# Commvault Migration Path

> Migrate Nutanix AHV or ESXi VMs to Azure Local using Commvault for Hop 1 and Azure Migrate for Hop 2.

---

> [!NOTE]
> **Planning assumption for this path**
> This documentation models Commvault as a **two-hop path**: protect or copy Nutanix workloads with Commvault, restore them to Hyper-V staging as VHDX-backed VMs, then use Azure Migrate to complete the move to Azure Local. Validate the exact workflow against your Commvault release, licensed modules, and Nutanix integration before production use.
>
## Overview

The Commvault migration path uses a two-hop architecture:

1. **Hop 1 — Commvault**: Protects Nutanix workloads and restores them to a Hyper-V staging host. In this documentation, Commvault is used as the policy-driven control plane for staging and recovery.
2. **Hop 2 — Azure Migrate**: Discovers the staged Hyper-V VMs and migrates them to Azure Local as Azure Local VMs.

```
Nutanix AHV/ESXi  ──[Commvault protect/copy]──►  Commvault Storage  ──[Restore to Hyper-V]──►  Hyper-V Staging  ──[Azure Migrate]──►  Azure Local
```

## Why Commvault?

| Advantage | Details |
|-----------|---------|
| Existing investment | Reuse an existing Commvault estate instead of introducing another Hop 1 platform |
| Centralized policy model | Job policies, reporting, and governance stay inside one operational toolset |
| Mixed-source flexibility | One platform can support AHV and ESXi-based source estates when configured appropriately |
| Recovery-led migration | Teams already comfortable with restore workflows can reuse that operating model for migration staging |
| Enterprise controls | Useful where change control, auditing, and role separation are already built around Commvault |

## Scenario Pages

- [Prerequisites](prerequisites.md) — Licensing, component, storage, and connectivity requirements
- [Architecture](architecture.md) — Detailed component diagram and data flow
- [Runbook](runbook.md) — Step-by-step migration workflow for staged restore and Azure Migrate cutover
- [Validation & Checklist](validation.md) — Validation steps and rollback guidance

## Source Platform Variants

=== "Nutanix AHV"

    Use the Nutanix integration supported by your Commvault release to discover and protect AHV VMs. Validate required Prism connectivity, snapshot behavior, and the exact restore workflow to Hyper-V before production rollout.

=== "Nutanix ESXi"

    For ESXi-on-Nutanix, Commvault can follow the VMware integration path through vCenter or ESXi. Validate CBT, snapshot handling, and restore-to-Hyper-V behavior in the PoC before large-scale execution.

## Scale Reference

This path should be validated with the same batch-oriented discipline used for the other two-hop scenarios. Start with a small wave, confirm storage, restore time, and Azure Migrate behavior, then size batch concurrency for the full program.

> [!TIP]
> **Start with the PoC**
> Before migrating production VMs, validate the Commvault path with a representative pilot set and confirm your release-specific workflow.
>
## Alternative approaches

- Compare all four paths in the [Tool Comparison](../../overview/tool-comparison.md)
- If you need built-in re-IP and lower-RPO live replication, see [Veeam](../01-veeam/index.md)
- If you want a simpler Nutanix-native backup and restore model, see [HYCU](../02-hycu/index.md)
- If you prefer clean-build target VMs and selective data migration, see [Deploy-First](../04-deploy-first/index.md)
