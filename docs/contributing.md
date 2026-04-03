# Contributing

See the repository [CONTRIBUTING.md](https://github.com/AzureLocal/azurelocal-nutanix-migration/blob/main/CONTRIBUTING.md) for full contribution guidelines.

## Quick Reference

- Fork the repository and submit pull requests against `main`
- Follow the [IIC naming and documentation standards](standards/index.md)
- Use Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`
- All content must use **IIC** (Infinite Improbability Corp) naming — no real customer names
- For diagrams: place rendered visuals in `docs/assets/images/` and editable `.drawio` in `docs/assets/diagrams/`
- Include a `Draw.io source` link wherever a diagram is embedded
- Do not add local output artifacts (for example, `mnt/` paths) to commits
- Use current repo terminology: **Azure Local VMs** for target workloads
- Run `mkdocs build --strict` locally before opening a PR
