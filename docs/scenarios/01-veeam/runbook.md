# Veeam Migration Path — Runbook

> Step-by-step migration runbook. Execute one batch of 8–10 VMs at a time.

---

## Section 1 — Veeam Setup

### 1.1 Add Nutanix as a Source

=== "Nutanix AHV"

    1. In the Veeam console, navigate to **Backup Infrastructure → Managed Servers**
    2. Click **Add Server → Nutanix AHV**
    3. Enter the Prism Element cluster VIP/hostname **or** the Prism Central address
    4. Provide credentials — a Nutanix admin account with Cluster Admin role on Prism Element (or equivalent on Prism Central)
    5. Accept the SSL certificate and verify the cluster is discovered
    6. Veeam automatically deploys the **AHV Worker VM** on the Nutanix cluster
    7. Verify the Worker VM is running in Prism and shows as online in Veeam → Backup Infrastructure → Backup Proxies

    !!! info "AHV Worker VM"
        The Worker VM default configuration is **6 vCPU, 6 GB RAM, 100 GB disk**. It handles up to 4 concurrent tasks by default. The Worker processes backup workloads and distributes backup traffic. The Nutanix cluster must have the **iSCSI Data Service IP** configured and UEFI boot support enabled. Nutanix AOS **6.8.1.6 or later** is required.

    !!! warning "Veeam AHV uses backup, not live replication"
        Unlike the ESXi path, Veeam Backup & Replication for AHV creates scheduled **backups** (not continuously-running live replicas). Migration to Hyper-V is achieved via **Instant Recovery to Hyper-V** (very low downtime) or **Full VM Restore to Hyper-V**. See Section 3 for details.

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

## Section 2 — Create Jobs (Per Batch)

Create one job per batch of up to 10 VMs. Follow the appropriate tab for your source platform.

### 2.1 Job Configuration

=== "Nutanix AHV — Backup Job"

    1. **New Job**: Home → **Backup Job** → Nutanix AHV
    2. **Name**: Use `BAK-Batch01-VMs001-010`, `BAK-Batch02-VMs011-020`, etc.
    3. **Select VMs**: Add exactly 10 VMs from inventory. Group by application affinity.
    4. **Backup Repository**: Select a high-speed Veeam repository (local NVMe or SAN LUN). Size for the full backup of all VMs in the batch.
    5. **Schedule**: Enable scheduled incrementals (e.g., every 60 minutes) to keep the backup current with low RPO before cutover.
    6. **Guest Processing**: Enable application-aware processing for SQL/Exchange/AD VMs (requires NGT on source VMs for Windows).

=== "Nutanix ESXi — Replication Job"

    1. **New Job**: Home → **Replication Job** → Virtual Machine (VMware vSphere)
    2. **Name**: Use `REP-Batch01-VMs001-010`, `REP-Batch02-VMs011-020`, etc.
    3. **Select VMs**: Add exactly 10 VMs. Group by application affinity.
    4. **Destination**: Select the Hyper-V staging host. Set replica storage path (e.g., `D:\Replicas\Batch01`)
    5. **Network Mapping**: Map source networks to the corresponding Hyper-V virtual switch
    6. **Re-IP Rules** (if subnets differ):
        - Configure under Guest Processing → Network
        - Specify source IP range and target IP range
        - Requires VMware Tools on source VMs
    7. **Schedule**: Set to manual trigger or a specific maintenance window.

### 2.2 Initial Backup / Replication

=== "AHV Backup"

    1. Right-click the backup job → **Active Full Backup** (first run)
    2. Monitor progress in the **Job History** pane
    3. Initial full backup time varies with VM disk size and network bandwidth (typically 2–12 hours for a 10-VM batch)
    4. Verify all 10 VMs reach **Backup successful** status
    5. Allow scheduled incrementals to run until the cutover window. Mail each VM's "last backup" timestamp is recent before proceeding.

=== "ESXi Replication"

    1. Right-click the replication job → **Start**
    2. Monitor progress in the **Job History** pane
    3. Initial full replication time varies (typically 4–24 hours for a 10-VM batch)
    4. Verify all 10 VMs reach **Replication successful** status
    5. Allow scheduled incrementals to run. Monitor last successful sync time.

---

## Section 3 — Hop 1 Cutover Procedure (Per Batch)

!!! warning "Do not delete source VMs"
    Source Nutanix VMs are your rollback point. Do **NOT** decommission them until the batch is fully validated on Azure Local.

!!! info "Hop 1 downtime starts at VM power-off and ends when the VM is running and validated on Hyper-V"
    AHV (Instant Recovery): typically **15–30 minutes**. AHV (Full Restore): **1–4 hours**. ESXi (Replication): **15–30 minutes**.

### 3.1 Pre-Cutover

1. Notify stakeholders — maintenance window begins for this batch
2. Trigger a **final incremental backup** (AHV) or **manual incremental sync** (ESXi) immediately
3. Wait for it to complete successfully

### 3.2 Cutover Steps

=== "AHV — Instant Recovery to Hyper-V (Recommended)"

    **Downtime target: 15–30 minutes**

    1. **Power off source VMs** on Nutanix (Prism)
    2. Trigger **one final incremental backup** to capture the last dirty blocks from shutdown
    3. Wait for backup to complete
    4. In Veeam console: right-click each VM in the backup job → **Instant Recovery** → **To Hyper-V**
    5. Select the Hyper-V staging host, virtual switch, and storage path
    6. Veeam mounts the backup and starts the VM on Hyper-V — VM is running within minutes
    7. Validate the VM on Hyper-V (see [Hop 1 Validation](validation.md#hop-1-go--no-go-sign-off))
    8. Once validated, right-click the restored VM in Veeam → **Migrate to Production Storage** to move VHDX data from the backup repository to Hyper-V local storage. The VM stays running during this process.

=== "AHV — Full Restore to Hyper-V (Alternative)"

    **Downtime target: 1–4 hours (size-dependent)**

    1. **Power off source VMs** on Nutanix (Prism)
    2. Trigger **one final incremental backup** to capture the last dirty blocks from shutdown
    3. Wait for backup to complete
    4. In Veeam console: right-click each VM in the backup job → **Restore** → **Entire VM Restore**
    5. Select **Restore to a different location or platform**; choose **Hyper-V**
    6. Select the Hyper-V staging host, virtual switch, and target storage path
    7. Veeam converts and restores to VHDX. Monitor progress; power on when complete.
    8. Validate the VM on Hyper-V (see [Hop 1 Validation](validation.md#hop-1-go--no-go-sign-off))

=== "ESXi — Replication Failover"

    **Downtime target: 15–30 minutes**

    1. **Power off source VMs** on Nutanix ESXi / vCenter
    2. Trigger **one more manual incremental sync** to capture final dirty blocks from shutdown
    3. Wait for sync to complete
    4. In Veeam, right-click the replication job → **Failover**
    5. Select the latest restore point
    6. Veeam powers on the replica VMs on Hyper-V
    7. Validate the VMs on Hyper-V (see [Hop 1 Validation](validation.md#hop-1-go--no-go-sign-off))

### 3.3 Rollback (if needed)

=== "AHV Instant Recovery"
    1. In Veeam, stop the Instant Recovery session — the backup repo copy is untouched
    2. Power the source AHV VMs back on in Prism
    3. Investigate the issue, resolve, then retry

=== "AHV Full Restore"
    1. Delete the restored Hyper-V VMs
    2. Power the source AHV VMs back on in Prism
    3. Investigate and resolve before retrying

=== "ESXi Replication"
    1. Right-click the job → **Undo Failover** — this reverts to the source ESXi VMs
    2. Power the source VMs back on
    3. Investigate and resolve before retrying

### 3.4 Commit Hop 1

After successful Hyper-V validation (see [Hop 1 Go / No-Go Sign-off](validation.md#hop-1-go--no-go-sign-off)):

- **AHV IR path**: Complete the “Migrate to Production Storage” operation if not already done, then confirm VM runs from local HV storage.
- **AHV Full Restore**: Confirm VM runs successfully and sign-off is complete.
- **ESXi path**: Right-click the replication job → **Commit Failover** — removes undo capability.
- In all cases: proceed to Azure Migrate replication (Section 4).

---

## Section 4 — Azure Migrate Setup (Hop 2) {#section-4}

!!! note "Azure Migrate for Azure Local is in Preview"
    The native Hyper-V → Azure Local migration path via Azure Migrate uses a **dual appliance** architecture and is currently in **Preview** (requires Azure Local 2503+). Both a **source appliance** (on the Hyper-V host) and a **target appliance** (on the Azure Local cluster) are required. Data does not leave your datacenter.

### 4.1 Prepare Azure Local Prerequisites

Before deploying appliances, confirm on the Azure Local cluster:

1. Azure Local instance deployed, Arc-registered, and healthy
2. A **custom storage path** created for the Arc resource bridge (VM configuration and OS disks)
3. A **logical network** created for the Arc resource bridge for migrated VMs
4. Contributor + User Access Administrator roles granted on the subscription for the Azure Migrate project

### 4.2 Create Azure Migrate Project

1. Azure portal → **Azure Migrate** → **Create Project**
2. **Project name**: `nutanix-to-azl-migration` (or your naming standard)
3. **Subscription**: The subscription tied to your Azure Local cluster registration
4. **Resource Group**: `rg-iic-migration-01`
5. **Geography**: Region closest to your datacenter

### 4.3 Deploy the Source Appliance (Hyper-V Host)

1. In Azure Migrate project → **Discover** under Migration and Modernization
2. Select **Hyper-V** as the virtualization platform and **Azure Local** as the target
3. Download the Azure Migrate **source appliance** VHD (**16 GB RAM, 8 vCPU, 80 GB disk**)
4. Create a new VM on the Hyper-V staging host using this VHD
5. Boot the appliance and open the browser-based configuration wizard on port 44368
6. Register the source appliance with your Azure Migrate project using the project key
7. Add Hyper-V host credentials (domain admin or local admin with WMI/WinRM access)
8. Start discovery — wait for VMs to appear in the Azure Migrate portal (typically 5–15 minutes)

### 4.4 Deploy the Target Appliance (Azure Local Cluster)

1. In Azure Migrate project → **Deploy target appliance**
2. Download and deploy the Azure Migrate **target appliance** on the Azure Local cluster
3. Register the target appliance with the same Azure Migrate project
4. Associate the target appliance with the Azure Local custom location, storage path, and logical network
5. Verify both appliances show as **Connected** in the Azure Migrate portal

---

## Section 5 — Azure Migrate Replication and Cutover (Hop 2)

!!! info "Hop 2 downtime starts when VMs are shut down for final delta sync and ends when Azure Local VMs pass validation"
    Typical cutover downtime: **30–60 minutes per batch** of 10 VMs.

### 5.1 Start Replication

1. Azure Migrate → **Migration and Modernization** → **Replicate**
2. Source: **Hyper-V** | Target: **Azure Local**
3. Select the Azure Local cluster, custom storage path, and logical network
4. Select the 10 staged Hyper-V VMs from this batch
5. Set target VM name = original VM name; configure network and storage
6. Click **Replicate** — wait for all VMs to reach **Protected** state (initial replication may take several hours depending on disk size and bandwidth; VMs remain running on Hyper-V during this time)

### 5.2 Test Migration

1. Select all 10 VMs → **Test Migration**
2. Select an **isolated test network** on Azure Local (no production traffic)
3. Validate all VMs (see [Hop 2 Validation](validation.md#hop-2-validation--azure-local))
4. After validation: **Clean up test migration**

### 5.3 Production Cutover

!!! info "Downtime begins here for Hop 2"
    Azure Migrate shuts down the Hyper-V VM, performs a final delta sync, then creates the Azure Local VM. Expected total time per batch of 10 VMs: **30–60 minutes**.

1. Select all 10 VMs → **Migrate**
2. Toggle **Shutdown VMs before migration** = **Yes** to ensure no data loss
3. Azure Migrate performs a final delta sync and creates Azure Local VMs on Azure Local
4. Confirm VMs are visible in the Azure portal as Azure Local VMs
5. Validate all VMs (see [Hop 2 Validation](validation.md#hop-2-validation--azure-local))
6. Click **Complete Migration** to stop replication

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
