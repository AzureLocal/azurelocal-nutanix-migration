# Proof of Concept (PoC) Plan

> Validate your chosen migration path before committing to a full production migration.

---

## Choose Your PoC Scenario

Not every organisation needs a 5-week, three-tool evaluation. Pick the scenario that matches your situation:

| Scenario | Best For | VMs | Duration | Tools Tested |
|----------|----------|-----|----------|--------------|
| [**1 — Single-Tool Quick PoC**](#scenario-1-single-tool-quick-poc) | You already know which tool you're using (e.g., Veeam is already licensed). Just validate the end-to-end process works in your environment. | 3–5 | ~1 week | 1 tool |
| [**2 — Two-Tool Comparison PoC**](#scenario-2-two-tool-comparison-poc) | Deciding between two options (e.g., Veeam vs HYCU). Run the same workload set through both to compare results side-by-side. | 5–10 | 2–3 weeks | 2 tools |
| [**3 — Full Three-Tool Evaluation**](#scenario-3-full-three-tool-evaluation) | Open tool selection with no incumbent. Full comparison across all three paths and both staging options. | 15 | 4–5 weeks | 3 tools |

> [!TIP]
> **When in doubt, start with Scenario 1**
> Running any single-tool PoC first gives you real timing baselines and surface-level confidence before expanding scope. If issues arise, it's far cheaper to discover them with 5 VMs than mid-production.
>
---

## Scenario 1 — Single-Tool Quick PoC

Use this when you already have a tool in mind and just need to validate the two-hop process end-to-end before production.

### Scope

| Item | Value |
|------|-------|
| VMs | 3–5 representative VMs (include at least 1 Windows, 1 Linux, 1 stateful/database) |
| Tool | One of: Veeam, HYCU, or Carbonite (Deploy-First) |
| Staging option | One of: Standalone Hyper-V (Option A) or Azure Local-hosted Hyper-V (Option B) — not both |
| Duration | ~5 business days (see [1-Week Timeline](timeline.md#1-week-single-tool-poc)) |

### Entry Criteria

- [ ] Tool pilot environment deployed and licensed for at least 5 VMs
- [ ] Azure Local target capacity confirmed
- [ ] Azure Migrate project and source appliance deployed (not needed for Carbonite path)
- [ ] 3–5 PoC VMs selected — approved by infra and app owners
- [ ] Rollback owner assigned for each VM

### Exit Criteria

- [ ] All selected VMs migrated end-to-end (Hop 1 + Hop 2) with no unresolved failures
- [ ] Timing baselines recorded: full backup/replication time, cutover time per VM, Hop 2 Azure Migrate cutover time
- [ ] At least one rollback drill completed and documented
- [ ] Go/No-Go decision signed — proceed to production waves or escalate issues

### What You Learn

- Whether the tool works cleanly in your specific source environment (AHV, ESXi, guest OS mix)
- Real per-VM timing for your storage and network configuration
- Re-IP / DNS change reliability for your AD and network layout
- Any environment-specific blockers (firewall rules, AOS version, BitLocker, etc.) before they hit production

---

## Scenario 2 — Two-Tool Comparison PoC

Use this when you are deciding between two migration tools and want objective side-by-side evidence.

### Scope

| Item | Value |
|------|-------|
| VMs | 5–10 representative VMs (5 per tool, **same workload set** used for both tools for a fair comparison) |
| Tools | Two of: Veeam + HYCU (most common), Veeam + Carbonite, or HYCU + Carbonite |
| Staging option | Use the **same staging option for both tools** — do not mix Option A and Option B or results will not be comparable |
| Duration | 2–3 weeks (see [3-Week Timeline](timeline.md#3-week-two-tool-comparison)) |

> [!NOTE]
> **Carbonite comparison note**
> Carbonite (Deploy-First) does **not** use a Hyper-V staging hop — it replicates directly from Nutanix to Azure Local. When comparing Carbonite against Veeam or HYCU, you are comparing different architectures, not just different tools. That is a valid comparison, but frame the evaluation accordingly: Carbonite trades the staging flexibility for potentially lower downtime and fewer moving parts.
>
### Entry Criteria

- [ ] Both tool environments deployed and licensed
- [ ] Azure Local target capacity confirmed for both tool workloads
- [ ] Azure Migrate project and source appliance deployed (for Veeam/HYCU paths)
- [ ] 5 PoC VMs per tool selected from the same workload archetypes (see [VM Selection](test-matrix.md#vm-selection))
- [ ] Staging option confirmed (must be the same for both tools for valid comparison)
- [ ] Rollback owners assigned

### Exit Criteria

- [ ] Both tools tested end-to-end with the same 5-VM workload set
- [ ] Comparison scorecard completed (see [Comparison Metrics](test-matrix.md#comparison-metrics))
- [ ] One rollback drill per tool documented
- [ ] Tool recommendation agreed by infra and app leads, signed
- [ ] Production wave plan drafted for the selected tool

### Scorecard Decision Criteria

Weight each criterion based on your organisation's priorities:

| Criterion | Veeam | HYCU | Carbonite | Weight |
|-----------|-------|------|-----------|--------|
| Migration success rate | | | | High |
| Initial copy speed | | | | Medium |
| Cutover downtime per VM | | | | High |
| Tooling complexity / operator skill | | | | Medium |
| Licensing cost per VM | | | | High |
| Re-IP reliability | | | | Medium |
| Rollback speed and simplicity | | | | High |
| Existing team familiarity | | | | Low |

---

## Scenario 3 — Full Three-Tool Evaluation

Use this when no tool is pre-selected, the organisation is open to any path, and a formal evaluation with documented evidence is required (e.g., for procurement or board approval).

This is the original full 3×2 matrix approach.

![PoC six-cell matrix](../assets/images/10-poc-six-cell-matrix.svg)

Draw.io source: [poc-six-cell-matrix.drawio](../assets/diagrams/poc-six-cell-matrix.drawio)

![PoC execution and decision flow](../assets/images/12-poc-execution-decision-flow-six-cell.svg)

Draw.io source: [poc-execution-decision-flow-six-cell.drawio](../assets/diagrams/poc-execution-decision-flow-six-cell.drawio)

### PoC Matrix (3 × 2)

|  | **Option A — Standalone Hyper-V Staging** | **Option B — Azure Local-hosted Hyper-V** |
|--|------------------------------------------|-------------------------------------------|
| **Veeam** | Cell **A1** — Veeam → Standalone HV → Azure Migrate → Azure Local | Cell **B1** — Veeam → Azure Local-hosted HV → Azure Migrate |
| **HYCU** | Cell **A2** — HYCU → Standalone HV → Azure Migrate → Azure Local | Cell **B2** — HYCU → Azure Local-hosted HV → Azure Migrate |
| **Carbonite** | Cell **A3** — Carbonite → direct to Azure Local (no staging hop) | Cell **B3** — same as A3; Carbonite has no staging option variable |

> [!NOTE]
> **Carbonite cells in the full matrix**
> Because Carbonite (Deploy-First) replicates directly from source to Azure Local, Cells A3 and B3 are effectively the same test. Run it once and record it in both columns. Use the second Carbonite run to test a different workload archetype or re-test under different load conditions.
>
Each cell = **5 VMs**. The same 5-VM workload set per tool is reused across Option A and Option B so staging differences can be compared cleanly.

See the [Test Matrix](test-matrix.md) for the full breakdown of what is tested in each cell.

### Full Evaluation Scope

| Item | Value |
|------|-------|
| Total VMs | 15 representative VMs (5 per tool, reused across both staging options) |
| Environments | Nutanix AHV or ESXi source estate in the IIC datacenter |
| Tools tested | Veeam Backup & Replication, HYCU Backup & Recovery, and Carbonite Migrate (Deploy-First) |
| Staging options | Standalone Hyper-V (Option A) and Azure Local-hosted Hyper-V (Option B) for two-hop tools |
| Duration | 4–5 weeks (see [Full Evaluation Timeline](timeline.md#full-evaluation-timeline)) |
| Success threshold | All cells executed with evidence, decision scorecard completed, and one production path selected |

### Entry and Exit Criteria

| Gate | Criteria |
|------|----------|
| **Entry criteria (start PoC)** | 1) All three tool environments deployed and licensed, 2) Azure Local target capacity confirmed, 3) Azure Migrate project/appliance healthy, 4) 15 PoC VMs selected and approved, 5) rollback owners assigned |
| **Exit criteria (complete PoC)** | 1) All cells executed with evidence, 2) weighted scorecard completed, 3) risks and mitigations updated, 4) Go/No-Go decision signed by infra + app owners |

## What the PoC Measures

These apply to all three scenarios — scale the number of data points collected to match scope:

1. **Migration fidelity** — Do VMs boot cleanly? Are data and applications intact?
2. **Migration speed** — Full backup/replication time, incremental time, cutover time per VM
3. **Tooling complexity** — Is setup and operation straightforward for your team?
4. **Re-IP process** — Does IP/DNS change work reliably for each tool in your AD/network layout?
5. **Failure rate** — How often do jobs fail and how easily do they recover?
6. **Rollback confidence** — Can you get a VM back to Nutanix inside the agreed window?

## PoC Success Criteria

| Metric | Pass Threshold |
|--------|---------------|
| VM migration success rate | ≥ 95% (no data corruption, boots clean) |
| Initial full replication/backup time | ≤ 12 hours per 5-VM batch |
| Cutover window (per VM) | ≤ 30 minutes including IP/DNS change |
| Rollback time (per VM) | ≤ 15 minutes back to live on Nutanix |
| Application smoke test | Pass on all validated VMs |

## PoC Risk Register (initial)

| Risk | Probability | Impact | Mitigation | Owner |
|------|-------------|--------|------------|-------|
| Staging storage fills during full sync | Medium | High | Pre-calculate required space + 30% headroom; stop-wave threshold | Infra lead |
| Re-IP/DNS errors at cutover | Medium | High | Pre-stage IP mapping + low TTL + validation script | Network lead |
| Azure Migrate replication lag | Medium | Medium | Start replication earlier; monitor protection state before cutover | Migration lead |
| Carbonite replication lag before cutover | Low | Medium | Monitor delta queue continuously; only cut over when lag < 60 seconds | Migration lead |
| App-level validation misses hidden dependency | Low | High | Dependency checklist + app-owner test scripts per VM | App owner |
| Tool instability in one cell | Low | Medium | Auto-fail gate + rerun rule + vendor support escalation | PoC manager |
| Azure Migrate for Azure Local still in Preview | Medium | Medium | Confirm Azure Local 2503+ is deployed; test migration (not production cutover) first | Infra lead |

## Required PoC Deliverables

Deliverables scale with scenario — collect at minimum what is marked for your chosen scenario:

| Deliverable | Scenario 1 | Scenario 2 | Scenario 3 |
|-------------|:----------:|:----------:|:----------:|
| Per-VM gate checklist | ✅ | ✅ | ✅ |
| Timing measurements (full copy, incremental, cutover) | ✅ | ✅ | ✅ |
| One rollback drill with documented duration | ✅ | ✅ | ✅ |
| Evidence pack (screenshots/logs) | Optional | ✅ | ✅ |
| Side-by-side comparison scorecard | — | ✅ | ✅ |
| Risk register with final status | — | ✅ | ✅ |
| Full recommendation deck | — | Optional | ✅ |
| Signed Go/No-Go record | ✅ | ✅ | ✅ |

## Quick Links

- [Test Matrix](test-matrix.md) — test cells, VM selection, what each validates
- [Timeline](timeline.md) — week-by-week execution plan
- [Decision Framework](timeline.md#decision-framework) — how to choose based on PoC results
- [PoC execution flow diagram](../diagrams/index.md#poc) — visual flow and decision gates
