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

## Resources

- [Storage Migration Service overview](https://learn.microsoft.com/en-us/windows-server/storage/storage-migration-service/overview)
- Automation scripts: `src/03-deploy-first/`

## Status

> This scenario is a planned expansion. Detailed runbook, prerequisites, and architecture pages will be added in a future release.
