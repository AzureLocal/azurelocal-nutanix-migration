# Deploy-First Migration

> Deploy new VMs directly on Azure Local, then migrate data from Nutanix source VMs.

---

!!! note "Scenario Overview"
    This scenario is the right choice when you want **clean, right-sized, modern VMs** on Azure Local rather than a like-for-like copy of your Nutanix VMs. Instead of replicating an existing VM image, you build new VMs from scratch and migrate only the **data and application state**.

## Overview

Deploy-First is a **build-first migration strategy**, not a two-hop replication pipeline. You provision the destination VM on Azure Local first, then choose the most appropriate migration method for the workload:

- **File/data migration** for file servers and content-heavy workloads
- **Application-native migration** for SQL, IIS, and Linux/database workloads
- **Carbonite Migrate** when you want agent-based OS-level replication into a pre-built target VM

## Scenario Pages

- [Prerequisites](prerequisites.md) — Common readiness requirements, network needs, and tool-specific prerequisites
- [Architecture](architecture.md) — Build-first variants and decision model
- [Runbook](runbook.md) — Step-by-step workflows for SMS/Robocopy, application-native migration, and Carbonite
- [Validation & Checklist](validation.md) — Validation, rollback, and sign-off guidance

## Path variants

| Variant | Best for | Migration layer | Typical tools |
|---------|----------|-----------------|---------------|
| **File/data migration** | File servers, content repositories, stateless content hosts | Data layer | SMS, Robocopy, rsync |
| **Application-native migration** | SQL Server, IIS, Linux app/database stacks | Application layer | SQL backup/restore, app export/import, native DB tools |
| **Carbonite Migrate** | Mixed or legacy estates requiring low-downtime OS-level move | OS layer | Carbonite Migrate |

## When to Use This Approach

| Use Case | Why Deploy-First |
|----------|-----------------|
| VMs running outdated OS (Server 2012/2016) | Good opportunity to refresh OS while migrating |
| VM was over-provisioned on Nutanix | Right-size CPU/RAM at migration time |
| Stateless or easily rebuilt workloads | Fastest path — just redeploy and repoint |
| Large file servers | Use Storage Migration Service (SMS) for clean data migration |
| SQL or app workloads | Use in-app migration tools (SQL backup/restore, DFS, etc.) |

## Not Suitable For

- VMs where the exact OS state must be preserved (use Veeam or HYCU instead)
- VMs with complex application state that cannot be easily migrated via data transfer

## Common execution pattern

1. Provision and baseline the new Azure Local VM
2. Install the required OS and supporting software on the target
3. Select the correct migration method for the workload type
4. Migrate data, application state, or OS state
5. Perform cutover and validation
6. Decommission or archive the Nutanix source after the hold period

## Resources

- [Storage Migration Service overview](https://learn.microsoft.com/en-us/windows-server/storage/storage-migration-service/overview)
- [Tool Comparison](../../overview/tool-comparison.md)
- [Diagrams Gallery](../../diagrams/index.md#deploy-first)

## Alternative approaches

- If you need a two-hop replication path with built-in re-IP, see [Veeam](../01-veeam/index.md)
- If you want a simpler Nutanix-native backup/restore workflow, see [HYCU](../02-hycu/index.md)
