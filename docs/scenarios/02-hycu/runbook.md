# HYCU Migration Path — Runbook

> Step-by-step migration runbook using HYCU. Execute one batch of 8–10 VMs at a time.

---

## Section 1 — HYCU Setup

### 1.1 Deploy HYCU Controller VM

1. Download the HYCU appliance image (QCOW2 for AHV) from the HYCU customer portal
2. In Prism, create a new VM: **4 vCPU, 8 GB RAM, 256 GB disk**
3. Assign a static IP on the management VLAN; verify DNS resolution in both directions
4. Power on the VM — HYCU boots within a few minutes
5. Open a browser: `https://<hycu-ip>:8443`
6. Set admin password, accept EULA, apply your HYCU license key

### 1.2 Add Nutanix Cluster as Source

=== "Nutanix AHV"

    1. In HYCU web console → **Administration → Sources → Add Source**
    2. Select **Nutanix AHV**
    3. Enter Prism Element cluster VIP or FQDN
    4. Provide Nutanix Cluster Admin credentials
    5. HYCU validates connectivity and auto-discovers all VMs, volume groups, and Nutanix Files shares
    6. Verify VM inventory shows the expected count

=== "Nutanix ESXi"

    1. In HYCU web console → **Administration → Sources → Add Source**
    2. Select **VMware vSphere**
    3. Enter vCenter or ESXi FQDN
    4. Provide vSphere service account credentials
    5. HYCU discovers all VMs managed by vCenter

### 1.3 Configure Backup Target

1. HYCU console → **Administration → Targets → Add Target**
2. Select target type (SMB, NFS, S3, or iSCSI) and provide connection details and credentials
3. Test the connection and save
4. **Size the target** for the total used disk of the concurrent batch + 20% overhead

### 1.4 Register Hyper-V Host as Restore Target

1. HYCU console → **Administration → Targets → Add Target**
2. Select **Microsoft Hyper-V**
3. Enter Hyper-V host FQDN and provide domain or local admin credentials
4. HYCU discovers available storage paths and virtual switches on the Hyper-V host
5. Set the default restore path (e.g., `D:\Restored`) and default virtual switch
6. Verify the connection shows healthy

---

## Section 2 — Create Backup Policies (Per Batch)

1. HYCU console → **Policies → Create Policy**
2. **Name**: Use `MIG-Batch01-VMs001-010`, `MIG-Batch02-VMs011-020`, etc.
3. **Assign VMs**: Select exactly 8–10 VMs for this batch
4. **Schedule**: Daily incrementals; set a manual or scheduled full backup time
5. **Retention**: Keep at least the latest restore point (short retention is fine for migration-only use)
6. **Run Initial Full Backup**: Trigger the first full backup immediately. Monitor progress.

Initial full backup time varies with VM disk size and backup target bandwidth (typically 2–12 hours per batch on first run).

---

## Section 3 — Cutover Procedure (Per Batch)

!!! warning "Do not delete source VMs"
    Source Nutanix VMs are your rollback point. Do NOT decommission them until the batch is fully validated on Azure Local.

### 3.1 Pre-Cutover

1. Notify stakeholders — maintenance window begins for this batch
2. Trigger a **manual incremental backup** to capture the latest changes
3. Wait for the incremental to complete successfully

### 3.2 Cutover Steps

1. **Power off source VMs** on Nutanix (in Prism or vCenter)
2. Trigger **one more manual incremental backup** to capture final dirty blocks from shutdown
3. **Restore to Hyper-V**:
    - In HYCU console, select each VM → **Restore → Restore to Hyper-V**
    - Select the Hyper-V staging host registered in step 1.4
    - Select the restore storage path and virtual switch
    - HYCU automatically converts disk format to VHDX during restore
4. Monitor restore progress in the HYCU console
5. Power on the restored VMs on Hyper-V

### 3.3 Re-IP After Restore (If Subnets Differ)

!!! info "HYCU does not have built-in re-IP rules"
    Unlike Veeam, HYCU does not inject new IP addresses during restore. If your Hyper-V staging network uses different subnets, use the PowerShell helper in `src/02-hycu/powershell/Set-VMIPAddress.ps1` to update IPs post-restore.

```powershell
# Example: Update IP post-restore
Set-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "10.0.2.50" -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "10.0.0.10"
```

### 3.4 Rollback (If Needed)

If Hyper-V validation fails:

1. Power off the restored Hyper-V VMs
2. Delete the restored VMs from the Hyper-V host
3. Power the source Nutanix VMs back on in Prism/vCenter
4. Investigate the issue, adjust, and retry the restore

---

## Section 4 — Azure Migrate Setup

Same as the Veeam path — Azure Migrate is independent of the Hop 1 tool:

### 4.1 Create Azure Migrate Project

1. Azure portal → **Azure Migrate** → **Create Project**
2. Project name: use IIC naming (e.g., `nutanix-to-azl-migration`)
3. Subscription: tied to Azure Local cluster registration
4. Resource Group: `rg-iic-migration-01`

### 4.2 Deploy Azure Migrate Appliance

1. Azure Migrate → **Discover** → select **Hyper-V**
2. Download and deploy the appliance VHD on the Hyper-V staging host (**8 GB RAM, 4 vCPU**)
3. Configure via browser wizard — register with project key
4. Add Hyper-V host credentials; start discovery

---

## Section 5 — Azure Migrate Replication and Cutover

### 5.1 Start Replication

1. Azure Migrate → **Replicate** → Source: Hyper-V | Target: Azure Local
2. Select Azure Local cluster + target CSV volume
3. Select the 10 restored VMs; set target VM names (original names); set virtual switch
4. Click **Replicate** — wait for **Protected** state

### 5.2 Test Migration

1. Select all 10 VMs → **Test Migration** → select isolated test network
2. Validate all VMs (see [Validation section](validation.md))
3. **Clean up test migration** after validation

### 5.3 Production Cutover

1. Select all 10 VMs → **Migrate**
2. Azure Migrate performs a final delta sync and creates Azure Local VMs on Azure Local
3. Confirm VMs visible in Azure portal as Azure Local VMs
4. Click **Complete Migration**

---

## Section 6 — Cleanup

After the batch is fully validated on Azure Local:

1. Delete the restored Hyper-V VMs to free staging storage
2. Delete HYCU backup policies for this batch (or disable them) to free backup target storage
3. Begin the next batch (return to Section 2)
4. Source Nutanix VMs: keep powered off during the holding period; decommission after it expires

---

## Batch Execution Tracker

| Batch | VMs | Full Backup | Restore to HV | HV Validation | Azure Migrate | Azure Local | Status |
|-------|-----|-------------|---------------|---------------|---------------|-------------|--------|
| Batch 01 | VM001–VM010 | — | — | — | — | — | Not Started |
| Batch 02 | VM011–VM020 | — | — | — | — | — | Not Started |
| Batch 03 | VM021–VM030 | — | — | — | — | — | Not Started |
| Batch 04–30 | ... | — | — | — | — | — | Not Started |
