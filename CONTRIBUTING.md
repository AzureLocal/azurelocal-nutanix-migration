# Contributing

Thank you for your interest in contributing to the Nutanix to Azure Local Migration project. Contributions are welcome — especially around additional migration scenarios, automation scripts, and real-world runbook refinements.

## Before You Start

- Read the [README](README.md) for a project overview
- This project documents production migration paths — **test all script changes in a non-production environment**
- Check open issues and pull requests to avoid duplicate work

## How to Contribute

### Reporting Issues

Use the GitHub Issues tab. Include:
- Which migration scenario or path (Veeam, HYCU, Commvault, Deploy-First, etc.)
- Which step in the runbook failed or is unclear
- Full error messages and environment details (Nutanix version, Azure Local version, tool version)

### Suggesting Features

Open an issue describing the use case or migration scenario you want to add. Describe the business problem, not just the solution.

### Contributing Automation

All automation lives in `src/`. Structure:
- `src/01-veeam/` — Veeam scenario scripts
- `src/02-hycu/` — HYCU scenario scripts
- `src/03-commvault/` — Commvault scenario scripts
- `src/04-deploy-first/` — Deploy-first scenario scripts
- `src/common/` — Shared helpers used by multiple scenarios

Each subfolder contains `powershell/`, `bicep/`, `ansible/`, or `terraform/` subdirectories as appropriate.

### Submitting Pull Requests

1. Fork the repo and create a branch from `main`
2. Name branches using conventional types: `feat/veeam-re-ip-automation`, `fix/hycu-restore-steps`, `docs/deploy-first-scenario`
3. Keep changes focused — one logical change per PR
4. Update the relevant `docs/` pages if your change affects runbook steps or prerequisites
5. Add an entry to [CHANGELOG.md](CHANGELOG.md) under `[Unreleased]`
6. Fill out the pull request template completely

## Commit Messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

| Type | When |
|------|------|
| `feat` | New feature or scenario |
| `fix` | Bug fix in automation |
| `docs` | Documentation updates |
| `chore` | Maintenance, scaffolding |
| `ci` | CI/CD workflow changes |
| `refactor` | Code restructuring |

## Standards

All examples and configurations must use **Contoso (IIC)** naming. See [Standards](standards/index.md).

- Company: **Contoso**
- Domain: `contoso.cloud` / `contoso.local`
- Resources: `rg-iic-<purpose>-<##>`, `azlocal-iic-01`, etc.
- Never use real customer names, `contoso`, `fabrikam`, `example.com`, or internal company names

## Documentation Style

This project uses MkDocs Material. Follow these conventions:

- **Admonitions**: `!!! note`, `!!! warning`, `!!! tip`, `!!! danger`
- **Tabs**: Use `=== "Nutanix AHV"` / `=== "Nutanix ESXi"` for source-platform variations
- **Code blocks**: Always include a language identifier (` ```powershell `, ` ```yaml `, etc.)
- **Tables**: Use standard Markdown tables

## Local Development

```bash
pip install mkdocs-material
mkdocs serve
```

Navigate to `http://localhost:8000` to preview the docs site locally.
