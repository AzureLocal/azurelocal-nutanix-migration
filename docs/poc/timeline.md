# PoC — Timeline

> Choose the timeline that matches your PoC scenario. All three options use the same entry and exit criteria — they differ in scope, not rigour.

| Scenario | Timeline | Section |
|----------|----------|---------|
| Scenario 1 — Single Tool Quick PoC | ~1 week | [1-Week Timeline](#1-week-single-tool-poc) |
| Scenario 2 — Two-Tool Comparison | ~3 weeks | [3-Week Timeline](#3-week-two-tool-comparison) |
| Scenario 3 — Full Three-Tool Evaluation | 4–5 weeks | [Full Evaluation Timeline](#full-evaluation-timeline) |

---

## 1-Week Single-Tool PoC

Use when you have already chosen a tool and just need to validate the end-to-end process before production.

| Day | Activity |
|-----|---------|
| Day 1 | Deploy tool environment (Veeam, HYCU, or Carbonite management server); verify connectivity to Nutanix source; document 3–5 PoC VMs |
| Day 1–2 | Start initial backup, replication, or mirror job for all PoC VMs; record start time |
| Day 2 | Monitor initial copy completion; record duration; confirm incremental/delta cycle is healthy |
| Day 3 | *(Two-hop paths only)* Deploy Azure Migrate source appliance; register with project; discover Hyper-V staging VMs |
| Day 3 | Trigger final incremental; declare maintenance window; begin cutover — power off source VMs, run restore/failover/cutover |
| Day 3–4 | Validate all VMs using Hop 1 go/no-go checklist (see tool-specific validation.md); obtain batch sign-off |
| Day 4 | *(Two-hop paths only)* Start Azure Migrate replication; wait for Protected state; run test migration on isolated network |
| Day 4–5 | Azure Migrate production cutover; validate on Azure Local; record Hop 2 downtime |
| Day 5 | Rollback drill: roll one VM back to Nutanix; record duration; complete final Go/No-Go sign-off |

**Minimum deliverables:** Timing log, per-VM gate checklist, one rollback drill record, signed Go/No-Go.

---

## 3-Week Two-Tool Comparison

Use when comparing two tools side-by-side with the same workload set.

### Week 1 — Setup and Tool 1

| Day | Activity |
|-----|---------|
| Day 1 | Deploy both tool environments; verify connectivity to Nutanix source; document 5 shared PoC VMs |
| Day 1–2 | **Tool 1**: Start initial backup/replication/mirror for all 5 PoC VMs; record start time |
| Day 2 | Monitor Tool 1 initial copy; record duration; confirm incremental cycle |
| Day 3 | **Tool 1 Cutover**: maintenance window; final incremental; power off source VMs; restore/cutover to staging (Hyper-V or Azure Local) |
| Day 3–4 | Validate Tool 1 VMs using Hop 1 checklist; record per-VM downtime |
| Day 4–5 | *(Two-hop paths)* Azure Migrate replication for Tool 1; test migration; record Protected state timing |
| Day 5 | Tool 1 Azure Migrate production cutover; validate on Azure Local; record Hop 2 downtime |

### Week 2 — Tool 2

| Day | Activity |
|-----|---------|
| Day 6 | Power source VMs back on (restored to last-known state on Nutanix); re-baseline before Tool 2 run |
| Day 6–7 | **Tool 2**: Start initial backup/replication/mirror for the same 5 PoC VMs; record start time |
| Day 7–8 | Monitor Tool 2 initial copy; confirm incremental cycle |
| Day 9 | **Tool 2 Cutover**: maintenance window; final incremental; power off source VMs; restore/cutover |
| Day 9–10 | Validate Tool 2 VMs using Hop 1 checklist; record per-VM downtime |
| Day 10 | *(Two-hop paths)* Azure Migrate replication for Tool 2 VMs |

### Week 3 — Comparison and Decision

| Day | Activity |
|-----|---------|
| Day 11–12 | Tool 2 Azure Migrate test migration and production cutover; validate on Azure Local; record Hop 2 downtime |
| Day 13 | Rollback drill for each tool (one VM each); record duration |
| Day 14 | Complete comparison scorecard (see [Scenario 2 Scorecard](test-matrix.md#comparison-scorecard)); review weighted results |
| Day 15 | Decision meeting — select production tool; draft production wave plan; sign Go/No-Go |

**Minimum deliverables:** Timing log for both tools, comparison scorecard, one rollback drill per tool, signed recommendation and Go/No-Go.

---

## Full Evaluation Timeline

> Original 4–5-week plan for Scenario 3 (all three tools, both staging options).

---

## Week-by-Week Plan

### Week 1 — Environment Setup

| Day | Activity |
|-----|---------|
| Day 1–2 | Deploy HYCU controller VM on Nutanix AHV cluster |
| Day 1–2 | Deploy Veeam Backup & Replication server |
| Day 1–3 | Deploy Carbonite management server; validate connectivity to Nutanix source and Azure Local target; confirm licensing |
| Day 2–3 | Configure HYCU source, backup target, and Hyper-V restore target |
| Day 2–3 | Configure Veeam source, AHV proxy, and Hyper-V replication destination |
| Day 3–4 | Provision standalone Hyper-V staging host for Option A tests |
| Day 3–5 | Verify Azure Local cluster health, CSV capacity, and Azure integration readiness |
| Day 4–5 | Deploy Azure Migrate appliance; register with project |
| Day 5 | Identify and document the 15 PoC VMs; record baseline OS, apps, IPs, and services |

---

### Week 2 — Option A: Cells A1 + A2

| Day | Activity |
|-----|---------|
| Day 6–7 | **Cell A1**: Start Veeam replication job (PoC-VM-01..05) to standalone Hyper-V |
| Day 6–7 | **Cell A2**: Start HYCU full backup (PoC-VM-06..10) |
| Day 7 | Monitor initial full copy completion; record timing |
| Day 8 | Let incremental cycles run; confirm CBT or incremental behavior |
| Day 9 | **Cell A1 Cutover**: final sync, failover, re-IP validation |
| Day 9 | **Cell A2 Cutover**: final increment, restore, post-restore re-IP validation |
| Day 10 | Validate A1 and A2 VMs on Hyper-V and start Azure Migrate replication |

---

### Week 3 — Option A: Cell A3 + Azure Migrate Completion

| Day | Activity |
|-----|---------|
| Day 11–12 | **Cell A3**: Deploy Carbonite agents on PoC-VM-11..15 source and pre-provisioned Azure Local targets; start initial mirror |
| Day 12–13 | Monitor initial mirror completion; confirm continuous replication; validate delta lag < 60 seconds |
| Day 13 | Test migration for A1/A2 workloads to isolated Azure Local network; validate |
| Day 14 | Production cutover for A1/A2 workloads; collect evidence and metrics |
| Day 14–15 | **Cell A3 Cutover**: Carbonite production cutover for PoC-VM-11..15; validate on Azure Local; record downtime |
| Day 15 | Rollback drill for one representative workload; prepare Azure Local-hosted Hyper-V staging for Option B |

---

### Week 4 — Option B: Cells B1 + B2

| Day | Activity |
|-----|---------|
| Day 16–17 | **Cell B1**: Re-run Veeam workload set using Azure Local-hosted Hyper-V staging |
| Day 16–17 | **Cell B2**: Re-run HYCU workload set using Azure Local-hosted Hyper-V staging |
| Day 18 | Validate both cells on staging and monitor Azure Local resource impact |
| Day 19 | Run Azure Migrate test migration for B1 and B2 |
| Day 20 | Complete B1 and B2 cutovers; document capacity, throughput, and operational complexity |

---

### Week 5 — Option B: Cell B3 + Decision

| Day | Activity |
|-----|---------|
| Day 21–22 | **Cell B3**: Re-run Carbonite workload set or alternate workload archetypes against Azure Local targets |
| Day 23 | Validate B3 workloads; record Azure Local resource impact under concurrent Carbonite + Azure Migrate load |
| Day 24 | Complete scorecard, finalize risk register, and compare all cells |
| Day 25 | **Go/No-Go** meeting — select the production migration tool and staging model |

---

## PoC VM IP / Naming Assignments

Use IIC naming convention for PoC VMs on Azure Local:

| PoC VM | Source Name | AZL Target Name | Source IP | Target IP |
|--------|-------------|-----------------|-----------|-----------|
| PoC-VM-01 | \<nutanix-vm-name\> | \<azl-vm-name\> | \<ip\> | \<ip\> |
| PoC-VM-02 | — | — | — | — |
| ... | — | — | — | — |

Fill in this table before starting Week 2. Shared with networking team for VLAN/subnet changes.

---

## Rollback Runbook (PoC)

### Rollback triggers

- Tier 1 VM fails application smoke test after cutover
- Data integrity mismatch detected (checksums/record counts/files)
- Cutover exceeds agreed downtime window

### Rollback steps

1. Declare rollback and freeze further cutovers in current cell
2. Stop target workload on Azure Local VM
3. Power on source VM on Nutanix (or restore prior running state)
4. Repoint DNS/LB records to source VM
5. Validate app health from business-owner test script
6. Record rollback duration and root cause in metrics workbook

### Rollback validation

- Source VM serving production traffic
- Application owner confirms service restoration
- Incident notes and remediation plan documented before next test wave

---

## Capacity and Saturation Thresholds

Treat these as stop-wave thresholds during PoC execution:

| Domain | Threshold | Action if exceeded |
|--------|-----------|--------------------|
| Azure Local node CPU | > 85% sustained for 15+ minutes | Pause replication/cutover wave; scale down concurrency |
| Azure Local memory pressure | < 15% free sustained | Pause non-critical test jobs |
| CSV free capacity | < 25% remaining | Stop new replication; reclaim space |
| Storage latency | > 20 ms sustained | Pause wave; investigate storage bottleneck |
| Replication network throughput | < planned floor for 30+ minutes | Extend window and re-baseline estimate |

---

## Decision Framework

After the PoC, answer these questions to finalize tool selection:

| Question | Answer | Impact |
|----------|--------|--------|
| Did all three tools successfully migrate their workload sets? | Yes / No / Partial | Eliminate failing tools from production shortlist |
| Which tool had the fastest initial transfer or restore window? | Veeam / HYCU / Carbonite | Performance matters for wave planning |
| Which tool had faster cutover window? | | < 30 min per VM preferred |
| Did re-IP work reliably end-to-end? | | Veeam has advantage if complex re-IP needed |
| Did HYCU backup target add complexity? | | If yes, consider Veeam or Carbonite |
| Did Carbonite replication lag stay consistently low before cutover? | | If not, investigate network or storage bottleneck |
| Was standalone HV needed, or is Azure Local-hosted Hyper-V sufficient? | | If Azure Local is sufficient, reduces hardware |
| Team preference after hands-on use? | | Operator comfort matters at 300-VM scale |

### Weighted scorecard model

Use weighted scoring to prevent subjective decisions:

| Category | Weight | A1 | A2 | A3 | B1 | B2 | B3 |
|----------|:------:|:--:|:--:|:--:|:--:|:--:|:--:|
| Migration fidelity / reliability | 30% | | | | |
| Speed (full + incremental + cutover) | 20% | | | | |
| Operational complexity | 15% | | | | |
| Re-IP and network stability | 10% | | | | |
| Rollback performance | 10% | | | | |
| Capacity efficiency / hardware footprint | 10% | | | | |
| Team fit / supportability | 5% | | | | |

Scoring method:

- Rate each category 1-5 per cell
- Weighted score = `rating * weight`
- Sum weighted scores to rank A1-A3 and B1-B3
- Any auto-fail gate overrides score and disqualifies that cell

### Outcome Scenarios

| Outcome | Production Recommendation |
|---------|--------------------------|
| HYCU is fastest and simplest for AHV workloads | Use HYCU with the best passing A/B cell |
| Veeam has best cutover and re-IP behaviour | Use Veeam with the best passing A/B cell |
| Carbonite has lowest downtime and no staging hardware needed | Use Carbonite (Deploy-First) path |
| Azure Local-hosted Hyper-V adds no instability | Use the best passing **B-cell** — reduces hardware |
| Azure Local staging causes capacity issues | Use the best passing **A-cell** |
