# PoC — Test Matrix

> Test plans for all three PoC scenarios. Jump to the section matching your chosen scenario.

- [Scenario 1 — Single-Tool Test Template](#scenario-1-single-tool-test-template)
- [Scenario 2 — Two-Tool Comparison Test Plan](#scenario-2-two-tool-comparison-test-plan)
- [Scenario 3 — Full Three-Tool Matrix](#scenario-3-full-three-tool-matrix)

---

## Scenario 1 — Single-Tool Test Template

Run this for whichever tool you have selected. Repeat the same steps regardless of tool.

### VM Selection (3–5 VMs)

Select VMs that give you coverage across the dimensions that matter most in your environment:

| VM Slot | Suggested Profile | Why Include It |
|---------|-------------------|----------------|
| VM-01 | Windows Server, small disk (~80 GB), domain-joined | Baseline — fastest to complete, validates AD/DNS/re-IP |
| VM-02 | Windows Server, large disk (200+ GB), stateful/Tier 1 | Tests throughput; drives timing baseline for large VMs |
| VM-03 | Linux (Ubuntu or RHEL), application or database workload | Validates Linux guest restore and re-IP method |
| VM-04 *(optional)* | Multi-disk VM (3+ disks) | Tests disk ordering/mount points through restore |
| VM-05 *(optional)* | Legacy OS (WS2016 or older) | Surfaces any guest compatibility issues early |

### Single-Tool Test Checklist

| Step | Action | Record | Pass / Fail |
|------|--------|--------|-------------|
| 1 | Tool environment deployed and connected to Nutanix source | Screenshot of connected source | |
| 2 | First full backup or initial replication job started | Start time (UTC) | |
| 3 | First full backup or replication completes | End time, total data transferred | |
| 4 | Incremental/delta cycle runs and completes | Duration, delta size | |
| 5 | Maintenance window declared; final incremental triggered | Time stakeholders notified | |
| 6 | VMs powered off on Nutanix (downtime begins) | VM power-off timestamp per VM | |
| 7 | Restore or failover to Hyper-V staging (or Azure Local for Carbonite) | Start and end time per VM | |
| 8 | Re-IP applied (if subnet differs) | Per-VM IP change confirmed | |
| 9 | VM boots and passes Hop 1 validation checklist | Per-VM sign-off (see tool validation.md) | |
| 10 | Azure Migrate replication started and reaches Protected state | Duration per batch | |
| 11 | Azure Migrate test migration completed | Test VMs validated on isolated network | |
| 12 | Azure Migrate production cutover completed | Start and end time, downtime per VM | |
| 13 | Hop 2 validation completed on Azure Local | Per-VM sign-off | |
| 14 | Rollback drill: one VM rolled back to Nutanix and re-powered | Rollback duration recorded | |
| 15 | Go/No-Go signed | Signed record filed | |

Gate: All VMs at step 13 validated before signing Go/No-Go at step 15.

---

## Scenario 2 — Two-Tool Comparison Test Plan

Run the same 5-VM workload set through both tools using the same staging option. Compare the results using the metrics below.

### VM Selection (5 VMs — same set used for BOTH tools)

| VM # | Profile | Disk Size | Why |
|------|---------|-----------|-----|
| Comparison-VM-01 | Windows, IIS or app server | ~80 GB | Lightweight baseline |
| Comparison-VM-02 | Windows, file server or SQL, large disk | 200+ GB | Throughput and large-disk cutover |
| Comparison-VM-03 | Linux, database or backend | ~150 GB | Linux compatibility |
| Comparison-VM-04 | Windows, multi-disk (2–3 disks), AD-joined | ~60+100 GB | Disk mapping + re-IP validation |
| Comparison-VM-05 | Windows or Linux, stateful, Tier 1 | ~100 GB | Production-representative workload for rollback drill |

!!! tip "Why the same VMs?"
    Using identical VMs means differences in outcomes are attributable to the tool, not the workload. If you use different VMs per tool, you cannot draw valid comparisons from the timing data.

### Per-Tool Test Record

Run the [Single-Tool Test Checklist](#single-tool-test-checklist) above for each tool independently, recording all metrics separately.

### Comparison Scorecard

Fill this in after both tools have completed the checklist:

| Metric | Tool 1: _______ | Tool 2: _______ | Notes |
|--------|-----------------|-----------------|-------|
| Initial full copy time (5 VMs total) | | | |
| Incremental/delta cycle time | | | |
| Time from power-off to VM available on staging | | | |
| Re-IP success rate | | | |
| Azure Migrate to Azure Local cutover time (5 VMs) | | | |
| Migration success rate (no errors) | | | |
| Total Hop 1 downtime per VM (average) | | | |
| Total Hop 2 downtime per VM (average) | | | |
| Rollback time (from declaration to source VM live) | | | |
| Number of job failures requiring manual intervention | | | |
| Operator complexity rating (1 = simple, 5 = complex) | | | |
| Licensing cost per VM | | | |

Scoring guidance: For each metric, note which tool performed better. Count wins. Weight by the priority levels from the [Scorecard Decision Criteria](index.md#scorecard-decision-criteria) and select the tool with the highest weighted score.

---

## Scenario 3 — Full Three-Tool Matrix

> The 3×2 PoC matrix tests all three two-hop tools against both staging options.

### Test Matrix Overview

|  | **Option A — Standalone Hyper-V** | **Option B — Azure Local-hosted Hyper-V** |
|--|----------------------------------|-------------------------------------------|
| **Veeam** | Cell **A1** — Veeam → Standalone HV → Azure Migrate → Azure Local | Cell **B1** — Veeam → Azure Local-hosted HV → Azure Migrate |
| **HYCU** | Cell **A2** — HYCU → Standalone HV → Azure Migrate → Azure Local | Cell **B2** — HYCU → Azure Local-hosted HV → Azure Migrate |
| **Carbonite** | Cell **A3** — Carbonite → direct to Azure Local | Cell **B3** — repeat with different workload archetype |

---

## VM Selection (15 VMs — Scenario 3 Full Evaluation)

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
| PoC-VM-11 | Windows Server 2022 | Line-of-business app | 120 GB | Tier 1 | Yes | High | APP2-GRP | Carbonite app workload |
| PoC-VM-12 | Rocky Linux 9 | API service | 70 GB | Tier 2 | No | Medium | API-GRP | Carbonite Linux workload |
| PoC-VM-13 | Windows Server 2019 | File and print combo | 160 GB | Tier 2 | Yes | Medium | FILE-GRP | Carbonite file-state test |
| PoC-VM-14 | Oracle Linux 8 | Database service | 220 GB | Tier 1 | Yes | High | DB2-GRP | Carbonite database workload |
| PoC-VM-15 | Windows Server 2016 | Legacy app server | 90 GB | Tier 2 | Yes | High | LEGACY-GRP | Carbonite legacy-state test |

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

### Cell A3 — Carbonite → Azure Local (Direct)

**Tool**: Carbonite Migrate (Deploy-First / OpenText)
**Staging**: None — Carbonite replicates directly from Nutanix source to pre-provisioned Azure Local target VMs
**VMs**: PoC-VM-11 through PoC-VM-15

!!! info "No Hyper-V hop for Carbonite"
    The Carbonite path does not use Hyper-V staging or Azure Migrate. The target Azure Local VMs are provisioned first, then Carbonite agents replicate data directly. Azure Migrate is not part of this cell.

| Step | Action | Pass/Fail |
|------|--------|-----------|
| Target Azure Local VMs provisioned | All 5 target VMs deployed with matching disk layout | |
| Carbonite agents installed | Source (Nutanix) and target (Azure Local) agents online in management console | |
| Migration jobs created | 5 jobs created with correct replication scope and re-IP/DNS settings | |
| Initial mirror complete | All 5 VMs report healthy mirror completion | |
| Continuous replication active | Delta queue staying current (lag < 60 seconds sustained) | |
| Test cutover | Performed on isolated copy; app validated; reverted | |
| Production cutover | Source writes quiesced; final sync complete; target serving workload | |
| Post-cutover validation | All 5 VMs healthy on Azure Local; app smoke tests pass | |

**Gate conditions (A3)**

- **Must pass**: All 5 VMs cut over cleanly; cutover downtime ≤ 30 minutes per VM; source VMs held for rollback window
- **Auto-fail**: Replication failure on Tier 1 VM, data integrity mismatch, or rollback > 15 min/VM
- **Escalation owner**: OpenText/Carbonite engineer + PoC manager

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

### Cell B3 — Carbonite → Azure Local (Alternate Workload Set)

**Tool**: Carbonite Migrate (Deploy-First / OpenText)
**Staging**: None (same as A3 — Carbonite has no staging option variable)
**VMs**: Run PoC-VM-11..15 again under different load conditions, or substitute an alternate 5-VM set to test additional workload archetypes

Key differences from A3:
- Use to validate Carbonite under higher concurrency (run multiple jobs simultaneously)
- Or substitute larger-disk VMs to establish throughput ceiling
- Compare replication lag behaviour under production-representative load

**Gate conditions (B3)**

- **Must pass**: same A3 quality gates + no Azure Local resource saturation event
- **Auto-fail**: replication failure or throughput < 50% of A3 baseline under equivalent load
- **Escalation owner**: OpenText/Carbonite engineer + Azure Local platform owner

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
| Lowest expected downtime, no Hyper-V staging available, or direct-to-target preferred | **Carbonite (Deploy-First)** — A3 |
| No separate staging hardware available | Best passing **B-cell** (B1 or B2) or **Carbonite** A3 |
| Lowest operational complexity wins over feature depth | **HYCU** or **Carbonite**, depending on measured operator burden |
| Fastest large-wave throughput with reliable re-IP wins | **Veeam** |
