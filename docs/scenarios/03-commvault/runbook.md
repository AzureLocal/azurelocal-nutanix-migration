# Commvault Migration Path — Runbook

> Step-by-step migration runbook using Commvault for Hop 1 and Azure Migrate for Hop 2.

---

> [!NOTE]
> **UI labels vary by Commvault release**
> Exact screen names and workflow labels differ between Command Center, legacy consoles, and specific Commvault feature packs. Treat the steps below as the execution pattern to implement, then map them to your current UI.
>
## Section 1 — Prepare the Commvault Environment

1. Confirm Commvault licensing covers the required Nutanix or VMware source workflow
2. Confirm the Commvault control plane and data-mover components are healthy
3. Validate that the storage target has enough free capacity for the active batch plus incremental overhead
4. Validate connectivity from Commvault to the source platform and the Hyper-V staging target

## Section 2 — Add the Source Platform

=== "Nutanix AHV"

    1. Add the Nutanix environment to Commvault using the supported AHV integration path
    2. Validate VM inventory and snapshot permissions
    3. Confirm the selected pilot VMs appear in policy scope

=== "Nutanix ESXi"

    1. Add the VMware environment through vCenter or ESXi
    2. Validate VM inventory and CBT or snapshot access as required
    3. Confirm the selected pilot VMs appear in policy scope

## Section 3 — Register Hyper-V Staging

1. Add the Hyper-V staging host or Azure Local-hosted Hyper-V target to Commvault
2. Validate credentials, storage path, and target switch mapping
3. Confirm restored VMs will land in the correct folder or storage location for Azure Migrate discovery

## Section 4 — Create the Migration Batch

1. Select a controlled batch of 5-10 VMs
2. Assign those VMs to the Commvault plan or policy used for migration staging
3. Run the initial protection or copy job and wait for completion
4. Review job results and address any application-consistency or snapshot warnings before cutover

## Section 5 — Cut Over to Hyper-V Staging

> [!WARNING]
> **Do not delete source VMs**
> Source Nutanix VMs remain the rollback point until Azure Local validation is complete.
>
1. Notify stakeholders and start the maintenance window
2. Trigger the final incremental protection or copy job
3. Power off the source VMs on Nutanix
4. Run the final sync needed by your Commvault workflow
5. Restore the VMs to the Hyper-V staging host
6. Power on the restored VMs on Hyper-V and validate guest health

## Section 6 — Re-IP After Restore (If Needed)

Commvault does not provide a repo-standard built-in re-IP mechanism in this documentation model. If subnets differ, use the same post-restore network-change discipline used for HYCU:

```powershell
# Example: Update IP post-restore
Set-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "10.0.2.50" -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "10.0.0.10"
```

## Section 7 — Azure Migrate Setup

1. Azure portal -> **Azure Migrate** -> **Create Project**
2. Deploy the Azure Migrate appliance on the Hyper-V staging host
3. Register the appliance with the project and confirm the staged VMs are discovered

## Section 8 — Azure Migrate Replication and Cutover

1. Select the staged VMs for replication to Azure Local
2. Set target Azure Local cluster, CSV path, VM names, and network mappings
3. Wait for **Protected** state
4. Run **Test Migration** to an isolated network
5. Validate workloads and clean up the test migration
6. Execute production cutover to create Azure Local VMs

## Section 9 — Cleanup

1. Keep source Nutanix VMs powered off during the holding period
2. Remove staged Hyper-V VMs once Azure Local validation is complete
3. Retire or repurpose the Commvault migration policy used for the batch
4. Reclaim staging and protection storage before starting the next wave
