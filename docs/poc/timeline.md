# PoC — Timeline

> Five-week execution plan for the 3×2 PoC matrix.

---

## Week-by-Week Plan

### Week 1 — Environment Setup

| Day | Activity |
|-----|---------|
| Day 1–2 | Deploy HYCU controller VM on Nutanix AHV cluster |
| Day 1–2 | Deploy Veeam Backup & Replication server |
| Day 1–3 | Validate Commvault pilot workflow, licensing, storage target, and restore path |
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
| Day 11–12 | **Cell A3**: Run Commvault protection, final sync, restore to standalone Hyper-V |
| Day 12 | Validate Commvault-restored VMs on Hyper-V and start Azure Migrate replication |
| Day 13 | Test migration for A1-A3 workloads to isolated Azure Local network |
| Day 14 | Production cutover for A1-A3 workloads; collect evidence and metrics |
| Day 15 | Rollback drill for one representative workload and prepare Azure Local-hosted Hyper-V staging for Option B |

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
| Day 21–22 | **Cell B3**: Run Commvault workload set using Azure Local-hosted Hyper-V staging |
| Day 23 | Validate B3 workloads and record Azure Local resource impact |
| Day 24 | Complete scorecard, finalize risk register, and compare all 6 cells |
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
| Which tool had the fastest initial transfer or restore window? | Veeam / HYCU / Commvault | Performance matters for wave planning |
| Which tool had faster cutover window? | | < 30 min per VM preferred |
| Did re-IP work reliably end-to-end? | | Veeam has advantage if complex |
| Did HYCU backup target add complexity? | | If yes, favor Veeam |
| Did Commvault's release-specific workflow stay supportable through pilot? | | If not, remove from shortlist |
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
| Veeam has best cutover and re-IP behavior | Use Veeam with the best passing A/B cell |
| Commvault performs adequately and governance fit is highest | Use Commvault with the best passing A/B cell |
| Azure Local-hosted Hyper-V adds no instability | Use the best passing **B-cell** — reduces hardware |
| Azure Local staging causes capacity issues | Use the best passing **A-cell** |
