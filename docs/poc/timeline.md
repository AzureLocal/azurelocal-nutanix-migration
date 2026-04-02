# PoC — Timeline

> Four-week execution plan for the 2×2 PoC matrix.

---

## Week-by-Week Plan

### Week 1 — Environment Setup

| Day | Activity |
|-----|---------|
| Day 1–2 | Deploy HYCU controller VM on Nutanix AHV cluster |
| Day 1–2 | Deploy Veeam Backup & Replication server |
| Day 2–3 | Configure HYCU source (Nutanix AHV), backup target, and Hyper-V restore target |
| Day 2–3 | Configure Veeam AHV source, AHV proxy, and Hyper-V replication destination |
| Day 3–4 | Provision standalone Hyper-V staging host (for Option A tests) |
| Day 3–5 | Verify Azure Local cluster health, CSV capacity, Arc registration |
| Day 4–5 | Deploy Azure Migrate appliance on Hyper-V staging host; register with project |
| Day 5 | Identify and document the 10 PoC VMs; record baseline: OS, apps, IP, services |

---

### Week 2 — Cell A1 + A2 (Standalone Hyper-V)

| Day | Activity |
|-----|---------|
| Day 6–7 | **Cell A1**: Start Veeam replication job (PoC-VM-01..05) to standalone Hyper-V |
| Day 6–7 | **Cell A2**: Start HYCU full backup (PoC-VM-06..10) |
| Day 7 | Monitor initial full replication/backup completion; record timing |
| Day 8 | Let 2× incremental cycles run; confirm CBT/incremental working |
| Day 9 | **Cell A1 Cutover**: Power off PoC-VM-01..05 on Nutanix; run final sync; power on HV VMs; test re-IP |
| Day 9 | **Cell A2 Cutover**: Power off PoC-VM-06..10; run final increment; restore to Hyper-V; apply re-IP script |
| Day 10 | Validate all 10 VMs on Hyper-V (see validation checklist) |
| Day 10 | Start Azure Migrate replication from Hyper-V → Azure Local for all 10 VMs |

---

### Week 3 — Azure Migrate Cutover (A1+A2) + Cell A3+A4 Setup

| Day | Activity |
|-----|---------|
| Day 11–12 | **Test migration**: Azure Migrate test-migrate all 10 VMs to isolated vnet on Azure Local |
| Day 12 | Validate all 10 VMs on Azure Local; run app smoke tests |
| Day 13 | **Production cutover**: Complete Azure Migrate for all 10 VMs |
| Day 13 | Document metrics for Cells A1 and A2 |
| Day 14 | Power source Nutanix VMs back on (restore from powered-off state — rollback test) |
| Day 15 | **Re-run**: Begin Cells A3+A4 using Azure Local nodes as Hyper-V staging |

---

### Week 4 — Cell A3 + A4 + Decision

| Day | Activity |
|-----|---------|
| Day 16–17 | Run Cell A3 (Veeam → AZL) and Cell A4 (HYCU → AZL) — same VMs, different staging |
| Day 17–18 | Cutover and validate all 10 VMs in Option B configuration |
| Day 19 | Record all metrics, compare all 4 cells |
| Day 19 | Run full [Decision Framework](#decision-framework) analysis |
| Day 20 | **Go/No-Go** meeting — decide production migration tool and path |

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

## Decision Framework

After the PoC, answer these questions to finalize tool selection:

| Question | Answer | Impact |
|----------|--------|--------|
| Did both tools successfully migrate all 10 VMs? | Yes / No / Partial | If no, eliminate that tool |
| Which tool had faster initial transfer? | Veeam / HYCU | Veeam if delta < 20%, otherwise either |
| Which tool had faster cutover window? | | < 30 min per VM preferred |
| Did re-IP work reliably end-to-end? | | Veeam has advantage if complex |
| Did HYCU backup target add complexity? | | If yes, favor Veeam |
| Was standalone HV needed, or is AZL sufficient? | | If AZL sufficient, reduces hardware |
| Team preference after hands-on use? | | Operator comfort matters at 300-VM scale |

### Outcome Scenarios

| Outcome | Production Recommendation |
|---------|--------------------------|
| Both tools pass, HYCU faster or simpler for AHV | Use HYCU + AZL (Cell A4) |
| Both tools pass, Veeam faster or re-IP more complex | Use Veeam + StandaloneHV (Cell A1) |
| HYCU fails or has errors on AHV | Use Veeam exclusively |
| Standalone HV adds no benefit over AZL | Use AZL direct (Cells A3/A4) — reduces hardware |
| AZL staging causes capacity issues | Use Standalone HV staging (A1/A2) |
