# azurelocal-nutanix-migration

![Nutanix to Azure Local Migration](docs/assets/images/azurelocal-nutanix-migration-banner.svg)

[![Azure Local](https://img.shields.io/badge/Azure%20Local-azurelocal.cloud-0078D4?logo=microsoft-azure)](https://azurelocal.cloud)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Documentation: [azurelocal.cloud](https://azurelocal.cloud) | Solutions: [Azure Local Solutions](https://azurelocal.cloud)

> **⚠️ Under Active Development** — This repository is a work in progress. Documentation and automation are not guaranteed to be complete at this time.

Documentation and automation for migrating workloads from **Nutanix AHV** and **Nutanix ESXi** to **Azure Local**.

---

## Documentation

The full documentation site is published via MkDocs:

**Site URL**: <https://azurelocal.github.io/azurelocal-nutanix-migration/>

---

## Migration Scenarios

| Scenario | Description |
|----------|-------------|
| [Veeam Migration Path](docs/scenarios/01-veeam/) | Replicate VMs from Nutanix to a Hyper-V staging host using Veeam, then migrate to Azure Local |
| [HYCU Migration Path](docs/scenarios/02-hycu/) | Direct migration using HYCU Backup & Recovery |
| [Commvault Migration Path](docs/scenarios/03-commvault/) | Enterprise migration using Commvault |
| [Deploy-First (Carbonite)](docs/scenarios/04-deploy-first/) | Deploy-first pattern using Carbonite Move |
| [Alternative Methods](docs/scenarios/05-alternative-migration-methods/) | Azure Migrate and manual migration paths |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
