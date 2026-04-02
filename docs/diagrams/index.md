# Diagrams Gallery

> Architecture diagrams for all migration paths.

---

## Veeam Migration Path {#veeam}

### High-Level Architecture

![Veeam high-level architecture](../assets/images/01-high-level-architecture.png)

*Two-hop architecture: Nutanix AHV/ESXi → Veeam replication → Hyper-V staging → Azure Migrate → Azure Local.*

### Batch Pipeline Flow

![Veeam batch pipeline flow](../assets/images/02-batch-pipeline-flow.png)

*Sequential batch execution — 10 VMs per batch, Hop 1 cutover before Hop 2 begins.*

### Veeam Setup Detail

![Veeam setup detail](../assets/images/03-veeam-setup-detail.png)

*Detailed component diagram: Veeam server, AHV proxy VM, replication jobs, Hyper-V target.*

### Azure Migrate Workflow

![Azure Migrate workflow](../assets/images/04-azure-migrate-workflow.png)

*Azure Migrate: appliance discovery → replication → test migration → production cutover → Arc-managed VMs.*

### Veeam DrawIO Source

The editable DrawIO source for all Veeam diagrams:  
[`diagrams/veeam/migration-diagrams-veeam.drawio`](../assets/diagrams/migration-diagrams-veeam.drawio)

---

## HYCU Migration Path {#hycu}

### HYCU Setup Detail

![HYCU setup detail](../assets/images/03-hycu-setup-detail.png)

*HYCU controller VM on AHV, backup target, Hyper-V restore target, Azure Migrate.*

### HYCU DrawIO Source

[`diagrams/hycu/migration-diagrams-hycu.drawio`](../assets/diagrams/migration-diagrams-hycu.drawio)

---

## Proof of Concept (PoC) Diagrams {#poc}

### PoC Overview — Both Options

![PoC overview both options](../assets/images/01-poc-overview-both-options.png)

*2×2 matrix: Veeam/HYCU × Option A (standalone HV) / Option B (Azure Local direct).*

### Option A — Standalone Hyper-V

![Option A: Standalone Hyper-V](../assets/images/02-option-a-standalone-hyperv.png)

*Dedicated physical or virtual Hyper-V staging host separate from Azure Local.*

### Option B — Azure Local Direct

![Option B: Azure Local direct](../assets/images/03-option-b-azure-local-direct.png)

*Azure Local cluster node used as Hyper-V staging target — no separate hardware.*

### PoC Timeline and Decision

![PoC timeline and decision](../assets/images/04-poc-timeline-and-decision.png)

*Four-week PoC timeline with decision gates at the end of each cell.*

### PoC DrawIO Source

[`diagrams/poc/poc-diagrams.drawio`](../assets/diagrams/poc-diagrams.drawio)
