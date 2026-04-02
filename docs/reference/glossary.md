# Glossary

> Definitions for terms used throughout this documentation.

---

## A

**AHV** (Acropolis Hypervisor)  
Nutanix's native KVM-based hypervisor. AHV is fully integrated with Prism and uses native snapshot APIs leveraged by HYCU, Nutanix Move, and Azure Migrate for agentless VM replication.

**Arc-managed VM**  
A Hyper-V VM running on Azure Local that is registered with Azure Arc, enabling Azure management features (RBAC, Policy, Defender for Cloud, Update Manager, Monitor).

**Azure Local**  
Microsoft's hyperconverged infrastructure (HCI) platform formerly known as Azure Stack HCI. Runs Hyper-V workloads on-premises with Azure Arc integration.

**Azure Migrate**  
A free Azure service for discovering, assessing, and migrating servers to Azure or Azure Local. Used in this repo as the Hop 2 migration engine from Hyper-V staging to Azure Local.

---

## B

**Batch**  
A group of 8–10 VMs migrated together in a single migration cycle. Batches limit blast radius and allow for parallel testing.

**CBT** (Changed Block Tracking)  
A mechanism used by hypervisors (AHV, vSphere) to track which disk blocks have changed since the last backup or replication cycle, enabling efficient incremental operations.

**CSV** (Cluster Shared Volume)  
A shared disk volume accessible by all nodes in an Azure Local or Windows Server Failover Cluster. Migration target storage on Azure Local is stored on CSVs.

---

## H

**HYCU Backup & Recovery**  
A purpose-built backup and recovery solution for Nutanix, VMware, and other platforms. Uses native AHV snapshot APIs — no proxy VM required on Nutanix clusters.

**Hop 1**  
The first migration hop: migrating VMs from the Nutanix source to a Hyper-V staging environment using Veeam, HYCU, or Nutanix Move.

**Hop 2**  
The second migration hop: migrating VMs from Hyper-V staging to Azure Local using Azure Migrate.

**HV** (Hyper-V)  
Microsoft's Type-1 hypervisor. Used as the staging platform in all two-hop migration paths before the final move to Azure Local.

---

## I

**IIC** (Intelligent Infrastructure Contoso)  
The Contoso IIC environment naming/resource convention used throughout this repository for lab and reference scenarios.

---

## N

**Nutanix Move**  
A free migration appliance from Nutanix for migrating AHV VMs to other hypervisors, including Hyper-V. Uses native AHV APIs; separate from HYCU.

**NCC** (Nutanix Cluster Check)  
A health-check utility built into Nutanix clusters. Run `ncli health-check run-all` or use Prism to validate cluster health before migration.

---

## P

**Prism Central**  
Nutanix's multi-cluster management plane. Required for some Azure Migrate direct-from-AHV scenarios. Distinct from Prism Element (the single-cluster management plane).

**Prism Element**  
Nutanix's per-cluster management plane (HTTPS port 9440). Used by Veeam, HYCU, and Nutanix Move to discover and snapshot VMs.

---

## R

**RPO** (Recovery Point Objective)  
The maximum acceptable age of restore point data at cutover time. In migration context: how much data can be lost if cutover happens at the last synchronization point.

**RTO** (Recovery Time Objective)  
The maximum acceptable time to complete a cutover and have the VM operational on the new platform.

---

## V

**Veeam Backup & Replication**  
A widely-used data protection and migration platform. In this repo, used for Hop 1 replication from Nutanix (AHV or ESXi) to Hyper-V staging. Supports built-in re-IP rules at failover time.

**VHDX**  
The Hyper-V virtual disk format. All migration paths convert source VM disks (AHV qcow2 or VMware vmdk) to VHDX before Azure Migrate replication to Azure Local.
