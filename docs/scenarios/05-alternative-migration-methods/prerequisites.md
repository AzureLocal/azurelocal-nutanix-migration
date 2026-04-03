# Alternative Migration Methods — Prerequisites

> Readiness requirements for file-level and application-native deploy-first migrations.

---

## Common prerequisites

| Area | Requirement | Why it matters |
|------|-------------|----------------|
| Azure Local target | Target cluster healthy, capacity confirmed, target networks ready | All build-first variants land directly on Azure Local |
| Target VM design | CPU, memory, storage, and OS design approved for each workload | This path intentionally right-sizes the destination |
| Identity and DNS | Domain join, DNS updates, and service account needs documented | Cutover depends on clean name/IP transitions |
| Application ownership | App owner available for smoke testing and sign-off | Build-first validation is application-driven |
| Rollback plan | Source VM hold period and rollback trigger defined | No staging checkpoint exists for these paths |

## Network requirements

| Flow | Protocol / Port | Used by |
|------|-----------------|---------|
| Source file server to target VM | SMB 445 | SMS, Robocopy |
| Source and target to DNS / AD | DNS 53, Kerberos 88, LDAP 389/636 | All domain-joined workloads |
| Source SQL to backup location | SMB 445 or HTTPS 443 | SQL backup/restore |
| Linux source to target | SSH 22 | rsync / Linux-native transfer |
| Target VM to Azure | HTTPS 443 | Azure integration and management |

## Target VM readiness

- Provision target VMs on Azure Local before starting migration activity
- Apply baseline OS configuration, patching, security policy, and monitoring agents
- Pre-create data disks and mount points to match the target application design
- Confirm target VM backup or rollback expectations with the application owner

## Tool-specific readiness

=== "SMS / Robocopy"

    - Source and target file paths inventoried
    - Permissions model reviewed (share + NTFS)
    - Exclusions documented (temp, cache, transient folders)
    - Maintenance window approved for final delta and share cutover
    - Storage Migration Service role installed on the orchestrator (Windows Admin Center or PowerShell)

=== "Application-native"

    - Application-specific runbook approved by app owner
    - Backup location selected and tested (accessible from both source and target)
    - Connection strings, certificates, bindings, and service accounts documented
    - Post-cutover validation script or smoke-test checklist prepared
    - Required application roles/features pre-installed on the target VM

## Pre-start checklist

- [ ] Target Azure Local VM exists for every workload in scope
- [ ] IP mapping and DNS update plan approved
- [ ] Application validation owner assigned
- [ ] Cutover window approved
- [ ] Source VM rollback/hold policy documented
- [ ] Tool-specific ports confirmed open
- [ ] Storage sizing reviewed with 25-30% free headroom on target
- [ ] Monitoring baseline captured on each source workload
- [ ] Admin credentials confirmed for source and target systems
