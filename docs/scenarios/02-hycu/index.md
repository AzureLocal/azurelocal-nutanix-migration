# HYCU Migration Path

> Migrate Nutanix AHV or ESXi VMs to Azure Local using HYCU Backup & Recovery and Azure Migrate.

---

## Overview

The HYCU migration path uses a two-hop architecture:

1. **Hop 1 — HYCU**: Backs up VMs from Nutanix AHV or ESXi, then restores them to a Hyper-V staging host with automatic VHDX conversion.
2. **Hop 2 — Azure Migrate**: Discovers the staged Hyper-V VMs and migrates them to Azure Local as Azure Local VMs.

```
Nutanix AHV  ──[HYCU backup]──►  HYCU Backup Target  ──[HYCU restore]──►  Hyper-V Staging  ──[Azure Migrate]──►  Azure Local
```

## Why HYCU?

| Advantage | Details |
|-----------|---------|
| Simplest deployment | Single Linux VM on the Nutanix cluster — no Windows server, no SQL database |
| No proxy VM on AHV | Uses native AHV snapshot API directly — zero additional footprint on Nutanix |
| Web UI management | Browser-based console on port 8443 — no desktop application required |
| Agentless | No agents on source VMs |
| Purpose-built for Nutanix | Native AHV and Nutanix Files integration |

## Scenario Pages

- [Prerequisites](prerequisites.md) — Licensing, hardware, network, and account requirements
- [Architecture](architecture.md) — Detailed component diagram and data flow
- [Runbook](runbook.md) — Step-by-step migration runbook with batch pipeline
- [Validation & Checklist](validation.md) — Validation steps and pre-migration checklist

## Source Platform Support

=== "Nutanix AHV"

    HYCU is purpose-built for **Nutanix AHV**. It connects directly to the Prism Element API using native AHV snapshot APIs. No proxy VM is deployed — HYCU's controller VM communicates directly with the Nutanix cluster.

    Changed Block Tracking (CBT) is handled natively by Nutanix AHV, giving HYCU efficient incremental backups.

=== "Nutanix ESXi"

    HYCU also supports **VMware vSphere** sources (including ESXi-on-Nutanix). HYCU connects to vCenter or ESXi via the vSphere API, similar to how Veeam operates on ESXi. Backups use VMware snapshot mechanisms.

## HYCU vs. Veeam Summary

| Aspect | HYCU | Veeam |
|--------|------|-------|
| Migration workflow | Backup → Restore (two-step) | Direct live replication |
| RPO at cutover | Last incremental interval | Live replica (lower RPO) |
| Re-IP capability | Not built-in; script post-restore | Built-in re-IP rules |
| Staging storage | Backup target + Hyper-V staging | Hyper-V staging only |
| Deployment footprint | Single VM on Nutanix | Windows Server + components |

!!! tip "Start with the PoC"
    Before migrating production VMs, validate the HYCU path in the [Proof of Concept plan](../../poc/index.md) using 5–10 representative VMs.

## Alternative approaches

- Compare all three paths in the [Tool Comparison](../../overview/tool-comparison.md)
- If you want live replication and built-in re-IP, see [Veeam](../01-veeam/index.md)
- If you prefer clean-build target VMs and data/application migration, see [Deploy-First](../03-deploy-first/index.md)
