# Standards

> Documentation and naming conventions used throughout this project.

---

## IIC Naming Convention

All Azure and Azure Local resources in this project follow the Contoso IIC naming standard:

### Resource Groups

```
rg-iic-<purpose>-<##>
```

| Example | Purpose |
|---------|---------|
| `rg-iic-migration-01` | Resources for migration tooling |
| `rg-iic-production-01` | Production workloads on Azure Local |
| `rg-iic-network-01` | Networking resources |

### Virtual Machines

```
<site>-<role>-<##>
```

| Example | Role |
|---------|------|
| `azlocal-iic-web-01` | Web server |
| `azlocal-iic-sql-01` | SQL Server |
| `azlocal-iic-app-01` | Application server |
| `azlocal-iic-dc-01` | Domain controller |

### Azure Local Clusters

```
azlocal-iic-<##>
```

Example: `azlocal-iic-01`

### Network Resources

```
vnet-iic-<purpose>-<##>
snet-iic-<purpose>-<##>
nsg-iic-<purpose>-<##>
```

---

## Domain and DNS

| Item | Value |
|------|-------|
| Active Directory domain | `contoso.local` |
| Public/cloud domain | `contoso.cloud` |
| DNS servers | `10.0.0.10`, `10.0.0.11` |

---

## Documentation Standards

All documentation in this repository follows these conventions:

1. **No real company names**: All customer-specific names are replaced with `Contoso` (the IIC environment)
2. **No real datacenters**: Referred to as `Contoso datacenter`
3. **Tabs for platform variants**: AHV vs. ESXi and Option A vs. Option B use the `=== "..."` tab syntax
4. **Admonitions for warnings**: `!!! warning` for destructive operations, `!!! tip` for shortcuts, `!!! note` for informational asides
5. **Tables over prose**: Configuration requirements are always in tables when there are 3+ items

---

## MkDocs Style Guide

- Page titles: Title Case
- Section headings: Sentence case
- Code blocks: Always include language identifier (```powershell, ```bash, ```yaml)
- Relative links within docs: Use `relative/path.md` — no absolute URLs for internal docs
- Diagrams: Embed via `![alt](../../diagrams/path.png)` or the `mkdocs-drawio` plugin for `.drawio` files

See [MkDocs Material reference](https://squidfunk.github.io/mkdocs-material/) for the full feature set.

---

## Git Commit Conventions

This repository uses [Conventional Commits](https://www.conventionalcommits.org/):

```
feat:     New documentation page or significant content addition
fix:      Correction to existing content (broken link, wrong command, etc.)
docs:     Minor wording improvements
chore:    Non-content changes (mkdocs.yml, workflows, package updates)
refactor: Restructure without content change
```

Release notes are generated automatically from commit messages via `release-please`.
