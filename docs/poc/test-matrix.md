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

| VM # | OS | Workload Type | Disk Size | Tier | Stateful | Re-IP Complexity | Dependency Group | Purpose |
|------|----|--------------|-----------|------|----------|------------------|------------------|---------|
| PoC-VM-01 | Windows Server 2022 | IIS Web App | 80 GB | Tier 2 | No | Medium | WEB-GRP | Test web workload |
| PoC-VM-02 | Windows Server 2022 | File Server | 200 GB | Tier 1 | Yes | High | FILE-GRP | Test large disk |
| PoC-VM-03 | Windows Server 2019 | SQL Server 2019 | 300 GB | Tier 1 | Yes | High | DB-GRP | Test DB workload |
| PoC-VM-04 | Ubuntu 22.04 | Web backend | 60 GB | Tier 2 | No | Medium | WEB-GRP | Test Linux |
| PoC-VM-05 | RHEL 8 | App server | 80 GB | Tier 2 | Yes | Medium | APP-GRP | Test RHEL |
| PoC-VM-06 | Windows Server 2019 | AD-joined workload | 80 GB | Tier 1 | Yes | High | ID-GRP | Test domain join |
| PoC-VM-07 | Windows Server 2022 | Custom app | 100 GB | Tier 2 | Yes | Medium | APP-GRP | Test legacy app |
| PoC-VM-08 | Ubuntu 20.04 | PostgreSQL | 150 GB | Tier 1 | Yes | Medium | DB-GRP | Test Linux DB |
| PoC-VM-09 | Windows Server 2016 | Print server | 80 GB | Tier 3 | Yes | Low | UTIL-GRP | Test older OS |
| PoC-VM-10 | Windows Server 2022 | Multi-disk VM (3 disks) | 60+200+100 GB | Tier 1 | Yes | High | APP-GRP | Test multi-disk |

---

## Cell-by-Cell Test Plan

### Cell A1 — Veeam → Standalone Hyper-V

**Tool**: Veeam Backup & Replication  
**Staging**: Dedicated physical or virtual Hyper-V host (not Azure Local)  
**VMs**: PoC-VM-01 through PoC-VM-05  

| Step | Action | Pass/Fail |
|------|--------|-----------|
| Veeam server deployed | Deploy on Windows Server in IIC datacenter | |
| AHV proxy added | Veeam deploys AHV proxy VM via Prism | |
| Replication job created | 5-VM job to Hyper-V staging host | |
| Initial replication | All 5 VMs complete in expected time | |
| Incremental replication | Daily incrementals run without errors | |
| Cutover (re-IP test) | VM reboots on Hyper-V, Veeam re-IP rules applied | |
| Azure Migrate | All 5 VMs discovered, replicated, and cut over to Azure Local | |
| Post-cutover validation | All 5 VMs healthy on Azure Local | |

**Gate conditions (A1)**

- **Must pass**: 5/5 VMs boot + app smoke tests pass + cutover <= 30 min/VM
- **Auto-fail**: any data corruption, unrecoverable replication error, rollback > 15 min/VM
- **Escalation owner**: Veeam engineer + PoC manager

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

**Gate conditions (A2)**

- **Must pass**: 5/5 VMs restore cleanly + re-IP script success >= 95%
- **Auto-fail**: restore chain failure for any Tier 1 VM, repeated backup corruption
- **Escalation owner**: HYCU engineer + PoC manager

---

### Cell A3 — Veeam → Azure Local Node as HV

**Tool**: Veeam Backup & Replication  
**Staging**: Azure Local cluster node used as Hyper-V staging (directly on AZL)  
**VMs**: PoC-VM-01 through PoC-VM-05 (re-test in this configuration)  

Key differences from A1:
- No separate staging hardware — Azure Local node serves as the Hyper-V target
- Azure Migrate appliance also deployed directly on Azure Local
- Reduced hardware footprint, faster Hop 2 (replication from local storage to same cluster)

**Gate conditions (A3)**

- **Must pass**: same A1 quality gates + no Azure Local capacity threshold breach
- **Auto-fail**: Azure Local node CPU > 85% sustained during business window or storage latency threshold exceeded
- **Escalation owner**: Veeam engineer + Azure Local platform owner

---

### Cell A4 — HYCU → Azure Local Node as HV

**Tool**: HYCU Backup & Recovery  
**Staging**: Azure Local cluster node used as Hyper-V staging  
**VMs**: PoC-VM-06 through PoC-VM-10 (re-test in this configuration)  

Key differences from A2:
- No separate staging hardware
- HYCU restore target is Hyper-V on Azure Local node
- Azure Migrate Hop 2 is essentially local

**Gate conditions (A4)**

- **Must pass**: same A2 quality gates + stable restore throughput on Azure Local staging
- **Auto-fail**: repeated restore timeout for Tier 1 workloads, or AZL resource saturation beyond threshold
- **Escalation owner**: HYCU engineer + Azure Local platform owner

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

## Metrics Collection Template (required)

Use this format for every measured activity:

| Timestamp (UTC) | Cell | VM/Batch | Metric | Value | Unit | Operator | Evidence (log/screenshot path) | Confidence (1-5) | Notes |
|-----------------|------|----------|--------|-------|------|----------|-------------------------------|------------------|------|
| | A1 | PoC-VM-01..05 | Initial replication duration | | min | | | | |
| | A2 | PoC-VM-06..10 | Restore duration | | min | | | | |
| | A3 | PoC-VM-01..05 | Cutover duration per VM | | min | | | | |
| | A4 | PoC-VM-06..10 | Rollback duration per VM | | min | | | | |

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
