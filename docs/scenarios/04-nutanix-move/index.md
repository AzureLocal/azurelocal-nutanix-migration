# Nutanix Move Migration

> Migrate Nutanix AHV VMs directly to Hyper-V / Azure Local using Nutanix Move.

---

!!! note "Scenario Overview"
    **Nutanix Move** is a free migration tool from Nutanix that can migrate AHV VMs directly to Hyper-V (and to other hypervisors). It handles disk conversion (AHV → VHDX) and optional IP/hostname changes at cutover — all from a single appliance VM deployed on the source cluster.

## When to Use Nutanix Move

| Scenario | Why Nutanix Move |
|----------|-----------------|
| AHV source only (not ESXi-on-Nutanix) | Nutanix Move is purpose-built for AHV migrations |
| No existing Veeam or HYCU license | Nutanix Move is free (included with Nutanix support) |
| Smaller VM counts (< 50) | Simpler tooling without a full backup infrastructure |
| Faster time-to-value | Minimal infrastructure prerequisites |

## Limitations

- **AHV to Hyper-V only** — Nutanix Move does not support ESXi-on-Nutanix as a source for Hyper-V targets
- **Direct migration** — no separate backup target; if the migration fails, roll back by powering on source VMs
- **Concurrency limits** — typically 5–10 concurrent VM migrations per Move appliance
- Nutanix Move migrates to Hyper-V; Azure Migrate is still required for Hop 2 (HV → Azure Local)

## High-Level Architecture

```
Nutanix AHV  ──[Nutanix Move replication]──►  Hyper-V Staging  ──[Azure Migrate]──►  Azure Local
```

Nutanix Move operates similar to Veeam in concept, but uses Nutanix's own internal APIs for AHV snapshotting. The Move appliance VM is deployed on the Nutanix cluster.

## Nutanix Move Migration Steps

1. **Deploy Move appliance VM** on the Nutanix AHV cluster (download from Nutanix portal)
2. **Add source**: Add the Nutanix AHV cluster as a Move migration source
3. **Add target**: Add the Hyper-V staging host as a Move migration target
4. **Create migration plan**: Select source VMs, map to Hyper-V target, configure networking
5. **Start seed migration**: Move syncs VM data in the background (initial seed + incrementals)
6. **Cutover**: During maintenance window, trigger cutover from Move console — source VM powers off, final sync occurs, Hyper-V VM powers on
7. **Azure Migrate (Hop 2)**: Same as all other scenarios — Azure Migrate discovers VMs on Hyper-V and migrates to Azure Local

## Resources

- [Nutanix Move documentation](https://portal.nutanix.com/page/documents/list?type=software&filterKey=software&filterVal=Move)
- Automation scripts: `src/04-nutanix-move/`

## Status

> Detailed runbook, prerequisites, and architecture pages planned for a future release. The Azure Migrate (Hop 2) steps are identical to the Veeam path — see [Veeam Runbook — Section 4+](../01-veeam/runbook.md#section-4) for Azure Migrate details.
