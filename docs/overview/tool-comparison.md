# Tool Comparison

> Compare migration tools to choose the right path for your environment.

---

## Primary Tool Comparison

| Aspect | **Veeam B&R** | **HYCU** | **Carbonite Migrate** |
|:--|:--|:--|:--|
| **Deployment model** | Dedicated Windows Server + SQL Express | Single Linux VM on Nutanix cluster | Carbonite management server + agent on source and target VMs |
| **Source coverage** | AHV + ESXi | AHV + ESXi | Hypervisor-agnostic at OS level (AHV, ESXi, Hyper-V, physical) |
| **AHV integration** | Prism API + temporary AHV proxy | Native AHV snapshot API | No AHV API dependency |
| **Agent requirement** | Agentless (NGT optional for re-IP) | Agentless | Agent-based on both source and target |
| **Migration workflow** | Live replication to Hyper-V staging | Backup then restore to Hyper-V staging | Continuous OS-level replication into pre-provisioned target VM |
| **Cutover/downtime profile** | Low downtime (final sync + failover) | Moderate downtime (restore/final sync window) | Low downtime (final delta sync + cutover) |
| **Re-IP/network handling** | Built-in re-IP rules | Script-driven post-restore | Typically handled via DNS/LB update and OS config |
| **Storage overhead during migration** | Hyper-V staging copy | Backup repository + staging copy | Target-side replicated copy (no separate backup repository required) |
| **Performance impact on source** | Moderate during initial sync, low during incrementals | Moderate during backup windows | Moderate CPU/network impact from agent-based replication |
| **Management UX** | Rich desktop console + web components | Simple web UI | Carbonite console |
| **Licensing model** | VUL per workload | Per-VM/per-socket subscription | Licensed product (typically per workload/server) |
| **Operational complexity** | Medium-high | Low-medium | Medium |
| **Best fit** | Larger waves, granular control, existing Veeam investment | Teams that prioritize simplicity and AHV-native workflows | Mixed/legacy environments needing hypervisor-independent migration |
| **Main limitations** | More moving parts to deploy/manage | Two-step workflow can increase staging/storage overhead | Requires agents and careful change-control on guest OS |

---

## When to Choose Each Tool

![Tool selection flow](../assets/images/06-tool-selection-flow.svg)

Draw.io source: [migration-diagrams-tool-selection-flow.drawio](../assets/diagrams/migration-diagrams-tool-selection-flow.drawio)

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

### Choose Carbonite if:

- You need a **hypervisor-independent** option for mixed or legacy estates
- Source hypervisor/API constraints make agentless approaches difficult
- You are following a **deploy-first** model with pre-built Azure Local target VMs
- You can support agent deployment and change-control across source VMs
- You want continuous replication with low cutover downtime but not a hypervisor-native toolchain

---

## Hop 2 (Common): Azure Migrate

All scenarios in this documentation use **Azure Migrate** for Hop 2 (Hyper-V → Azure Local). Azure Migrate is the recommended path because it:

- Provides **Arc registration** as part of the migration — VMs arrive already integrated with Azure
- Handles **VHDX format validation** and Azure Local compatibility checks
- Offers a **test migration** capability before production cutover
- Tracks migration status in the Azure portal
- Is free (no additional licensing beyond Azure Local infrastructure costs)
