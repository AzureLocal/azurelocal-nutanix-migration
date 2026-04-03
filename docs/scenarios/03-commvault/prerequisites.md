# Commvault Migration Path — Prerequisites

> All requirements that must be met before starting the Commvault migration path.

---

## Licensing

| Component | Requirement |
|-----------|-------------|
| **Commvault** | Valid Commvault licensing for Nutanix or VMware source protection and restore workflows |
| **Azure Local** | Valid Azure Local subscription with Azure integration enabled |
| **Azure Migrate** | No additional license — included with Azure subscription |

!!! warning "Validate Commvault feature entitlement early"
    Exact Hop 1 behavior depends on the Commvault release and licensed modules in your estate. Confirm Nutanix or VMware source support, restore-to-Hyper-V workflow, and required worker components before starting the pilot.

---

## Core Commvault Components

The exact Commvault topology varies. This documentation assumes the minimum operational footprint below:

| Component | Purpose | Notes |
|-----------|---------|-------|
| Commvault control plane | Policy, orchestration, inventory, and job control | Command Center or equivalent admin surface must be reachable |
| Media or worker component | Data movement between source, storage, and restore target | Size according to concurrent batch throughput |
| Commvault storage target | Holds protected copies before restore to Hyper-V staging | Plan for full copy plus incremental overhead |
| Hyper-V restore target | Receives restored VMs as VHDX-backed workloads | Can be standalone Hyper-V or Azure Local-hosted Hyper-V staging |

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

=== "Azure Local as Hyper-V (Option B)"

    Add Azure Local cluster nodes as the Hyper-V restore target for staged cutover validation.

    - Verify sufficient free CSV capacity for one batch (used disk x 1.1 or more)
    - Ensure migration I/O will not compete with production workloads
    - Deploy the Azure Migrate appliance directly on the Azure Local-hosted Hyper-V layer if using this option

---

## Network Requirements

| Connection | Protocol | Port | Notes |
|------------|----------|------|-------|
| Commvault components -> Prism Element | HTTPS | 9440 | AHV source management |
| Commvault components -> vCenter/ESXi | HTTPS | 443 | ESXi source management |
| Commvault components -> Hyper-V host | WinRM | 5985/5986 | Restore and host management |
| Commvault components -> Hyper-V host | SMB | 445 | VHDX placement and file operations |
| Admin workstation -> Commvault console | HTTPS | 443 | Management access |
| Hyper-V host -> Azure | HTTPS | 443 | Azure Migrate appliance |
| Azure Migrate appliance -> Azure Local | SMB/HTTPS | 445, 443 | Replication |

!!! note "Version-specific Commvault ports"
    Additional Commvault inter-service ports vary by release and deployment model. Use the vendor networking guidance for your exact version in addition to the core ports above.

---

## Source Requirements

=== "Nutanix AHV"

    - Prism Element reachable from the Commvault data mover path
    - Nutanix account with the required snapshot and inventory permissions
    - Pilot validation confirming the restore workflow to Hyper-V staging for your exact release

=== "Nutanix ESXi"

    - vCenter or ESXi reachable from the Commvault environment
    - vSphere account with inventory, snapshot, and restore-related permissions
    - VMware Tools installed on protected VMs when required for your backup consistency model

---

## Pre-Start Checklist

| Item | Owner |
|------|-------|
| Commvault licensing and supported workflow confirmed | Infrastructure |
| Control plane and worker components deployed | Infrastructure |
| Nutanix or VMware source added and inventory verified | Infrastructure |
| Commvault storage target sized and tested | Infrastructure |
| Hyper-V staging target reachable and validated | Infrastructure |
| Azure Migrate project created | Cloud |
| Azure Migrate appliance deployed and registered | Cloud |
| Azure Local cluster healthy, integrated, and capacity-checked | Infrastructure |
| Network ports open between all components | Networking |
| Batch inventory and dependency grouping complete | Migration Lead |
| IP/VLAN mapping spreadsheet complete | Networking |
| Re-IP script or post-restore network procedure prepared | Infrastructure |