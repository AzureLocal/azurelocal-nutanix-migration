# Deploy-First Migration

> Deploy new VMs directly on Azure Local, then migrate data from Nutanix source VMs.

---

!!! note "Scenario Overview"
    This scenario is the right choice when you want **clean, right-sized, modern VMs** on Azure Local rather than a like-for-like copy of your Nutanix VMs. Instead of replicating an existing VM image, you build new VMs from scratch and migrate only the **data and application state**.

## When to Use This Approach

| Use Case | Why Deploy-First |
|----------|-----------------|
| VMs running outdated OS (Server 2012/2016) | Good opportunity to refresh OS while migrating |
| VM was over-provisioned on Nutanix | Right-size CPU/RAM at migration time |
| Stateless or easily rebuilt workloads | Fastest path — just redeploy and repoint |
| Large file servers | Use Storage Migration Service (SMS) for clean data migration |
| SQL or app workloads | Use in-app migration tools (SQL backup/restore, DFS, etc.) |

## Not Suitable For

- VMs where the exact OS state must be preserved (use Veeam or HYCU instead)
- VMs with complex application state that cannot be easily migrated via data transfer

## Deploy-First Migration Steps

1. **Provision new VM on Azure Local** using Arc Virtual Machine provisioning or the Azure portal
2. **OS and application install** on the new VM (clean build)
3. **Data migration** using the appropriate tool:
    - **File data**: [Storage Migration Service (SMS)](https://learn.microsoft.com/en-us/windows-server/storage/storage-migration-service/overview) for Windows file servers
    - **File data**: Robocopy with `/MIR /ZB /W:5 /R:3` for simple file shares
    - **SQL Server**: SQL Server backup to Azure Blob, restore on target; or SQL Server log shipping
    - **IIS/Web apps**: xcopy/Robocopy content, export/import application pool settings
    - **Linux file systems**: rsync for files; database-native backup/restore for databases
4. **Cutover**: Point DNS/load balancers to the new Azure Local VM
5. **Decommission** source Nutanix VM after validation

## Carbonite Migrate

[Carbonite Migrate](https://www.carbonite.com/business/products/carbonite-migrate/) (formerly DoubleTake) is an OS-level agent-based migration tool. An agent is installed on each source VM and continuously replicates changed data to the target VM on Azure Local. Because it operates entirely at the OS level, it has no dependency on the source hypervisor — Nutanix AHV, VMware, Hyper-V, bare metal, it does not matter.

| Aspect | Detail |
|--------|--------|
| Source | Any OS (Windows, Linux) on any hypervisor |
| Target | Hyper-V, Azure Local |
| Agent required | Yes — installed on source VMs |
| Replication | Continuous, live block-level replication |
| Cutover | Near-zero downtime — final sync + cutover |
| Advantage | Hypervisor-independent; works on any OS version |

### When to Use Carbonite

- Source VMs are on Nutanix AHV and you cannot use Veeam or HYCU agentless replication
- Source hypervisor is unsupported or end-of-life
- You need continuous replication with minimal cutover downtime
- Mixed-OS environments (Windows and Linux in the same migration wave)

### How It Works

1. **Install the Carbonite Migrate agent** on each source VM (Windows or Linux)
2. **Install the Carbonite Migrate agent** on each target VM that has already been provisioned on Azure Local (deploy-first — new VM, clean OS)
3. **Create a migration job** in the Carbonite Migrate console pairing source → target
4. **Initial mirror**: Carbonite performs a full block-level sync from source to target — this runs in the background without interrupting the source VM
5. **Continuous replication**: After the initial mirror, Carbonite tracks and ships changed blocks in real time, keeping target in sync
6. **Cutover**: When ready, initiate cutover from the Carbonite console. Carbonite sends a final delta sync, then cuts over the target VM. Downtime is limited to the final sync window — typically minutes
7. **Validate** the target VM on Azure Local, then decommission the source on Nutanix

### Prerequisites

- Carbonite Migrate license (contact [Carbonite/OpenText sales](https://www.carbonite.com/business/products/carbonite-migrate/))
- Network connectivity from source Nutanix AHV VMs to target Azure Local VMs (ports 6325 TCP, 6326 TCP)
- Target VMs pre-provisioned on Azure Local with matching OS version — this is the deploy-first step
- Agent installation rights on source VMs (local admin on Windows, root/sudo on Linux)

### Supported OS

| OS | Versions |
|----|----------|
| Windows Server | 2012 R2, 2016, 2019, 2022 |
| Windows (client) | Not supported for server migrations |
| Linux | RHEL/CentOS 7+, SLES 12+, Ubuntu 18.04+ |

### Resources

- [Carbonite Migrate product page](https://www.carbonite.com/business/products/carbonite-migrate/)
- [Carbonite Migrate documentation](https://www.carbonite.com/support/)

## Resources

- [Storage Migration Service overview](https://learn.microsoft.com/en-us/windows-server/storage/storage-migration-service/overview)
- Automation scripts: `src/03-deploy-first/`

## Status

> This scenario is a planned expansion. Detailed runbook, prerequisites, and architecture pages will be added in a future release.
