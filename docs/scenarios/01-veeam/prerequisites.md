# Veeam Migration Path — Prerequisites

> All requirements that must be met before starting the Veeam migration.

---

## Licensing

| Component | Requirement |
|-----------|-------------|
| **Veeam Data Platform (VUL)** | Required. Choose **Foundation**, **Advanced**, or **Premium** edition. Each protected VM consumes **1 VUL instance**. Licenses are sold in packs of 10. For rolling batches of 10, a minimum of **10 VUL instances** is sufficient — instances can be revoked from completed batches and re-assigned to the next batch. For all VMs simultaneously, match the VUL count to your total VM count. |
| **Veeam B&R version** | Minimum **v12.2** (AHV plugin integrated; no separate installer). Current recommended: **v13** (v13.0.1.1071 as of early 2026). |
| **Azure Local** | Valid Azure Local subscription with Azure integration enabled |
| **Azure Migrate (for Azure Local)** | No additional license — included with Azure subscription. The Hyper-V → Azure Local migration feature is currently **in Preview** (Azure Local 2503+). |

> [!WARNING]
> **Confirm licensing before starting**
> Engage your Veeam account team to confirm VUL count and entitlements. Backup jobs fail if license limits are exceeded mid-migration. VUL instances consumed by AHV VMs are released when they are no longer protected by an active backup job, so rolling batch migrations are efficient on license count.
>
---

## Estimated Downtime Per VM

| Hop | Scenario | Typical VM Downtime |
|-----|----------|--------------------|
| Hop 1 — AHV | Instant Recovery to Hyper-V (recommended) | **15–30 minutes** per VM (final backup + IR mount; VM runs from repo while data migrates in background) |
| Hop 1 — AHV | Full Restore to Hyper-V | **1–4 hours** per VM (depends on VM disk size and storage throughput) |
| Hop 1 — ESXi | Replication Failover | **15–30 minutes** per batch (final delta sync + Veeam failover + VM boot) |
| Hop 2 | Azure Migrate cutover to Azure Local | **30–60 minutes** per batch of 10 VMs (final delta + Azure Local VM creation + first boot) |

> [!TIP]
> **Minimising Hop 1 downtime for AHV**
> Use **Instant Recovery to Hyper-V**: the VM is available on Hyper-V within ~15 min of the final backup completing. Veeam migrates the VHDX data to Hyper-V local storage in the background with no additional disruption to the running workload.
>
---

## Veeam Server Requirements

Install Veeam Backup & Replication **v12.2 or later** (v13 recommended) on a dedicated Windows Server VM:

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 4 vCPU | 8 vCPU |
| RAM | 16 GB | 32 GB |
| OS Disk | 100 GB | 150 GB |
| OS | Windows Server 2022 | Windows Server 2022 or 2025 |
| .NET | 4.7.2+ | included in WS2022 |
| SQL | SQL Express (bundled) | SQL Express for <500 VMs |

---

## Hyper-V Staging Host Requirements

=== "Standalone Hyper-V (Option A)"

    | Resource | Minimum | Recommended |
    |----------|---------|-------------|
    | CPU | 8 cores | 16+ cores |
    | RAM | 32 GB | 64 GB |
    | Storage | 2 TB local SSD | 4 TB NVMe or thin-provisioned SAN LUN |
    | Network | 1 GbE | 10 GbE |
    | OS | Windows Server 2022 | Windows Server 2025 |
    | Roles | Hyper-V | Hyper-V, domain-joined |

    Size storage for the total **used disk space** of your largest concurrent batch. For 10 VMs averaging 200 GB used, plan for ~2–2.5 TB.

=== "Azure Local as Hyper-V (Option B)"

    Add one or more Azure Local cluster **nodes** as Veeam Managed Hyper-V servers. Replicated VMs land on CSV (Cluster Shared Volume) storage as plain Hyper-V VMs.

    - Verify sufficient free space on CSV volumes for the batch (used disk space × 1.1)
    - Azure Local must not have production VMs that could be impacted by migration I/O
    - Azure Migrate appliance can be deployed directly on the Azure Local cluster

---

## Nutanix Source Requirements

=== "Nutanix AHV"

    - Prism Element or Prism Central accessible over **HTTPS (TCP 9440)** from the Veeam server
    - A Nutanix account with **Cluster Admin** role on Prism Element (or equivalent on Prism Central)
    - Sufficient capacity on the Nutanix cluster for the **Veeam Worker VM** (default: 6 vCPU, 6 GB RAM, 100 GB disk)
    - **iSCSI Data Service IP** configured in the Nutanix AHV cluster settings (required for Veeam iSCSI disk reads)
    - **UEFI boot** must be supported in the Nutanix AHV environment (required for Worker VM deployment)
    - Nutanix AOS **6.8.1.6 or later** required
    - Prism Central: pc.2022.6 through pc.2024.3.1.10, or pc.7.3 and later (except 7.3.1.2 and 7.5.0.0)
    - NGT (Nutanix Guest Tools) optional but recommended for application-consistent backups

=== "Nutanix ESXi"

    - vCenter or ESXi accessible over HTTPS (TCP 443) from the Veeam server
    - A vCenter/ESXi account with **vSphere API** access (read access to VMs + snapshot operations)
    - VMware **Changed Block Tracking (CBT)** enabled on VMs (default for most configurations)
    - VMware Tools installed on source VMs (required for re-IP and application-consistent snapshots)

---

## Network Requirements

| Connection | Protocol | Port | Notes |
|------------|----------|------|-------|
| Veeam server → Nutanix Prism Element / Prism Central | HTTPS | **9440** | AHV source — Nutanix REST API |
| Veeam Worker VM → Nutanix cluster (VIP, iSCSI Data Service IP, CVM IPs) | iSCSI | 3205, 3260 | iSCSI disk access for backups |
| Veeam server → Worker VM | TCP | 19000 | Backup server to worker communication |
| Worker VM → Veeam backup server | TCP | 10006, 2500–3300 | Data transfer and ransomware index |
| Veeam server → vCenter/ESXi | HTTPS | 443 | ESXi source only |
| Veeam server → Hyper-V host | WinRM | 5985/5986 | Management |
| Veeam server → Hyper-V host | SMB | 445 | VHDX data transfer (restore/replication) |
| Hyper-V host → Azure | HTTPS | 443 | Azure Migrate appliance / ASR provider |
| Azure Migrate source appliance ↔ target appliance (on Azure Local) | SMB | 445 | Replication data path |
| Azure Migrate appliances → Azure | HTTPS | 443 | Project registration, metadata |

---

## Active Directory

- Hyper-V staging host should be **domain-joined** (simplifies credential management in Veeam)
- Service account for Veeam with local admin rights on the Hyper-V host
- Azure Migrate appliance service account with WMI and WinRM access to the Hyper-V host

---

## Pre-Start Checklist

| Item | Owner |
|------|-------|
| Veeam B&R v12.2+ installed and licensed (VUL count confirmed) | Infrastructure |
| Nutanix AHV cluster (AOS 6.8.1.6+) added to Veeam; Worker VM deployed and healthy | Infrastructure |
| iSCSI Data Service IP configured on the Nutanix cluster | Infrastructure |
| Hyper-V staging host(s) provisioned and added to Veeam | Infrastructure |
| Azure Migrate project created in Azure portal | Cloud |
| Azure Migrate **source appliance** deployed on Hyper-V host and registered | Cloud |
| Azure Migrate **target appliance** deployed on Azure Local and registered (Preview) | Cloud |
| Azure Local cluster healthy, Arc-registered, custom storage path and logical network created | Infrastructure |
| BitLocker disabled on all source VMs to be migrated | Infrastructure |
| All network ports verified open between components (including TCP 9440, TCP 3260, SMB 445) | Networking |
| VM inventory complete — sorted into batches of ≤10 | Migration Lead |
| IP/VLAN mapping spreadsheet complete | Networking |
