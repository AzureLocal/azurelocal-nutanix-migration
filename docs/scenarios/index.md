# Migration Scenarios

> Choose the migration path that best fits your source platform, operating model, and cutover requirements.

---

## Choose your path

This repository currently supports **five migration paths**:

<div class="grid cards" markdown>

- **Veeam Migration Path**

    Best when you need live replication, built-in re-IP, and strong control over large migration waves.

    [:octicons-arrow-right-24: Open Veeam Path](01-veeam/index.md)

- **HYCU Migration Path**

    Best when you want a Nutanix-native, backup/restore workflow with a simpler operating model.

    [:octicons-arrow-right-24: Open HYCU Path](02-hycu/index.md)

- **Commvault Migration Path**

    Best when you already operate Commvault and want a policy-driven two-hop workflow that reuses that platform for Hop 1.

    [:octicons-arrow-right-24: Open Commvault Path](03-commvault/index.md)

- **Deploy-First (Carbonite Migrate)**

    Best when you want to provision fresh Azure Local VMs and use Carbonite Migrate for low-downtime agent-based OS-level replication directly into them.

    [:octicons-arrow-right-24: Open Deploy-First Path](04-deploy-first/index.md)

- **Alternative Migration Methods**

    File-server and application-native migration for deploy-first workloads where OS-level replication is not required (SMS, Robocopy, SQL backup/restore, IIS, Linux rsync).

    [:octicons-arrow-right-24: Open Alternative Methods](05-alternative-migration-methods/index.md)

</div>

Opening one of the paths above takes you into that product's own documentation section, where the left navigation is limited to that path's pages.

## Path families

| Path family | Included paths | Core idea | Best for |
|-------------|----------------|-----------|----------|
| **Replication-first / two-hop** | Veeam, HYCU, Commvault | Move source VMs to Hyper-V staging first, then use Azure Migrate for Hop 2 | Like-for-like VM moves where you want a defined staging checkpoint |
| **Deploy-first / Carbonite** | Deploy-First | Provision new Azure Local VMs first, then use Carbonite Migrate for agent-based OS-level replication | Workloads requiring low-downtime migration without hypervisor-native tooling |
| **Deploy-first / lightweight** | Alternative Migration Methods | Provision new Azure Local VMs first, then migrate only data or application state | File servers, SQL, IIS, and Linux workloads with clean export/import paths |

## Quick decision guide

| If your priority is... | Start with... |
|------------------------|---------------|
| Lowest downtime and strong re-IP control | [Veeam](01-veeam/index.md) |
| Simplest Nutanix-native operations | [HYCU](02-hycu/index.md) |
| Existing Commvault investment and centralized policy-driven operations | [Commvault](03-commvault/index.md) |
| Low-downtime OS-level migration without hypervisor APIs (agent-based) | [Deploy-First with Carbonite](04-deploy-first/index.md) |
| File-server, SQL, IIS, or Linux workloads with simple export/import paths | [Alternative Migration Methods](05-alternative-migration-methods/index.md) |

## Recommended reading order

1. Review the [Tool Comparison](../overview/tool-comparison.md)
2. Open the scenario that best matches your operating model
3. Read that scenario in order: Overview → Prerequisites → Architecture → Runbook → Validation
4. Validate assumptions through the [Proof of Concept plan](../poc/index.md) before production rollout

## Visual decision support

- [Tool selection flow](../overview/tool-comparison.md) — decision flowchart for selecting Veeam, HYCU, Commvault, or Deploy-First/Carbonite
- [Common architecture diagrams](../diagrams/index.md#common-architecture) — two-hop pattern, migration phases, and selection visuals

> [!NOTE]
> **Current focus of this repo**
> The current documented focus is:
>
> - **Veeam** as a two-hop replication path
> - **HYCU** as a two-hop backup/restore path
> - **Commvault** as a two-hop policy-driven protection and restore path
> - **Deploy-First** as a build-first path that includes data migration methods and Carbonite as an agent-based option
>
> Unsupported or removed paths such as direct Azure Migrate from AHV and Zerto are intentionally excluded.
