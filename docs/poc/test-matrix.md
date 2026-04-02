# PoC — Test Matrix

> The 2×2 PoC matrix tests both tools against both staging options.

---

## Test Matrix Overview

|  | **Option A — Standalone Hyper-V** | **Option B — Azure Local Direct** |
|--|----------------------------------|----------------------------------|
| **Veeam** | Cell A1 — Veeam → Standalone HV → Azure Migrate → AZL | Cell A3 — Veeam → AZL (HV on AZL node) → Azure Migrate |
| **HYCU** | Cell A2 — HYCU → Standalone HV → Azure Migrate → AZL | Cell A4 — HYCU → AZL (HV on AZL node) → Azure Migrate |

---

## VM Selection

Select **10 representative VMs** that cover the range of workloads in your environment:

| VM # | OS | Workload Type | Disk Size | Purpose |
|------|----|--------------|-----------|---------|
| PoC-VM-01 | Windows Server 2022 | IIS Web App | 80 GB | Test web workload |
| PoC-VM-02 | Windows Server 2022 | File Server | 200 GB | Test large disk |
| PoC-VM-03 | Windows Server 2019 | SQL Server 2019 | 300 GB | Test DB workload |
| PoC-VM-04 | Ubuntu 22.04 | Web backend | 60 GB | Test Linux |
| PoC-VM-05 | RHEL 8 | App server | 80 GB | Test RHEL |
| PoC-VM-06 | Windows Server 2019 | AD-joined workload | 80 GB | Test domain join |
| PoC-VM-07 | Windows Server 2022 | Custom app | 100 GB | Test legacy app |
| PoC-VM-08 | Ubuntu 20.04 | PostgreSQL | 150 GB | Test Linux DB |
| PoC-VM-09 | Windows Server 2016 | Print server | 80 GB | Test older OS |
| PoC-VM-10 | Windows Server 2022 | Multi-disk VM (3 disks) | 60+200+100 GB | Test multi-disk |

---

## Cell-by-Cell Test Plan

### Cell A1 — Veeam → Standalone Hyper-V

**Tool**: Veeam Backup & Replication  
**Staging**: Dedicated physical or virtual Hyper-V host (not Azure Local)  
**VMs**: PoC-VM-01 through PoC-VM-05  

| Step | Action | Pass/Fail |
|------|--------|-----------|
| Veeam server deployed | Deploy on Windows Server in Contoso datacenter | |
| AHV proxy added | Veeam deploys AHV proxy VM via Prism | |
| Replication job created | 5-VM job to Hyper-V staging host | |
| Initial replication | All 5 VMs complete in expected time | |
| Incremental replication | Daily incrementals run without errors | |
| Cutover (re-IP test) | VM reboots on Hyper-V, Veeam re-IP rules applied | |
| Azure Migrate | All 5 VMs discovered, replicated, and cut over to Azure Local | |
| Post-cutover validation | All 5 VMs healthy on Azure Local | |

---

### Cell A2 — HYCU → Standalone Hyper-V

**Tool**: HYCU Backup & Recovery  
**Staging**: Dedicated physical or virtual Hyper-V host (not Azure Local)  
**VMs**: PoC-VM-06 through PoC-VM-10  

| Step | Action | Pass/Fail |
|------|--------|-----------|
| HYCU controller deployed | Deployed on AHV cluster as Linux appliance VM | |
| Nutanix source added | All VMs visible in HYCU console | |
| Backup target configured | SMB share on Hyper-V staging host | |
| Hyper-V registered | Appears in HYCU as restore target | |
| Initial full backup | 5 VMs complete in expected time | |
| Incremental backup | Daily incrementals run without errors | |
| Restore to Hyper-V | All 5 VMs restored to Hyper-V staging host | |
| Re-IP post-restore | PowerShell re-IP script applied successfully | |
| Azure Migrate | All 5 VMs discovered, replicated, and cut over to Azure Local | |
| Post-cutover validation | All 5 VMs healthy on Azure Local | |

---

### Cell A3 — Veeam → Azure Local Node as HV

**Tool**: Veeam Backup & Replication  
**Staging**: Azure Local cluster node used as Hyper-V staging (directly on AZL)  
**VMs**: PoC-VM-01 through PoC-VM-05 (re-test in this configuration)  

Key differences from A1:
- No separate staging hardware — Azure Local node serves as the Hyper-V target
- Azure Migrate appliance also deployed directly on Azure Local
- Reduced hardware footprint, faster Hop 2 (replication from local storage to same cluster)

---

### Cell A4 — HYCU → Azure Local Node as HV

**Tool**: HYCU Backup & Recovery  
**Staging**: Azure Local cluster node used as Hyper-V staging  
**VMs**: PoC-VM-06 through PoC-VM-10 (re-test in this configuration)  

Key differences from A2:
- No separate staging hardware
- HYCU restore target is Hyper-V on Azure Local node
- Azure Migrate Hop 2 is essentially local

---

## Comparison Metrics

Record these for each cell to drive the tool/option decision:

| Metric | Cell A1 (Veeam/StandaloneHV) | Cell A2 (HYCU/StandaloneHV) | Cell A3 (Veeam/AZL) | Cell A4 (HYCU/AZL) |
|--------|------|------|------|------|
| Initial full backup/replication time (5 VMs, avg) | | | | |
| Incremental time (5 VMs, avg) | | | | |
| Cutover window per VM | | | | |
| Re-IP success rate | | | | |
| Migration success rate (no errors) | | | | |
| Total hardware needed | | | | |
| Estimated scale-up time to 300 VMs | | | | |
| Operator complexity (1–5) | | | | |
| Rollback time per VM | | | | |

---

## PoC Decision Framework

After completing all 4 cells, use this framework to select the production path:

| Scenario | Recommended Choice |
|----------|--------------------|
| Target RPO < 15 min, large VMs (> 200 GB), re-IP required | **Veeam + Standalone HV (A1)** |
| No separate staging hardware available | **Veeam + AZL (A3)** or **HYCU + AZL (A4)** |
| Simplest deployment, Nutanix AHV source only | **HYCU (A2 or A4)** |
| Large VM count (> 300), parallel throughput needed | **Veeam (A1 or A3)** |
| Lower Nutanix expertise on the team | **HYCU (A2 or A4)** — web UI, no SQL instance |
