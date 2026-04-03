# Tool Comparison Matrix

> Side-by-side comparison of all migration tools covered in this repository.

---

## Primary Tool Comparison

| Aspect | **Veeam B&R** | **HYCU** | **Carbonite Migrate** |
|--------|:---:|:---:|:---:|
| Source: Nutanix AHV | ✅ | ✅ | ✅ |
| Source: Nutanix ESXi | ✅ | ✅ | ✅ |
| Deployment | Windows Server | Linux appliance on cluster | Agent on each VM |
| Agent on source VMs | ❌ (agentless) | ❌ (agentless) | ✅ Required |
| Separate backup storage | ❌ Not needed | ✅ Required | ❌ Not needed |
| Live/continuous replication | ✅ Yes | ❌ Backup-based | ✅ Yes |
| Built-in re-IP | ✅ Yes | ❌ Script required | ❌ DNS/LB update at cutover |
| Platform overhead/complexity | Medium | Low | Low |
| License cost | Paid | Paid | Paid |
| Concurrency (est.) | 10–20 VMs | 5–10 VMs | 10–20 VMs |
| Management UI | Desktop + Web | Web (HTTPS) | Carbonite console |

## When to Choose Each Tool

| Tool | Choose When |
|------|------------|
| **Veeam B&R** | Large VM counts (> 100), existing Veeam license, ESXi source, need built-in re-IP |
| **HYCU** | AHV source, no existing tool license, team prefers simple web UI, backup compliance also needed |
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
