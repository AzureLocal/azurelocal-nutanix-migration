# Veeam Migration Path — Runbook

> Step-by-step migration runbook. Execute one batch of 8–10 VMs at a time.

---

## Section 1 — Veeam Setup

### 1.1 Add Nutanix as a Source

=== "Nutanix AHV"

    1. In the Veeam console, navigate to **Backup Infrastructure → Managed Servers**
    2. Click **Add Server → Nutanix AHV**
    3. Enter the Prism Element cluster VIP or hostname
    4. Provide credentials — a Nutanix local admin or AD account with Cluster Admin role on Prism
    5. Accept the SSL certificate and verify the cluster is discovered
    6. Veeam automatically deploys the **AHV Backup Proxy VM** on the Nutanix cluster
    7. Verify the AHV proxy VM is running in Prism and shows as online in Veeam → Backup Infrastructure → Backup Proxies

    !!! info "AHV Proxy VM"
        The AHV proxy requires **4 vCPU and 8 GB RAM** on the Nutanix cluster. Ensure capacity is available. The proxy handles Changed Block Tracking (CBT) snapshots and data reads from AHV.

=== "Nutanix ESXi"

    1. In the Veeam console, navigate to **Backup Infrastructure → Managed Servers**
    2. Click **Add Server → VMware vSphere → vCenter Server** (or ESXi host if standalone)
    3. Enter the vCenter FQDN or IP address
    4. Provide service account credentials with vSphere API access
    5. Verify VM inventory is discovered in the Veeam console

### 1.2 Add Hyper-V Staging Host as Target

1. In Veeam console, go to **Backup Infrastructure → Managed Servers**
2. Click **Add Server → Microsoft Hyper-V → Standalone** (or Cluster for Azure Local Option B)
3. Enter the FQDN of the Hyper-V host
4. Provide domain admin or local admin credentials
5. Veeam installs the transport service and data mover components automatically
6. Verify the host shows as healthy under Managed Servers

---

## Section 2 — Create Replication Jobs (Per Batch)

Create one replication job per batch of 10 VMs. Use consistent naming.

### 2.1 Job Configuration

1. **New Job**: Home → **Replication Job** → Virtual Machine
    - AHV source: select **Nutanix AHV**
    - ESXi source: select **VMware vSphere**
2. **Name**: Use `REP-Batch01-VMs001-010`, `REP-Batch02-VMs011-020`, etc.
3. **Select VMs**: Add exactly 10 VMs from inventory. Group by application affinity.
4. **Destination**: Select the Hyper-V staging host. Set replica storage path (e.g., `D:\Replicas\Batch01`)
5. **Network Mapping**: Map source networks to the corresponding Hyper-V virtual switch
6. **Re-IP Rules** (if subnets differ):
    - Configure under Guest Processing → Network
    - Specify source IP range and target IP range
    - Requires NGT (AHV) or VMware Tools (ESXi) on source VMs
7. **Schedule**: Set to manual trigger or a specific maintenance window. Do **not** enable concurrent replication for all batches simultaneously.

### 2.2 Initial Replication

1. Right-click the replication job → **Start**
2. Monitor progress in the **Job History** pane
3. Initial full replication time varies with VM disk size and network bandwidth (typically 4–24 hours for a 10-VM batch)
4. Verify all 10 VMs reach **Replication successful** status

### 2.3 Incremental Syncs

- Allow scheduled incrementals to run until the cutover window
- Monitor the last successful sync time to ensure replicas remain current
- Fix any failed incrementals promptly to minimize the cutover delta

---

## Section 3 — Cutover Procedure (Per Batch)

!!! warning "Do not delete source VMs"
    Source Nutanix VMs are your rollback point. Do NOT decommission them until the batch is fully validated on Azure Local.

### 3.1 Pre-Cutover

1. Notify stakeholders — maintenance window begins for this batch
2. Trigger a **manual incremental sync** to capture the latest changes
3. Wait for the incremental to complete successfully

### 3.2 Cutover Steps

1. **Power off source VMs** on Nutanix (Prism or vCenter)
2. Trigger **one more manual incremental sync** to capture final dirty blocks from shutdown
3. In Veeam, right-click the replication job → **Failover**
4. Select the latest restore point
5. Veeam powers on the replica VMs on Hyper-V

### 3.3 Rollback (if needed)

If validation fails on Hyper-V:

1. Right-click the job → **Undo Failover** — this reverts to the source AHV/ESXi VMs
2. Power the source VMs back on
3. Investigate and resolve before retrying

### 3.4 Commit Failover

After successful Hyper-V validation (see [Validation section](validation.md)):

1. Right-click the job → **Commit Failover** — this finalizes the failover and removes the undo capability
2. Proceed to Azure Migrate replication (Section 4)

---

## Section 4 — Azure Migrate Setup {#section-4}

### 4.1 Create Azure Migrate Project

1. Azure portal → **Azure Migrate** → **Create Project**
2. **Project name**: `nutanix-to-azl-migration` (or your naming standard, e.g., `rg-iic-migration-01`)
3. **Subscription**: The subscription tied to your Azure Local cluster registration
4. **Resource Group**: `rg-iic-migration-01`
5. **Geography**: Region closest to your datacenter

### 4.2 Deploy Azure Migrate Appliance

1. In Azure Migrate project → **Discover** under Migration and Modernization
2. Select **Hyper-V** as the virtualization platform
3. Download the Azure Migrate appliance VHD
4. Create a new VM on the Hyper-V staging host using this VHD: **8 GB RAM, 4 vCPU, 80 GB disk**
5. Boot the appliance VM and open the browser-based configuration wizard
6. Register the appliance with your Azure Migrate project using the project key from the portal
7. Add Hyper-V host credentials (domain admin or local admin with WMI access)
8. Start discovery — wait for VMs to appear in the Azure Migrate portal (typically 5–15 minutes)

---

## Section 5 — Azure Migrate Replication and Cutover

### 5.1 Start Replication

1. Azure Migrate → **Migration and Modernization** → **Replicate**
2. Source: **Hyper-V** | Target: **Azure Local**
3. Select the Azure Local cluster and target CSV volume
4. Select the 10 VMs from this batch
5. Set target VM name = original VM name
6. Set target virtual switch and network
7. Click **Replicate** — wait for all VMs to reach **Protected** state

### 5.2 Test Migration

1. Select all 10 VMs → **Test Migration**
2. Select an isolated test network on Azure Local (no production traffic)
3. Validate all VMs (see [Validation section](validation.md))
4. After validation: **Clean up test migration**

### 5.3 Production Cutover

1. Select all 10 VMs → **Migrate**
2. Toggle **Shutdown VMs before migration** = Yes (or leave off if already powered off from Veeam cutover)
3. Azure Migrate performs a final delta sync and creates Azure Local VMs on Azure Local
4. Confirm VMs are visible in the Azure portal as Azure Local VMs
5. Click **Complete Migration** to stop replication

---

## Section 6 — Cleanup

After the batch is fully validated on Azure Local:

1. Delete the Hyper-V replica VMs from the staging host to reclaim storage
2. In Veeam, remove or disable the replication job for this batch (or delete replicas from Veeam console)
3. Begin the next batch (return to Section 2)
4. Do not decommission source Nutanix VMs until all batches are complete and you have a defined holding period

---

## Batch Execution Tracker

| Batch | VMs | Replication Start | HV Validation | Azure Migrate Start | Azure Local Go-Live | Status |
|-------|-----|-------------------|---------------|--------------------|--------------------|--------|
| Batch 01 | VM001–VM010 | — | — | — | — | Not Started |
| Batch 02 | VM011–VM020 | — | — | — | — | Not Started |
| Batch 03 | VM021–VM030 | — | — | — | — | Not Started |
| Batch 04–30 | ... | — | — | — | — | Not Started |

Copy and extend this table in a shared spreadsheet for your actual migration tracking.
