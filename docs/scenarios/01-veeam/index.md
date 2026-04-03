# Veeam Migration Path

> Migrate Nutanix AHV or ESXi VMs to Azure Local using Veeam Backup & Replication and Azure Migrate.

---

## Overview

The Veeam migration path uses a two-hop architecture:

1. **Hop 1 — Veeam B&R**: Replicates VMs from Nutanix (AHV or ESXi) to an on-premises Hyper-V staging host. Veeam performs live replication, keeping replicas continuously in sync with the source until cutover. Disk format is automatically converted to VHDX.
2. **Hop 2 — Azure Migrate**: Discovers the staged Hyper-V VMs and migrates them to Azure Local as Azure Local VMs.

```
Nutanix AHV/ESXi  ──[Veeam replication]──►  Hyper-V Staging  ──[Azure Migrate]──►  Azure Local
```

## Why Veeam?

| Advantage | Details |
|-----------|---------|
| Live replication | Replicas stay continuously in sync — lowest possible RPO at cutover |
| Built-in re-IP | Re-IP rules fire automatically when VMs fail over to Hyper-V |
| Batch control | Fine-grained control over which VMs replicate simultaneously |
| Mature AHV support | Native Prism API integration with automatic AHV proxy deployment |
| Existing investment | Reuses existing Veeam Universal Licenses if you already own them |

## Scenario Pages

- [Prerequisites](prerequisites.md) — Licensing, hardware, network, and account requirements
- [Architecture](architecture.md) — Detailed component diagram and data flow
- [Runbook](runbook.md) — Step-by-step migration runbook with batch pipeline
- [Validation & Checklist](validation.md) — Validation steps and pre-migration checklist

## Source Platform Variants

=== "Nutanix AHV"

    Veeam connects to **Prism Element** via HTTPS (TCP 443). It automatically deploys a temporary **AHV Backup Proxy VM** on the Nutanix cluster to handle snapshot reads and data transfer. The proxy requires 4 vCPU and 8 GB RAM on the cluster.

=== "Nutanix ESXi"

    Veeam connects to **vCenter or ESXi directly** via the vSphere API — no special Nutanix integration is needed for ESXi-on-Nutanix. Add the vCenter or ESXi host as a VMware vSphere server in Veeam. Veeam uses VMware CBT (Changed Block Tracking) for incremental replication.

## Scale Reference

This scenario is documented with a **~300 VM / 30-batch** reference scale (IIC environment). Adjust batch sizes and timeline estimates for your actual VM count.

!!! tip "Start with the PoC"
    Before migrating production VMs, validate the Veeam path in the [Proof of Concept plan](../../poc/index.md) using 5–10 representative VMs.

## Alternative approaches

- Compare all three paths in the [Tool Comparison](../../overview/tool-comparison.md)
- If you want a simpler Nutanix-native backup/restore model, see [HYCU](../02-hycu/index.md)
- If you prefer clean-build target VMs and data/application migration, see [Deploy-First](../03-deploy-first/index.md)
