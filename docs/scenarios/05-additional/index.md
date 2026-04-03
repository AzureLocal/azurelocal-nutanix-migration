# Additional Migration Paths

> Additional migration tools and approaches for specialized scenarios.

---

This page summarizes additional migration options beyond the primary Veeam and HYCU paths. These are not covered by detailed runbooks in this repository but are applicable in specific situations.

---

## Azure Migrate — Direct from AHV (Agentless)

Azure Migrate supports **agentless VM discovery and replication directly from Nutanix AHV** using the AHV API, without needing a separate migration tool for Hop 1.

| Aspect | Detail |
|--------|--------|
| Source | Nutanix AHV (Prism Central v2021.x+) |
| Target | Azure (cloud), or Azure Local via Azure Migrate |
| Agent required | No — agentless |
| Tool | Azure Migrate: Server Migration |
| Limitation | Requires Prism Central (not Prism Element only clusters) |

This path eliminates Hop 1 entirely — Azure Migrate replicates directly from AHV VMDK/qcow2 to Azure Local VHDX.

**Useful when**: You have Prism Central and do not want to deploy a separate migration tool.

---

## Zerto

[Zerto](https://www.zerto.com/) is a continuous data protection (CDP) tool that can be used for VM migrations in addition to disaster recovery. Zerto supports Nutanix AHV as a source using its AHV connector.

| Aspect | Detail |
|--------|--------|
| Source | Nutanix AHV, VMware vSphere |
| Target | Hyper-V, Azure Local |
| RPO | Near-zero (journal-based CDP) |
| Re-IP | Built-in re-IP and network mapping at failover/migrate |

Useful when low RPO is critical and you already have a Zerto license for DR.

---

## Carbonite Migrate

[Carbonite Migrate](https://www.carbonite.com/business/products/carbonite-migrate/) (formerly DoubleTake) supports platform-to-platform live migrations using OS-level block replication. It works at the OS level rather than the hypervisor level — no dependency on Nutanix or Hyper-V APIs.

| Aspect | Detail |
|--------|--------|
| Source | Any OS (Windows, Linux) on any hypervisor |
| Target | Hyper-V, Azure Local |
| Agent required | Yes — installed on source VMs |
| Advantage | Hypervisor-independent; works on any OS version |

Useful when VMs are running on older hypervisors or unsupported AHV versions.

---

## Manual Migration (Export/Import)

For very small migrations (< 10 VMs) or one-off workloads, manual export/import can be used:

1. **On Nutanix AHV**: Snapshot the VM and export the disk image (QCOW2) from Prism
2. **Convert disk**: `qemu-img convert -f qcow2 -O vhdx source.qcow2 target.vhdx`
3. **Create Hyper-V VM**: Create a new VM pointing to the converted VHDX
4. **Azure Migrate (Hop 2)**: Proceed with Azure Migrate → Azure Local

This approach has no streaming replication — the entire disk is exported once, so it is only practical for small VMs or offline workloads.

---

## Choosing the Right Tool

See the [Tool Comparison Matrix](../../reference/tool-comparison-matrix.md) for a side-by-side comparison of all tools covered in this repository.
