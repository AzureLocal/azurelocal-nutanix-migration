# Deploy-First Prerequisites (Carbonite Migrate)

> Readiness requirements for agent-based OS-level replication from Nutanix to Azure Local using Carbonite Migrate.

---

## Common prerequisites

| Area | Requirement | Why it matters |
|------|-------------|----------------|
| Azure Local target | Cluster healthy, capacity confirmed, target networks ready | Target VM exists before migration starts |
| Target VM design | CPU, memory, storage, and OS design approved for each workload | Deploy-First intentionally right-sizes the destination |
| Carbonite license | Carbonite Migrate license available and assigned | One license per source VM migrated |
| Carbonite management server | Deployed and reachable from source and target VMs | Central job orchestration and monitoring |
| Identity and DNS | Domain join, DNS update, and service account needs documented | Cutover depends on clean name/IP transitions |
| Application ownership | App owner available for smoke testing and sign-off | Validation is application-driven |
| Rollback plan | Source VM hold period and rollback trigger defined | No intermediate staging checkpoint |

## Network requirements

| Flow | Protocol / Port | Used by |
|------|-----------------|---------|
| Source agent to target agent | TCP 6325, 6326 | Carbonite Migrate replication |
| Source and target agents to management server | TCP 8080, 8443 (or as configured) | Job management and monitoring |
| Source and target to DNS / AD | DNS 53, Kerberos 88, LDAP 389/636 | All domain-joined workloads |
| Target VM to Azure | HTTPS 443 | Azure integration and management |

## Target VM readiness

- Provision each target VM on Azure Local before installing Carbonite agents or creating migration jobs
- Apply baseline OS configuration: patching, security tooling, monitoring agents, and backup policy
- Pre-create data disks and mount points to match the target application design
- Confirm target VM backup/restore or rollback expectations with the application owner

## Carbonite Migrate readiness

- Carbonite Migrate management server deployed (Windows Server 2019/2022 recommended)
- Carbonite Migrate agent installer available for the OS family of each source VM
- Source VM change-control approved for agent installation
- Target VM change-control approved for agent installation
- Ports `6325` and `6326` confirmed open between each source/target pair
- Carbonite license quantity confirmed against number of source VMs in scope

## Pre-start checklist

- [ ] Target Azure Local VM exists for every workload in scope
- [ ] Carbonite management server deployed and accessible
- [ ] Carbonite license quantity confirmed
- [ ] Agent installation approved on source and target for every in-scope VM
- [ ] TCP 6325 and 6326 open between each source/target pair
- [ ] IP mapping and DNS update plan approved
- [ ] Application validation owner assigned per workload
- [ ] Cutover window approved
- [ ] Source VM rollback/hold policy documented
- [ ] Storage sizing reviewed with 25-30% free headroom on target
- [ ] Monitoring baseline captured on each source workload
- [ ] Admin credentials confirmed for source and target systems
