# Deploy-First Migration (Carbonite Migrate)

> Build the destination VM on Azure Local first, then use Carbonite Migrate to replicate the source workload directly into it.

---

> [!NOTE]
> **Scenario Overview**
> Deploy-First with Carbonite Migrate is the right choice when you need **low-downtime, agent-based OS-level replication** into a pre-provisioned Azure Local VM. Instead of relying on hypervisor-native replication or a two-hop staging path, you build the target VM first, install Carbonite agents on both endpoints, and let Carbonite drive continuous block-level replication until cutover.
>
## Overview

Deploy-First is a **build-first migration strategy**. The destination VM exists on Azure Local before any migration activity starts. Carbonite Migrate then handles OS-level replication from the Nutanix source directly to the pre-built target — no intermediate staging server, no hypervisor API dependency.

This makes it a strong fit for:

- Mixed or legacy estates where hypervisor-native migration is unavailable or impractical
- Workloads that need live cutover with minimal production downtime
- Environments where VM re-IP or OS-level state preservation is required, but the overhead of a full two-hop pipeline is not justified

## Scenario Pages

- [Prerequisites](prerequisites.md) — Carbonite licensing, management server, agent requirements, and network ports
- [Architecture](architecture.md) — Deploy-First with Carbonite component model and data flow
- [Runbook](runbook.md) — Step-by-step Carbonite Migrate execution
- [Validation & Checklist](validation.md) — Cutover validation, rollback guidance, and sign-off checklist

## Migration process at a glance

| Phase | What happens |
|-------|-------------|
| **Provision** | Target VM built and baselined on Azure Local before migration starts |
| **Agent install** | Carbonite Migrate agent installed on source Nutanix VM and target Azure Local VM |
| **Initial mirror** | Carbonite performs full block-level synchronization from source to target |
| **Continuous replication** | Changed-block replication keeps source and target in sync until cutover |
| **Cutover** | Source writes stopped, final sync completes, execution switches to target VM |
| **Validation** | Application owner validates target; source VM held for rollback window |

## When to Use This Approach

| Use Case | Why Deploy-First + Carbonite |
|----------|------------------------------|
| Low-downtime OS-level migration required | Continuous replication minimizes the cutover window |
| Hypervisor APIs unavailable or not preferred | Agent-based — no Nutanix or VMware dependency |
| Mixed OS estate across Windows and Linux | Carbonite supports both |
| VM right-sizing needed alongside migration | Target VM is provisioned with correct sizing before migration starts |
| No two-hop staging infrastructure available | Direct source-to-target path, no intermediate Hyper-V host required |

## Not Suitable For

- Workloads requiring a full hypervisor-backed snapshot or point-in-time restore model during migration
- Environments where agent installation on source VMs is not permitted (use [Veeam](../01-veeam/index.md) or [HYCU](../02-hycu/index.md) instead)
- Pure file-server or application-layer workloads where a simpler approach is preferred (see [Alternative Migration Methods](../05-alternative-migration-methods/index.md))

## Resources

- [Carbonite Migrate product documentation](https://www.carbonite.com/business/products/migrate/)
- [Tool Comparison](../../overview/tool-comparison.md)
- [Diagrams Gallery](../../diagrams/index.md#deploy-first)
- [Alternative Migration Methods](../05-alternative-migration-methods/index.md) — SMS, Robocopy, and application-native paths

## Alternative approaches

- If you need a two-hop replication path with built-in re-IP, see [Veeam](../01-veeam/index.md)
- If you want a simpler Nutanix-native backup/restore workflow, see [HYCU](../02-hycu/index.md)
- If you want to stay inside an existing Commvault operating model, see [Commvault](../03-commvault/index.md)
- For file-server or app-native migration without Carbonite, see [Alternative Migration Methods](../05-alternative-migration-methods/index.md)
