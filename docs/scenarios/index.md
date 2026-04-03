# Migration Scenarios

> Choose the migration path that best fits your source platform, operating model, and cutover requirements.

---

## Choose your path

This repository currently supports **three primary migration paths**:

<div class="grid cards" markdown>

- **Veeam Migration Path**

    Best when you need live replication, built-in re-IP, and strong control over large migration waves.

    [:octicons-arrow-right-24: Open Veeam Path](01-veeam/index.md)

- **HYCU Migration Path**

    Best when you want a Nutanix-native, backup/restore workflow with a simpler operating model.

    [:octicons-arrow-right-24: Open HYCU Path](02-hycu/index.md)

- **Deploy-First Migration**

    Best when you want to build fresh Azure Local VMs and migrate data, application state, or OS-level state into them.

    [:octicons-arrow-right-24: Open Deploy-First Path](03-deploy-first/index.md)

</div>

## Path families

| Path family | Included paths | Core idea | Best for |
|-------------|----------------|-----------|----------|
| **Replication-first / two-hop** | Veeam, HYCU | Move source VMs to Hyper-V staging first, then use Azure Migrate for Hop 2 | Like-for-like VM moves where you want a defined staging checkpoint |
| **Build-first / deploy-first** | Deploy-First | Provision new Azure Local VMs first, then migrate data, app state, or use Carbonite for OS-level replication | Modernization, right-sizing, OS refresh, file/data-centric workloads |

## Quick decision guide

| If your priority is... | Start with... |
|------------------------|---------------|
| Lowest downtime and strong re-IP control | [Veeam](01-veeam/index.md) |
| Simplest Nutanix-native operations | [HYCU](02-hycu/index.md) |
| Clean rebuilds, data-only migration, or hypervisor-independent replication | [Deploy-First](03-deploy-first/index.md) |

## Recommended reading order

1. Review the [Tool Comparison](../overview/tool-comparison.md)
2. Open the scenario that best matches your operating model
3. Read that scenario in order: Overview → Prerequisites → Architecture → Runbook → Validation
4. Validate assumptions through the [Proof of Concept plan](../poc/index.md) before production rollout

## Visual decision support

- [Tool selection flow](../overview/tool-comparison.md) — decision flowchart for selecting Veeam, HYCU, or Carbonite/deploy-first
- [Common architecture diagrams](../diagrams/index.md#common-architecture) — two-hop pattern, migration phases, and selection visuals

!!! note "Current focus of this repo"
    The current documented focus is:

    - **Veeam** as a two-hop replication path
    - **HYCU** as a two-hop backup/restore path
    - **Deploy-First** as a build-first path that includes data migration methods and Carbonite as an agent-based option

    Unsupported or removed paths such as direct Azure Migrate from AHV and Zerto are intentionally excluded.