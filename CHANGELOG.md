# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## 1.0.0 (2026-05-12)


### Features

* add azurelocal.cloud backlink and social footer to mkdocs ([f81c4db](https://github.com/AzureLocal/azurelocal-nutanix-migration/commit/f81c4dba8fdaa877032d156eba4d6bd906e2017c))
* add correctly named icon SVG, banner SVG, and update docs home page ([74ce5a9](https://github.com/AzureLocal/azurelocal-nutanix-migration/commit/74ce5a9a87429f094f0b0a4f3dc408f51f17a69d)), closes [#5](https://github.com/AzureLocal/azurelocal-nutanix-migration/issues/5)
* initial MkDocs site structure with migration scenarios, PoC, reference docs, and src scaffolding ([0fb910c](https://github.com/AzureLocal/azurelocal-nutanix-migration/commit/0fb910c7bbee72fce856a1020871ff77dae9f40a))
* rebuild src/ tool-first, remove Nutanix Move scenario, enforce IIC naming ([e79863b](https://github.com/AzureLocal/azurelocal-nutanix-migration/commit/e79863b3d94536209551d426906efbea10cdff27))


### Bug Fixes

* add pymdownx.emoji extension to render octicons in grid cards ([a51a516](https://github.com/AzureLocal/azurelocal-nutanix-migration/commit/a51a5161589c7ed05cdfb9755da830bd83af7b53))
* add reopened trigger to add-to-project workflow ([41b891c](https://github.com/AzureLocal/azurelocal-nutanix-migration/commit/41b891cea7a001083464928ded37c4331f079374))
* remove all Nutanix Move references (does not support Hyper-V target) ([6f49591](https://github.com/AzureLocal/azurelocal-nutanix-migration/commit/6f4959105aeafcb664a3d1e951944a9e42f03e79))
* remove invalid sitemap plugin, move gtag to preset options ([9b3ffa1](https://github.com/AzureLocal/azurelocal-nutanix-migration/commit/9b3ffa1d6b032809af705029178e6bb924f3f6fb))
* restore docs standards for mkdocs build ([11c354c](https://github.com/AzureLocal/azurelocal-nutanix-migration/commit/11c354c42987cefa4d7b33fc892539e0f74347b8))
* **standards:** update canonical path to docs/standards/ in platform ([dd77aac](https://github.com/AzureLocal/azurelocal-nutanix-migration/commit/dd77aacf2258f1de3a295812a2264f0c141dd45a))

## [Unreleased]

### Features

- Initial MkDocs documentation site structure
- Veeam migration path — full runbook, architecture, prerequisites, validation
- HYCU migration path — full runbook, architecture, prerequisites, validation
- Commvault migration path — full runbook, architecture, prerequisites, validation
- Deploy-First migration scenario documentation with Carbonite retained as a deploy-first variant
- Migration scenario landing page with product-scoped sidebar navigation
- Proof of Concept plan — 3×2 test matrix, five-week timeline, decision framework
- Reference documentation — tool comparison matrix, network requirements, IP mapping template, glossary
- Architecture and decision diagrams organized by scenario

### Infrastructure

- Add GitHub Actions deploy-docs workflow
- Add release-please workflow
- Add CODEOWNERS
- Add branch protection on main
