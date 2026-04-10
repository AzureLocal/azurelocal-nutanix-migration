# Deploy-First Prerequisites (Carbonite Migrate)

> Readiness requirements for agent-based OS-level replication from Nutanix to Azure Local using Carbonite Migrate (an **OpenText** product).

!!! info "Product naming"
    Carbonite Migrate was acquired by **OpenText** (formerly Carbonite, formerly Double-Take Software). You may see it referred to as *OpenText Migrate*, *Carbonite Migrate*, or *Double-Take Move* in older documentation. Current product page: [opentext.com/products/carbonite-migrate](https://www.opentext.com/products/carbonite-migrate). For licensing and procurement, contact your OpenText reseller or Microsoft partner.

---

## Licensing

| Item | Detail |
|------|--------|
| License model | Per-source-VM (one license consumed per migrated workload) |
| License type | Carbonite Migrate perpetual or subscription — confirm with OpenText/reseller |
| Trial | 30-day evaluation licenses available via OpenText; contact your reseller or [opentext.com](https://www.opentext.com/products/carbonite-migrate) |
| Quantity | Count equals the number of **source Nutanix VMs** being migrated (not replicas) |
| Consumption | Licenses attach to the migration job; once the job is removed after successful cutover, the license can typically be reassigned to the next batch (confirm with your agreement) |

!!! tip "Right-size your license quantity"
    Because Carbonite does **not** use a Hyper-V staging hop, there is **no Azure Migrate step** in this path. Carbonite replicates directly from the Nutanix source to the pre-provisioned Azure Local target VM. Licenses can be staggered across batches — you do not need to purchase all at once if migrating in waves.

---

## Estimated Downtime Per VM

| Phase | Downtime | Notes |
|-------|----------|-------|
| Initial mirror (Phase 4) | **Zero** | Runs in background while source VM stays online |
| Continuous replication (Phase 5) | **Zero** | Source VM stays online; delta changes replicated continuously |
| Production cutover (Phase 6) | **5–30 minutes** | Carbonite quiesces source writes, completes final changed-block sync, then transfers workload to target |
| Typical service disruption | **5–15 minutes** in optimal conditions | Depends on replication lag and application quiesce time |

!!! info "Carbonite has the shortest expected downtime of the three migration paths"
    Because the source VM stays online throughout the mirror and replication phases, and because Carbonite includes change-block tracking, the only downtime is the final cutover sync. A well-tuned job with low replication lag will cut over in under 10 minutes.

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

- [ ] OpenText/Carbonite Migrate licenses confirmed (quantity = number of source VMs per batch)
- [ ] Target Azure Local VM exists for every workload in scope
- [ ] Carbonite management server deployed and accessible
- [ ] Agent installation approved on source and target for every in-scope VM
- [ ] TCP 6325 and 6326 open between each source/target pair
- [ ] IP mapping and DNS update plan approved
- [ ] Application validation owner assigned per workload
- [ ] Cutover window approved (target: 5–30 min downtime per VM)
- [ ] Source VM rollback/hold policy documented (minimum 5 business days hold)
- [ ] Storage sizing reviewed with 25–30% free headroom on target
- [ ] Monitoring baseline captured on each source workload
- [ ] Admin credentials confirmed for source and target systems
