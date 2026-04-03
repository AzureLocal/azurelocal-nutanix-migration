# Alternative Migration Methods

> File-level and application-native migration paths for deploy-first workloads that do not require Carbonite Migrate.

---

!!! note "Section Overview"
    This section covers migration methods that follow the same **deploy-first model** (provision the target VM first), but use lighter-weight approaches suited to workloads where OS-level replication is not needed. These methods are best when the important asset is file data, application state, or a database export — not the source OS instance itself.

## Methods covered

<div class="grid cards" markdown>

- **File and Data Migration**

    Move file-server data using Storage Migration Service (SMS) or Robocopy. Right for file servers and content repositories.

    [:octicons-arrow-right-24: File and Data Migration](runbook.md#file-and-data-migration)

- **Application-Native Migration**

    Migrate SQL Server, IIS, and Linux/database workloads using the application's own export, backup, or replication tooling.

    [:octicons-arrow-right-24: Application-Native Migration](runbook.md#application-native-migration)

</div>

## When to use these methods instead of Carbonite

| Situation | Recommended method |
|-----------|-------------------|
| Workload is a Windows file server | SMS or Robocopy |
| Workload is stateless or easily rebuilt | Robocopy or simple re-deploy |
| SQL Server workload with a clean backup/restore path | Application-native (SQL backup/restore) |
| IIS or web application workload | Application-native (IIS export/import) |
| Linux app with rsync or native DB tooling available | Application-native (rsync / database dump/restore) |
| OS state must be preserved | Use [Deploy-First with Carbonite](../04-deploy-first/index.md) instead |

## Pages

- [Prerequisites](prerequisites.md) — Readiness requirements for SMS, Robocopy, and app-native paths
- [Runbook](runbook.md) — Step-by-step execution for each method
- [Validation & Checklist](validation.md) — Validation and rollback guidance

## Primary migration path

If you need low-downtime OS-level replication, use [Deploy-First with Carbonite Migrate](../04-deploy-first/index.md) instead.
