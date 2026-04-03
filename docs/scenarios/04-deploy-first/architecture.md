# Deploy-First Architecture (Carbonite Migrate)

> Agent-based OS-level replication from Nutanix source VMs into pre-provisioned Azure Local VMs.

---

## Architecture model

Deploy-First with Carbonite Migrate follows a **direct source-to-target replication model**. The target VM already exists on Azure Local when replication begins. Carbonite agents installed on both endpoints handle all changed-block tracking and replication without any hypervisor-layer dependency.

## Component diagram

![Deploy-First Carbonite architecture](../../assets/images/04-deploy-first-architecture-detailed.svg)

Draw.io source: [04-deploy-first-architecture-detailed.drawio](../../assets/diagrams/04-deploy-first-architecture-detailed.drawio)

## Architecture components

| Component | Role |
|-----------|------|
| **Nutanix AHV source VM** | Running production workload; Carbonite source agent installed |
| **Carbonite Migrate agent (source)** | Tracks and replicates changed blocks to the target |
| **Azure Local target VM** | Pre-provisioned before migration starts; Carbonite target agent installed |
| **Carbonite Migrate agent (target)** | Receives and applies replicated blocks from the source |
| **Carbonite management server** | Central console for job creation, monitoring, and cutover orchestration |

## Data flow

```
Nutanix AHV source VM
  └── Carbonite source agent
        └── TCP 6325/6326
              └── Carbonite target agent
                    └── Azure Local target VM
```

1. **Initial mirror** — Full block-level copy from source to target (runs once, typically during off-hours)
2. **Continuous replication** — Changed blocks replicated in near real-time; source remains live throughout
3. **Cutover** — Source writes stopped, final delta applied, workload execution transferred to target

## Key differences from two-hop paths

| Dimension | Veeam / HYCU / Commvault | Deploy-First (Carbonite) |
|-----------|--------------------------|--------------------------|
| Intermediate staging layer | Yes (Hyper-V host) | No — direct source to Azure Local |
| Azure Migrate required | Yes (Hop 2) | No |
| Hypervisor API dependency | Yes | No — agent-based only |
| Target VM created before migration | Not typically | Yes — always |
| Replication model | Snapshot / image | Continuous changed-block |

## Carbonite Migrate capabilities

| Capability | Detail |
|-----------|--------|
| Replication model | Continuous OS-level changed-block replication |
| Supported OS | Windows Server (all modern versions), Linux distributions |
| Hypervisor dependency | None |
| Network requirement | TCP 6325 and 6326 between source and target agents |
| Cutover model | Final sync + workload transfer; source VM held for rollback |
| Re-IP capability | Supported during or after cutover via Carbonite cutover settings |

## Diagram references

- [Deploy-First diagrams](../../diagrams/index.md#deploy-first)
- [Tool selection flow](../../overview/tool-comparison.md)
- [Alternative Migration Methods](../05-alternative-migration-methods/index.md) — SMS, Robocopy, and app-native architecture
