# Standards

This repository follows the org-wide **AzureLocal standards**, maintained centrally in [`AzureLocal/platform/standards/`](https://github.com/AzureLocal/platform/tree/main/standards) and rendered at [azurelocal.cloud/standards](https://azurelocal.cloud/standards/).

See [`STANDARDS.md`](../../STANDARDS.md) at the repo root for the canonical pointer and governance ([ADR-0002](https://github.com/AzureLocal/platform/blob/main/decisions/0002-standards-single-source.md)).

---

## Repo-specific terminology

The following conventions are specific to the Nutanix → Azure Local migration context and are **not** part of the org-wide standards:

- Prefer **Azure Local VMs** terminology across docs for target workloads.
- Avoid phrasing that implies unsupported direct AHV migration paths — migrations go via Veeam, HYCU, Commvault, or the deploy-first pattern, never directly from AHV.
