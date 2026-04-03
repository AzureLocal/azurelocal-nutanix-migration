# Diagrams Gallery

> Architecture diagrams for all migration paths.

---

## Common Architecture {#common-architecture}

### Simple Two-Hop Pattern

Tool-neutral architecture for documentation overviews:

![Simple two-hop pattern](../assets/images/01-common-two-hop-architecture.svg)

Nutanix AHV/ESXi (Source) → Hyper-V Staging (Intermediate) → Azure Local (Target)

### Common Two-Hop DrawIO Source

[`diagrams/common/migration-diagrams-common-two-hop.drawio`](../assets/diagrams/migration-diagrams-common-two-hop.drawio)

### Detailed Two-Hop Architecture

![Detailed two-hop architecture](../assets/images/01-common-two-hop-architecture-detailed.svg)

[`diagrams/common/migration-diagrams-common-two-hop-detailed.drawio`](../assets/diagrams/migration-diagrams-common-two-hop-detailed.drawio)

### Migration Phases Overview

![Migration phases overview](../assets/images/05-migration-phases-overview.svg)

[`diagrams/overview/migration-diagrams-phases-overview.drawio`](../assets/diagrams/migration-diagrams-phases-overview.drawio)

### Tool Selection Flow

![Tool selection flow](../assets/images/11-tool-selection-flow-four-path.svg)

[`diagrams/overview/migration-diagrams-tool-selection-flow-four-path.drawio`](../assets/diagrams/migration-diagrams-tool-selection-flow-four-path.drawio)

---

## Veeam Migration Path {#veeam}

### Scenario page detailed architecture

![Veeam scenario detailed architecture](../assets/images/01-veeam-architecture-detailed.svg)

*Scenario-page component diagram: source Nutanix estate, Veeam B&R control plane, Hyper-V staging, Azure Migrate appliance, and Azure Local destination.*

[`diagrams/scenarios/01-veeam-architecture-detailed.drawio`](../assets/diagrams/01-veeam-architecture-detailed.drawio)

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

*Azure Migrate: appliance discovery → replication → test migration → production cutover → Azure Local VMs.*

### Veeam DrawIO Source

The editable DrawIO source for all Veeam diagrams:  
[`diagrams/veeam/migration-diagrams-veeam.drawio`](../assets/diagrams/migration-diagrams-veeam.drawio)

---

## HYCU Migration Path {#hycu}

### Scenario page detailed architecture

![HYCU scenario detailed architecture](../assets/images/02-hycu-architecture-detailed.svg)

*Scenario-page component diagram: Nutanix source estate, HYCU controller and backup target, Hyper-V restore landing zone, Azure Migrate appliance, and Azure Local destination.*

[`diagrams/scenarios/02-hycu-architecture-detailed.drawio`](../assets/diagrams/02-hycu-architecture-detailed.drawio)

### HYCU Setup Detail

![HYCU setup detail](../assets/images/03-hycu-setup-detail.png)

*HYCU controller VM on AHV, backup target, Hyper-V restore target, Azure Migrate.*

### HYCU DrawIO Source

[`diagrams/hycu/migration-diagrams-hycu.drawio`](../assets/diagrams/migration-diagrams-hycu.drawio)

---

## Commvault Migration Path {#commvault}

### Scenario page detailed architecture

![Commvault scenario detailed architecture](../assets/images/03-commvault-architecture-detailed.svg)

*Scenario-page component diagram: Nutanix source estate, Commvault control and copy layers, Hyper-V staging, Azure Migrate appliance, and Azure Local destination.*

[`diagrams/scenarios/03-commvault-architecture-detailed.drawio`](../assets/diagrams/03-commvault-architecture-detailed.drawio)

### High-Level Architecture

![Commvault high-level architecture](../assets/images/08-commvault-high-level-architecture.svg)

*Two-hop architecture: Nutanix AHV/ESXi → Commvault protected copy → Hyper-V staging → Azure Migrate → Azure Local.*

### Commvault Setup Detail

![Commvault setup detail](../assets/images/09-commvault-setup-detail.svg)

*Control plane, media or worker components, protected storage, Hyper-V staging target, and Azure Migrate handoff.*

### Commvault DrawIO Source

[`diagrams/commvault/migration-diagrams-commvault.drawio`](../assets/diagrams/migration-diagrams-commvault.drawio)

---

## Deploy-First Migration Path {#deploy-first}

### Scenario page detailed architecture

![Deploy-First scenario detailed architecture](../assets/images/04-deploy-first-architecture-detailed.svg)

*Scenario-page component diagram: build-first Azure Local target VM, direct migration methods, and no intermediate Hyper-V staging layer in the primary flow.*

[`diagrams/scenarios/04-deploy-first-architecture-detailed.drawio`](../assets/diagrams/04-deploy-first-architecture-detailed.drawio)

### Architecture Overview

The editable draw.io source (open in [app.diagrams.net](https://app.diagrams.net)):  
[`assets/diagrams/migration-diagrams-deploy-first.drawio`](../assets/diagrams/migration-diagrams-deploy-first.drawio)

**Page 1 — Architecture:** Carbonite-based OS-level replication variant inside the broader Deploy-First path. Shows source Nutanix VM → Carbonite → pre-provisioned Azure Local target VM. Contrasts with the Veeam/HYCU/Commvault two-hop pattern (no Hyper-V staging host required).

**Page 2 — Migration Steps:** Eight-step swimlane — Provision target VM, install agents, create job, initial mirror, continuous replication, test failover, cutover, validate and cleanup. Includes timeline bar and when-to-use / when-not-to-use callouts.

---

## Proof of Concept (PoC) Diagrams {#poc}

### PoC Matrix Overview

![PoC six-cell matrix](../assets/images/10-poc-six-cell-matrix.svg)

*3×2 matrix: Veeam, HYCU, and Commvault across Option A (standalone Hyper-V) and Option B (Azure Local-hosted Hyper-V).* 

[`diagrams/poc/poc-six-cell-matrix.drawio`](../assets/diagrams/poc-six-cell-matrix.drawio)

### Option A — Standalone Hyper-V

![Option A: Standalone Hyper-V](../assets/images/02-option-a-standalone-hyperv.png)

*Dedicated physical or virtual Hyper-V staging host separate from Azure Local.*

### Option B — Azure Local Direct

![Option B: Azure Local direct](../assets/images/03-option-b-azure-local-direct.png)

*Azure Local cluster node used as Hyper-V staging target — no separate hardware.*

### PoC Execution and Decision Flow

![PoC execution and decision flow](../assets/images/12-poc-execution-decision-flow-six-cell.svg)

[`diagrams/poc/poc-execution-decision-flow-six-cell.drawio`](../assets/diagrams/poc-execution-decision-flow-six-cell.drawio)

### PoC DrawIO Source

[`diagrams/poc/poc-diagrams.drawio`](../assets/diagrams/poc-diagrams.drawio)
