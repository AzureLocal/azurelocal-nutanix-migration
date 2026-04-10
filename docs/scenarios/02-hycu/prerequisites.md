# HYCU Migration Path — Prerequisites

> All requirements that must be met before starting the HYCU migration.

---

## Licensing

| Component | Requirement |
|-----------|-------------|
| **HYCU License** | Per-VM subscription license required. HYCU licenses each protected VM. Contact your HYCU account representative or visit [hycu.com](https://www.hycu.com) for pricing. A **trial license** is available for PoC use. Licenses are applied in the HYCU web console (port 8443) after deployment. |
| **HYCU version** | The current product is **HYCU Protege** (also marketed as R-Cloud for on-premises deployments). Verify compatibility between your HYCU version and Nutanix AOS version before deployment. |
| **Azure Local** | Valid Azure Local subscription with Azure integration enabled |
| **Azure Migrate (for Azure Local)** | No additional license — included with Azure subscription. The Hyper-V → Azure Local migration feature is currently **in Preview** (requires Azure Local 2503+). |

!!! warning "Confirm licensing before starting"
    HYCU backup jobs will fail without a valid license applied. Obtain a trial license or production license from [hycu.com](https://www.hycu.com) before deploying the controller VM.

---

## Estimated Downtime Per VM

| Hop | Scenario | Typical VM Downtime |
|-----|----------|--------------------|
| Hop 1 | HYCU backup + restore to Hyper-V | **30 minutes to 4+ hours** per VM (restore time dominates; depends on VM disk size and storage throughput at ~500 MB/s typical) |
| Hop 2 | Azure Migrate cutover to Azure Local | **30–60 minutes** per batch of 10 VMs (final delta + Azure Local VM creation + first boot) |

!!! info "Estimating Hop 1 restore time"
    Plan approximately **1 hour per 200 GB of used VM disk** at typical 10 GbE network speeds. Test with representative VMs in the PoC to establish your baseline. HYCU does not offer Instant Recovery equivalent for Hyper-V targets, so restore time is not avoidable.

---

## HYCU Controller VM Requirements

Deploy a single HYCU controller VM on the Nutanix AHV cluster:

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 4 vCPU | 4 vCPU |
| RAM | 8 GB | 8 GB |
| Disk | 256 GB | 256 GB |
| OS | Linux (HYCU appliance image) | — |
| Network | Static IP on management VLAN | Static IP, DNS resolving both directions |
| Port | 8443 (HTTPS web console) | Open from admin workstations |

---

## HYCU Backup Target Requirements

HYCU requires a dedicated backup target to store VM backups before restoring to Hyper-V:

| Target Type | Protocol | Notes |
|-------------|----------|-------|
| SMB File Share | SMB 445 | Simplest; works with any Windows file server or NAS |
| NFS Export | NFS 2049 | Linux-based storage; works with Nutanix Files |
| S3-Compatible | HTTPS 443 | Nutanix Objects, MinIO, AWS S3 |
| iSCSI | iSCSI | Block-level; fast but requires iSCSI infrastructure |

**Storage sizing**: Plan for **1× used disk space** for the full backup + **10–20%** for incrementals, per concurrent batch. For 10 VMs averaging 100 GB used each, plan for ~1.2 TB on the backup target.

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

    !!! note "Two storage locations needed"
        HYCU requires **both** a backup target (holds the backup data) and the Hyper-V staging storage (holds restored VMs). Total storage = backup target + Hyper-V staging, both sized for one batch at a time.

=== "Azure Local as Hyper-V (Option B)"

    Add Azure Local cluster nodes as HYCU Hyper-V restore targets. HYCU discovers available CSV volumes and virtual switches on the cluster nodes.

    - Verify sufficient free CSV capacity for one batch (used disk × 1.1)
    - Ensure no production VMs will be impacted by migration I/O
    - Azure Migrate appliance can be deployed directly on the Azure Local cluster

---

## Network Requirements

| Connection | Protocol | Port | Notes |
|------------|----------|------|-------|
| HYCU Controller → Prism Element | HTTPS | 9440 | AHV source management |
| HYCU Controller → vCenter/ESXi | HTTPS | 443 | ESXi source |
| HYCU Controller → Backup Target (SMB) | SMB | 445 | Backup data writes |
| HYCU Controller → Backup Target (NFS) | NFS | 2049 | Backup data writes |
| HYCU Controller → Hyper-V Host (WinRM) | WinRM | 5985/5986 | Restore operations |
| Admin → HYCU Web Console | HTTPS | 8443 | Management access |
| Hyper-V Host → Azure | HTTPS | 443 | Azure Migrate appliance |
| Azure Migrate Appliance → Azure Local | SMB/HTTPS | 445, 443 | Replication |

---

## Nutanix Source Requirements

=== "Nutanix AHV"

    - Prism Element accessible over **HTTPS (TCP 9440)** from the HYCU controller VM
    - A Nutanix account with **Cluster Admin** privileges on Prism
    - HYCU controller VM must have IP connectivity to the Nutanix cluster management network
    - No additional proxy VM is deployed — HYCU communicates directly with AHV cluster APIs

=== "Nutanix ESXi"

    - vCenter or ESXi accessible over HTTPS (TCP 443) from HYCU
    - vCenter/ESXi service account with vSphere API access for VM discovery and snapshot operations
    - VMware Tools installed on source VMs (recommended for application-consistent backups)

---

## Pre-Start Checklist

| Item | Owner |
|------|-------|
| HYCU controller VM deployed on AHV cluster (4 vCPU / 8 GB RAM / static IP) | Infrastructure |
| HYCU licensed and activated (license key applied in web console port 8443) | Infrastructure |
| Nutanix AHV/ESXi cluster added as HYCU source; all VMs discovered | Infrastructure |
| HYCU backup target configured and tested (SMB/NFS/S3 with sufficient capacity) | Infrastructure |
| Hyper-V staging host registered as HYCU restore target | Infrastructure |
| Re-IP script prepared and tested (only if staging subnet differs from source) | Infrastructure |
| Azure Migrate project created | Cloud |
| Azure Migrate **source appliance** deployed on Hyper-V host and registered (Preview) | Cloud |
| Azure Migrate **target appliance** deployed on Azure Local and registered (Preview) | Cloud |
| Azure Local custom storage path and logical network created for Arc resource bridge | Infrastructure |
| Azure Local cluster healthy, Arc-registered, capacity verified | Infrastructure |
| BitLocker disabled on all source Windows VMs | Infrastructure |
| All network ports open between components | Networking |
| VM inventory sorted into batches of ≤10 | Migration Lead |
| IP/VLAN mapping spreadsheet complete | Networking |
