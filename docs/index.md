# Nutanix to Azure Local Migration

!!! warning "Under Active Development"
    This repository is a work in progress. Scripts, templates, and automation are not guaranteed to work at this time. Use at your own risk and expect breaking changes.

> Documentation and automation for migrating workloads from Nutanix AHV and Nutanix ESXi to Azure Local.

---

## What Is This?

This site provides end-to-end runbooks, architecture diagrams, and automation scripts for migrating virtual machines from **Nutanix** (AHV or ESXi-on-Nutanix) to **Azure Local** (formerly Azure Stack HCI). Each scenario is documented independently with prerequisites, architecture, step-by-step runbooks, and validation checklists.

## Migration Scenarios

<div class="grid cards" markdown>

- **Veeam Migration Path**

    Replicate VMs from Nutanix AHV or ESXi to an on-premises Hyper-V staging host using Veeam Backup & Replication, then use Azure Migrate to move them to Azure Local.

    [:octicons-arrow-right-24: Veeam Runbook](scenarios/01-veeam/index.md)

- **HYCU Migration Path**

    Back up VMs from Nutanix AHV using HYCU's native API integration, restore to a Hyper-V staging host, then use Azure Migrate to complete the migration to Azure Local.

    [:octicons-arrow-right-24: HYCU Runbook](scenarios/02-hycu/index.md)

- **Deploy-First Migration**

    Provision new VMs on Azure Local first, then selectively migrate data from the source Nutanix VMs using Storage Migration Service, Robocopy, or database-specific tools.

    [:octicons-arrow-right-24: Deploy-First Guide](scenarios/03-deploy-first/index.md)

- **Additional Scenarios**

    Alternative paths including Azure Migrate direct from AHV, Zerto continuous replication, and Carbonite Migrate agent-based migration.

    [:octicons-arrow-right-24: Additional Scenarios](scenarios/05-additional/index.md)

- **Proof of Concept**

    Structured PoC plan for evaluating Veeam vs. HYCU and standalone Hyper-V staging vs. Azure Local direct — 2×2 test matrix, timeline, and decision framework.

    [:octicons-arrow-right-24: PoC Plan](poc/index.md)

</div>

## Common Architecture

All two-hop scenarios follow the same pattern:

```
Nutanix AHV/ESXi  →  Hyper-V Staging  →  Azure Local
     (Source)         (Intermediate)       (Target)
       Veeam/HYCU         Azure Migrate
```

The staging hop converts Nutanix disk formats (VMDK/AHV) to VHDX and provides a validation checkpoint before the VMs land on Azure Local as Arc-managed workloads.

## Getting Started

1. Read the [Overview](overview/index.md) to understand the architecture and choose a migration path
2. Review the [Tool Comparison](overview/tool-comparison.md) to select the right tool for your environment
3. Follow your chosen scenario's prerequisites, architecture, and runbook pages
4. Use the [Reference](reference/tool-comparison-matrix.md) docs for network requirements, IP mapping templates, and glossary
