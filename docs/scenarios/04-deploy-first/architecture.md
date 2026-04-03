# Deploy-First Architecture

> Build-first migration patterns for Azure Local where the destination VM exists before migration starts.

---

## Architecture model

Deploy-First differs from Veeam and HYCU in one important way: **the target VM is created first**. Migration methods then move either data, application state, or full OS state into that pre-built destination.

## Component diagram

![Deploy-First detailed architecture](../../assets/images/04-deploy-first-architecture-detailed.svg)

Draw.io source: [04-deploy-first-architecture-detailed.drawio](../../assets/diagrams/04-deploy-first-architecture-detailed.drawio)

## Architecture variants

| Variant | Source | Target | Data path | Best fit |
|---------|--------|--------|-----------|----------|
| **File / data migration** | Nutanix VM | Pre-built Azure Local VM | File copy or file-service orchestration | File servers, content repositories |
| **Application-native migration** | Nutanix VM | Pre-built Azure Local VM | App/database export/import or native replication | SQL, IIS, Linux app stacks |
| **Carbonite Migrate** | Nutanix VM with agent | Pre-built Azure Local VM with agent | Continuous OS-level replication | Mixed estates, low-downtime OS-level moves |

## Key difference from two-hop paths

| Dimension | Veeam / HYCU | Deploy-First |
|-----------|--------------|--------------|
| Intermediate staging layer | Yes | No |
| Azure Migrate required | Yes (Hop 2) | No for the primary build-first flow |
| Destination VM created before migration | Not usually | Yes |
| Primary validation point | Hyper-V staging first, then Azure Local | Application validation directly on target Azure Local VM |

## Carbonite in this model

Carbonite belongs inside Deploy-First because it still assumes you **provision the target VM first**. The difference is that Carbonite preserves far more of the source OS state than SMS, Robocopy, or app-native methods do.

| Aspect | Carbonite detail |
|--------|------------------|
| Replication model | Continuous OS-level changed-block replication |
| Hypervisor dependency | None |
| Cutover behavior | Final sync, then switch execution to target VM |
| Best used when | You need low-downtime OS-level migration without relying on Nutanix or VMware APIs |

## Decision guidance

Use the following rule of thumb:

- **Choose SMS / Robocopy** when the important asset is the file data, not the existing OS instance
- **Choose application-native migration** when the application already has a supported export/import or backup/restore model
- **Choose Carbonite** when preserving the guest OS state matters, but hypervisor-native approaches are not the right fit

## Diagram references

- [Deploy-First diagrams](../../diagrams/index.md#deploy-first)
- [Tool selection flow](../../overview/tool-comparison.md)