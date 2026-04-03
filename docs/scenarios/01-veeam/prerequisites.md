# Veeam Migration Path — Prerequisites

> All requirements that must be met before starting the Veeam migration.

---

## Licensing

| Component | Requirement |
|-----------|-------------|
| **Veeam Universal License (VUL)** | Required. Each replicated VM consumes one VUL instance. For rolling batches of 10, a minimum of **10 VUL instances** is sufficient if you delete completed replicas before starting the next batch. For all 300 VMs simultaneously, 300 VUL instances are needed. |
| **Azure Local** | Valid Azure Local subscription with Azure integration enabled |
| **Azure Migrate** | No additional license — included with Azure subscription |

!!! warning "Confirm licensing before starting"
    Engage your Veeam account team to confirm VUL count and entitlements before deploying. Replication jobs will fail if license limits are exceeded mid-migration.

---

## Veeam Server Requirements

Install Veeam Backup & Replication v12.x or later on a dedicated Windows Server VM:

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

    - Prism Element accessible over HTTPS (TCP 443) from the Veeam server
    - A Nutanix account with **Cluster Admin** role on Prism Element
    - Sufficient capacity on the Nutanix cluster for the **AHV Backup Proxy VM** (4 vCPU, 8 GB RAM, ~40 GB disk)
    - Nutanix Guest Tools (NGT) installed on source VMs **if using Veeam re-IP rules** (otherwise optional)

=== "Nutanix ESXi"

    - vCenter or ESXi accessible over HTTPS (TCP 443) from the Veeam server
    - A vCenter/ESXi account with **vSphere API** access (read access to VMs + snapshot operations)
    - VMware **Changed Block Tracking (CBT)** enabled on VMs (default for most configurations)
    - VMware Tools installed on source VMs (required for re-IP and application-consistent snapshots)

---

## Network Requirements

| Connection | Protocol | Port | Notes |
|------------|----------|------|-------|
| Veeam → Nutanix Prism Element | HTTPS | 443 | AHV source only |
| Veeam → vCenter/ESXi | HTTPS | 443 | ESXi source only |
| Veeam → Hyper-V host | WinRM | 5985/5986 | Management |
| Veeam → Hyper-V host | SMB | 445 | Replica disk transfer |
| Hyper-V host → Azure | HTTPS | 443 | Azure Migrate appliance |
| Hyper-V host → Azure Local nodes | SMB/HTTPS | 445, 443 | Azure Migrate replication |
| Azure Migrate appliance → Azure | HTTPS | 443 | Project registration, replication |

---

## Active Directory

- Hyper-V staging host should be **domain-joined** (simplifies credential management in Veeam)
- Service account for Veeam with local admin rights on the Hyper-V host
- Azure Migrate appliance service account with WMI and WinRM access to the Hyper-V host

---

## Pre-Start Checklist

| Item | Owner |
|------|-------|
| Veeam B&R v12+ installed and licensed | Infrastructure |
| Nutanix AHV cluster added to Veeam (AHV proxy deployed) | Infrastructure |
| Hyper-V staging host(s) provisioned and added to Veeam | Infrastructure |
| Azure Migrate project created in Azure portal | Cloud |
| Azure Migrate appliance deployed and registered | Cloud |
| Azure Local cluster healthy, Arc-registered, CSV capacity verified | Infrastructure |
| All network ports verified open between components | Networking |
| VM inventory complete — sorted into batches | Migration Lead |
| IP/VLAN mapping spreadsheet complete | Networking |
