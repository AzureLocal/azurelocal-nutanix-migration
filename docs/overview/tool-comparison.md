# Tool Comparison

> Compare migration tools to choose the right path for your environment.

---

## Primary Tool Comparison

| Aspect | Veeam B&R | HYCU | Nutanix Move |
|--------|-----------|------|--------------|
| **Deployment** | Dedicated Windows Server + SQL Express | Single Linux VM on Nutanix cluster | Lightweight VM on Nutanix or separate host |
| **AHV Integration** | Via Prism API; deploys AHV Backup Proxy VM | Native AHV snapshot API; no proxy VM | Native AHV API |
| **ESXi Support** | Full vSphere API support | Full vSphere API support | Full vSphere support |
| **Agent Required** | No (agentless); NGT recommended for re-IP | No (agentless) | No (agentless) |
| **Management UI** | Windows desktop console | Web UI (port 8443) | Web UI |
| **Re-IP on Migration** | Built-in re-IP rules via Guest Processing | Not built-in; requires post-restore scripting | Built-in |
| **Migration Workflow** | Direct live replication to Hyper-V | Backup → Restore to Hyper-V (two steps) | Direct move to Hyper-V |
| **RPO / Cutover** | Low RPO — live replica kept in sync | RPO = last incremental backup interval | Direct move — no ongoing sync |
| **Storage Overhead** | Only Hyper-V staging (direct replication) | Backup target + Hyper-V staging (two copies) | Only Hyper-V staging |
| **Licensing Model** | Veeam Universal License (VUL) per workload | Per-VM or per-socket subscription | Included with Nutanix (check entitlement) |
| **Complexity** | Higher (more components, more flexibility) | Lower (fewer moving parts, simpler setup) | Lowest for AHV-native environments |
| **Existing Veeam** | Reuse existing investment | New tool if no existing HYCU | Requires Nutanix entitlement |

---

## When to Choose Each Tool

### Choose Veeam if:

- You already have a Veeam Universal License investment
- You need **built-in re-IP rules** (source and target are on different subnets)
- You need **live continuous replication** (lowest RPO possible)
- You want the most granular control over replication scheduling, bandwidth throttling, and job management
- Your team has existing Veeam expertise

### Choose HYCU if:

- You want the **simplest possible deployment** (single VM on Nutanix, no Windows server)
- Your source is AHV-native and you want zero agent/proxy overhead on the Nutanix cluster
- Backup/restore RPO (daily or more frequent incrementals) is acceptable for your workloads
- You prefer HYCU's web-based management console
- Per-VM subscription licensing matches your procurement model

### Choose Nutanix Move if:

- You have a valid Nutanix Move entitlement (check with your Nutanix account team)
- You want **direct migration** without a backup/restore intermediate step
- Your source is AHV or ESXi-on-Nutanix
- You want the fewest tools and moving parts (native Nutanix)
- Your migration window allows for a direct cutover (no need for continuous sync)

---

## Hop 2: Azure Migrate vs. Direct

All scenarios in this documentation use **Azure Migrate** for Hop 2 (Hyper-V → Azure Local). Azure Migrate is the recommended path because it:

- Provides **Arc registration** as part of the migration — VMs arrive already integrated with Azure
- Handles **VHDX format validation** and Azure Local compatibility checks
- Offers a **test migration** capability before production cutover
- Tracks migration status in the Azure portal
- Is free (no additional licensing beyond Azure Local infrastructure costs)

---

## Additional Tools (Alternative Paths)

See [Additional Scenarios](../scenarios/05-additional/index.md) for:

- **Azure Migrate direct from AHV** — skip the Hyper-V staging hop entirely
- **Zerto** — continuous replication, near-zero RPO, ideal for mission-critical workloads
- **Carbonite Migrate** — agent-based cross-platform migration, works at OS level
