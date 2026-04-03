# PoC — Test Matrix

> The 3×2 PoC matrix tests all three two-hop tools against both staging options.

---

## Test Matrix Overview

|  | **Option A — Standalone Hyper-V** | **Option B — Azure Local-hosted Hyper-V** |
|--|----------------------------------|-------------------------------------------|
| **Veeam** | Cell **A1** — Veeam → Standalone HV → Azure Migrate → Azure Local | Cell **B1** — Veeam → Azure Local-hosted HV → Azure Migrate |
| **HYCU** | Cell **A2** — HYCU → Standalone HV → Azure Migrate → Azure Local | Cell **B2** — HYCU → Azure Local-hosted HV → Azure Migrate |
| **Commvault** | Cell **A3** — Commvault → Standalone HV → Azure Migrate → Azure Local | Cell **B3** — Commvault → Azure Local-hosted HV → Azure Migrate |

---

## VM Selection

Select **15 representative VMs** that cover the range of workloads in your environment:

| VM # | OS | Workload Type | Disk Size | Tier | Stateful | Re-IP Complexity | Dependency Group | Purpose |
|------|----|--------------|-----------|------|----------|------------------|------------------|---------|
| PoC-VM-01 | Windows Server 2022 | IIS Web App | 80 GB | Tier 2 | No | Medium | WEB-GRP | Veeam pilot workload |
| PoC-VM-02 | Windows Server 2022 | File Server | 200 GB | Tier 1 | Yes | High | FILE-GRP | Veeam large-disk test |
| PoC-VM-03 | Windows Server 2019 | SQL Server 2019 | 300 GB | Tier 1 | Yes | High | DB-GRP | Veeam DB workload |
| PoC-VM-04 | Ubuntu 22.04 | Web backend | 60 GB | Tier 2 | No | Medium | WEB-GRP | Veeam Linux workload |
| PoC-VM-05 | RHEL 8 | App server | 80 GB | Tier 2 | Yes | Medium | APP-GRP | Veeam RHEL workload |
| PoC-VM-06 | Windows Server 2019 | AD-joined workload | 80 GB | Tier 1 | Yes | High | ID-GRP | HYCU domain workload |
| PoC-VM-07 | Windows Server 2022 | Custom app | 100 GB | Tier 2 | Yes | Medium | APP-GRP | HYCU app workload |
| PoC-VM-08 | Ubuntu 20.04 | PostgreSQL | 150 GB | Tier 1 | Yes | Medium | DB-GRP | HYCU Linux DB |
| PoC-VM-09 | Windows Server 2016 | Print server | 80 GB | Tier 3 | Yes | Low | UTIL-GRP | HYCU older OS test |
| PoC-VM-10 | Windows Server 2022 | Multi-disk VM (3 disks) | 60+200+100 GB | Tier 1 | Yes | High | APP-GRP | HYCU multi-disk test |
| PoC-VM-11 | Windows Server 2022 | Line-of-business app | 120 GB | Tier 1 | Yes | High | APP2-GRP | Commvault app workload |
| PoC-VM-12 | Rocky Linux 9 | API service | 70 GB | Tier 2 | No | Medium | API-GRP | Commvault Linux workload |
| PoC-VM-13 | Windows Server 2019 | File and print combo | 160 GB | Tier 2 | Yes | Medium | FILE-GRP | Commvault file-state test |
| PoC-VM-14 | Oracle Linux 8 | Database service | 220 GB | Tier 1 | Yes | High | DB2-GRP | Commvault database workload |
| PoC-VM-15 | Windows Server 2016 | Legacy app server | 90 GB | Tier 2 | Yes | High | LEGACY-GRP | Commvault legacy-state test |

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

### Cell A3 — Commvault → Standalone Hyper-V

**Tool**: Commvault  
**Staging**: Dedicated physical or virtual Hyper-V host (not Azure Local)  
**VMs**: PoC-VM-11 through PoC-VM-15  

| Step | Action | Pass/Fail |
|------|--------|-----------|
| Commvault workflow validated | Release-specific restore-to-Hyper-V path confirmed | |
| Source inventory verified | All 5 VMs visible in Commvault scope | |
| Storage target confirmed | Protected copy location sized and healthy | |
| Initial protection or copy | All 5 VMs complete in expected time | |
| Final sync | Delta run completes without blocking errors | |
| Restore to Hyper-V | All 5 VMs land on Hyper-V staging as expected | |
| Re-IP post-restore | Script or manual network update succeeds | |
| Azure Migrate | All 5 VMs discovered, replicated, and cut over to Azure Local | |
| Post-cutover validation | All 5 VMs healthy on Azure Local | |

**Gate conditions (A3)**

- **Must pass**: restore workflow works end-to-end for all 5 VMs + no release-specific blocker discovered
- **Auto-fail**: unsupported restore path, repeated workflow mismatch, or rollback > 15 min/VM
- **Escalation owner**: Commvault engineer + PoC manager

---

### Cell B1 — Veeam → Azure Local-hosted Hyper-V

**Tool**: Veeam Backup & Replication  
**Staging**: Azure Local cluster node used as Hyper-V staging  
**VMs**: PoC-VM-01 through PoC-VM-05 (re-test in this configuration)  

Key differences from A1:
- No separate staging hardware — Azure Local node serves as the Hyper-V target
- Azure Migrate appliance also runs against the Azure Local-hosted staging layer
- Reduced hardware footprint, faster local handoff to Azure Migrate

**Gate conditions (B1)**

- **Must pass**: same A1 quality gates + no Azure Local capacity threshold breach
- **Auto-fail**: Azure Local node CPU > 85% sustained during business window or storage latency threshold exceeded
- **Escalation owner**: Veeam engineer + Azure Local platform owner

---

### Cell B2 — HYCU → Azure Local-hosted Hyper-V

**Tool**: HYCU Backup & Recovery  
**Staging**: Azure Local cluster node used as Hyper-V staging  
**VMs**: PoC-VM-06 through PoC-VM-10 (re-test in this configuration)  

Key differences from A2:
- No separate staging hardware
- HYCU restore target is Hyper-V on Azure Local
- Azure Migrate handoff is local to the same platform

**Gate conditions (B2)**

- **Must pass**: same A2 quality gates + stable restore throughput on Azure Local staging
- **Auto-fail**: repeated restore timeout for Tier 1 workloads or Azure Local resource saturation beyond threshold
- **Escalation owner**: HYCU engineer + Azure Local platform owner

---

### Cell B3 — Commvault → Azure Local-hosted Hyper-V

**Tool**: Commvault  
**Staging**: Azure Local cluster node used as Hyper-V staging  
**VMs**: PoC-VM-11 through PoC-VM-15 (re-test in this configuration)  

Key differences from A3:
- No separate staging hardware
- Restore path lands directly on Azure Local-hosted Hyper-V storage
- Capacity and cluster contention become primary validation gates

**Gate conditions (B3)**

- **Must pass**: same A3 workflow gates + stable restore throughput and no Azure Local saturation event
- **Auto-fail**: release-specific restore mismatch on Azure Local-hosted Hyper-V, or repeated storage or host contention
- **Escalation owner**: Commvault engineer + Azure Local platform owner

---

## Comparison Metrics

Record these for each cell to drive the tool and staging decision:

| Metric | A1 | A2 | A3 | B1 | B2 | B3 |
|--------|----|----|----|----|----|----|
| Initial full copy time (5 VMs, avg) | | | | | | |
| Incremental or delta time (5 VMs, avg) | | | | | | |
| Cutover window per VM | | | | | | |
| Re-IP success rate | | | | | | |
| Migration success rate (no errors) | | | | | | |
| Total hardware needed | | | | | | |
| Estimated scale-up time to 300 VMs | | | | | | |
| Operator complexity (1–5) | | | | | | |
| Rollback time per VM | | | | | | |

## Metrics Collection Template (required)

Use this format for every measured activity:

| Timestamp (UTC) | Cell | VM/Batch | Metric | Value | Unit | Operator | Evidence (log/screenshot path) | Confidence (1-5) | Notes |
|-----------------|------|----------|--------|-------|------|----------|-------------------------------|------------------|------|
| | A1 | PoC-VM-01..05 | Initial replication duration | | min | | | | |
| | A2 | PoC-VM-06..10 | Restore duration | | min | | | | |
| | A3 | PoC-VM-11..15 | Protected copy plus restore duration | | min | | | | |
| | B1 | PoC-VM-01..05 | Cutover duration per VM | | min | | | | |
| | B2 | PoC-VM-06..10 | Rollback duration per VM | | min | | | | |
| | B3 | PoC-VM-11..15 | Azure Local resource impact | | % / ms | | | | |

---

## PoC Decision Framework

After completing all 6 cells, use this framework to select the production path:

| Scenario | Recommended Choice |
|----------|--------------------|
| Target RPO < 15 min, large VMs (> 200 GB), re-IP required | **Veeam** — A1 or B1 based on staging result |
| Simplest deployment, Nutanix AHV source only | **HYCU** — A2 or B2 |
| Existing Commvault investment and centralized governance matter most | **Commvault** — A3 or B3 |
| No separate staging hardware available | Best passing **B-cell** (B1, B2, or B3) |
| Lowest operational complexity wins over feature depth | **HYCU** or **Commvault**, depending measured operator burden |
| Fastest large-wave throughput with reliable re-IP wins | **Veeam** |
