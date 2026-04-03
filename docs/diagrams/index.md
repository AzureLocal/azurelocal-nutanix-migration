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

![Tool selection flow](../assets/images/06-tool-selection-flow.svg)

[`diagrams/overview/migration-diagrams-tool-selection-flow.drawio`](../assets/diagrams/migration-diagrams-tool-selection-flow.drawio)

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

*Azure Migrate: appliance discovery → replication → test migration → production cutover → Azure Local VMs.*

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

## Deploy-First Migration Path {#deploy-first}

### Architecture Overview

The editable draw.io source (open in [app.diagrams.net](https://app.diagrams.net)):  
[`assets/diagrams/migration-diagrams-deploy-first.drawio`](../assets/diagrams/migration-diagrams-deploy-first.drawio)

**Page 1 — Architecture:** Source Nutanix AHV cluster with Carbonite agents → continuous replication → pre-provisioned target VMs on Azure Local. Shows initial mirror, delta sync, and cutover flows. Contrasts with the Veeam/HYCU two-hop (no Hyper-V staging host required).

**Page 2 — Migration Steps:** Eight-step swimlane — Provision target VM, install agents, create job, initial mirror, continuous replication, test failover, cutover, validate and cleanup. Includes timeline bar and when-to-use / when-not-to-use callouts.

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
