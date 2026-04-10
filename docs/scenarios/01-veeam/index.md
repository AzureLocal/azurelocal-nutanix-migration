# Veeam Migration Path

> Migrate Nutanix AHV or ESXi VMs to Azure Local using Veeam Backup & Replication and Azure Migrate.

---

## Overview

The Veeam migration path uses a two-hop architecture:

1. **Hop 1 — Veeam B&R**:
    - **AHV source**: Backs up VMs from Nutanix AHV to a Veeam backup repository, then uses Instant Recovery or full restore to Hyper-V. Disk format is automatically converted to VHDX. Frequent incrementals keep backups current; Instant Recovery to Hyper-V can bring a VM up within 15–30 minutes of source shutdown.
    - **ESXi source**: Replicates VMs directly to the Hyper-V staging host using VMware CBT. The Hyper-V replica stays continuously in sync until cutover — true live replication with the lowest possible RPO.
2. **Hop 2 — Azure Migrate**: Discovers the Hyper-V VMs on staging and replicates them to Azure Local using the Azure Migrate for Azure Local appliance pair. Currently in Preview for Azure Local 2503+.

```
Nutanix AHV   ──[Veeam backup + Instant Recovery]──►  Hyper-V Staging  ──[Azure Migrate]──►  Azure Local
Nutanix ESXi  ──[Veeam live replication]           ──►  Hyper-V Staging  ──[Azure Migrate]──►  Azure Local
```

!!! info "Expected downtime per VM"
    **Hop 1 AHV (Instant Recovery path):** 15–30 minutes per VM (source shutdown → VM live on Hyper-V).
    **Hop 1 AHV (Full Restore path):** 1–4 hours per VM depending on size and storage throughput.
    **Hop 1 ESXi (Replication):** 15–30 minutes per batch (final delta sync + failover).
    **Hop 2 (Azure Migrate cutover):** 30–60 minutes per batch of 10 VMs (final delta + Azure Local VM creation).

## Why Veeam?

| Advantage | Details |
|-----------|---------|
| Instant Recovery to Hyper-V (AHV) | AHV VMs can be running on Hyper-V within 15–30 min of source shutdown using Instant Recovery |
| Live replication (ESXi) | ESXi replicas stay continuously in sync — lowest possible RPO at cutover |
| Built-in re-IP | Re-IP rules fire automatically when VMs fail over to Hyper-V (ESXi) or post-restore (AHV) |
| Batch control | Fine-grained control over which VMs are processed simultaneously |
| Integrated AHV plugin | Native Prism API integration built into Veeam B&R v12.2+ — no separate installer |
| Existing investment | Reuses Veeam Data Platform VUL instances if you already own them |

## Scenario Pages

- [Prerequisites](prerequisites.md) — Licensing, hardware, network, and account requirements
- [Architecture](architecture.md) — Detailed component diagram and data flow
- [Runbook](runbook.md) — Step-by-step migration runbook with batch pipeline
- [Validation & Checklist](validation.md) — Validation steps and pre-migration checklist

## Source Platform Variants

=== "Nutanix AHV"

    Veeam connects to **Prism Element or Prism Central** via HTTPS (TCP **9440**). Starting with Veeam B&R 12.2, the AHV plug-in is integrated — no separate installer needed. Veeam deploys a **Worker VM** on the Nutanix cluster (default: 6 vCPU, 6 GB RAM, 100 GB disk) to process backup workloads. Requires Nutanix AOS **6.8.1.6 or later**.

    The Hop 1 migration mechanism for AHV is **backup-based**: Veeam creates application-consistent backups with frequent incrementals. At cutover, you use **Instant Recovery to Hyper-V** (VM up in ~15 min, data migrated in background) or **Full VM Restore to Hyper-V** (slower but immediately on local HV storage).

=== "Nutanix ESXi"

    Veeam connects to **vCenter or ESXi directly** via the vSphere API — no special Nutanix integration is needed for ESXi-on-Nutanix. Add the vCenter or ESXi host as a VMware vSphere server in Veeam. Veeam uses VMware CBT (Changed Block Tracking) for incremental replication.

## Scale Reference

This scenario is documented with a **~300 VM / 30-batch** reference scale (IIC environment). Adjust batch sizes and timeline estimates for your actual VM count.

!!! tip "Start with the PoC"
    Before migrating production VMs, validate the Veeam path in the [Proof of Concept plan](../../poc/index.md) using 5–10 representative VMs.

## Alternative approaches

- Compare all four paths in the [Tool Comparison](../../overview/tool-comparison.md)
- If you want a simpler Nutanix-native backup/restore model, see [HYCU](../02-hycu/index.md)
- If you already standardize on Commvault, see [Commvault](../03-commvault/index.md)
- If you prefer clean-build target VMs and data/application migration, see [Deploy-First](../04-deploy-first/index.md)
