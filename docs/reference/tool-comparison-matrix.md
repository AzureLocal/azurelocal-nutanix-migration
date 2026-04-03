# Tool Comparison Matrix

> Side-by-side comparison of all migration tools covered in this repository.

---

## Primary Tool Comparison

| Aspect | **Veeam B&R** | **HYCU** | **Commvault** | **Carbonite Migrate** |
|--------|:---:|:---:|:---:|:---:|
| Source: Nutanix AHV | ✅ | ✅ | Assumed supported for planning; validate release | ✅ |
| Source: Nutanix ESXi | ✅ | ✅ | Assumed supported for planning; validate release | ✅ |
| Deployment | Windows Server | Linux appliance on cluster | Control plane plus media or worker components | Agent on each VM |
| Agent on source VMs | ❌ (agentless) | ❌ (agentless) | Varies by workflow | ✅ Required |
| Separate backup storage | ❌ Not needed | ✅ Required | ✅ Usually required | ❌ Not needed |
| Live or continuous replication | ✅ Yes | ❌ Backup-based | ❌ Restore-based in this doc model | ✅ Yes |
| Built-in re-IP | ✅ Yes | ❌ Script required | ❌ Script or manual post-restore | ❌ DNS/LB update at cutover |
| Platform overhead or complexity | Medium | Low | Medium-high | Low |
| License cost | Paid | Paid | Paid | Paid |
| Concurrency (est.) | 10–20 VMs | 5–10 VMs | Depends on media and storage design | 10–20 VMs |
| Management UI | Desktop + Web | Web (HTTPS) | Command Center + admin consoles | Carbonite console |

## When to Choose Each Tool

| Tool | Choose When |
|------|------------|
| **Veeam B&R** | Large VM counts (> 100), existing Veeam license, ESXi source, need built-in re-IP |
| **HYCU** | AHV source, no existing tool license, team prefers simple web UI, backup compliance also needed |
| **Commvault** | Existing Commvault estate, centralized governance and policy control matter, restore-based Hop 1 is acceptable |
| **Carbonite** | Hypervisor-independent requirement, very old AHV versions, OS-level replication preferred, deploy-first pattern |
| **Deploy-First** | OS refresh needed, stateless workloads, file server data migration only |

## Staging Option Comparison

| Staging Option | Hardware Cost | Complexity | Suitable For |
|---------------|:---:|:---:|:---:|
| **Option A — Standalone Hyper-V** | Extra server required | Medium | Dedicated migration pipeline, isolated from production |
| **Option B — Azure Local as HV** | Uses existing AZL cluster | Low | Smaller migrations, no spare hardware available |

## Recommended Defaults (IIC)

After completing the PoC, update this table with the decided production configuration:

| Decision | Selected Option | Notes |
|----------|----------------|-------|
| Primary migration tool | _TBD after PoC_ | |
| Staging option | _TBD after PoC_ | |
| Batch size | 8–10 VMs | Based on PoC timing |
| Concurrent batches | 1 (Hop 1) / multiple (Hop 2) | |
