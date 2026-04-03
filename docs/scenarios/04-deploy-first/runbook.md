# Deploy-First Runbook (Carbonite Migrate)

> Step-by-step execution for agent-based OS-level replication from Nutanix to Azure Local using Carbonite Migrate.

---

## Phase 1 — Provision and baseline the target VM

1. Create the target Azure Local VM with approved CPU, memory, and storage sizing
2. Install the guest OS and apply baseline patching
3. Join the target VM to the correct domain or identity boundary
4. Apply baseline configuration: security tooling, monitoring agents, and backup policy
5. Pre-create data volumes and mount points to match the application design
6. Confirm IP, DNS, firewall, and service account requirements with the application owner
7. Do **not** install the application yet — Carbonite will replicate it from the source

## Phase 2 — Install Carbonite Migrate agents

1. Log on to the Carbonite management server
2. Download the Carbonite Migrate agent installer for the source VM OS family (Windows or Linux)
3. Install the Carbonite Migrate agent on the **source Nutanix VM** per Carbonite's agent installation guide
4. Install the Carbonite Migrate agent on the **target Azure Local VM**
5. Verify both agents appear as online in the Carbonite management console
6. Confirm TCP ports `6325` and `6326` are reachable between source and target agent endpoints

## Phase 3 — Create the migration job

1. In the Carbonite management console, create a new migration job
2. Set the **source** to the source Nutanix VM agent endpoint
3. Set the **target** to the target Azure Local VM agent endpoint
4. Configure the replication scope — include all required volumes; exclude temp/cache paths where appropriate
5. Configure cutover settings: re-IP rules, DNS update behavior, and pre/post cutover scripts if required
6. Review job settings with the application owner before starting replication

## Phase 4 — Initial mirror

1. Start the migration job in the Carbonite console
2. Monitor the initial mirror progress — this is a full block-level copy and may take several hours depending on data volume
3. Confirm mirror completion is reported healthy in the console
4. Do not schedule cutover until the initial mirror has completed and continuous replication is active

## Phase 5 — Continuous replication and pre-cutover validation

1. Confirm continuous replication is running and the delta queue is staying current
2. Monitor replication lag — lag should be consistently low before scheduling cutover
3. Perform a **test cutover** (non-production) if permitted:
    - Initiate a test failover in the Carbonite console
    - Validate application functionality on the target VM
    - Revert the test failover and confirm replication resumes
4. Schedule the production cutover window with the application owner and change management

## Phase 6 — Production cutover

1. Notify all stakeholders that the cutover window is active
2. Quiesce or redirect source application traffic to maintenance mode
3. In the Carbonite console, initiate the production cutover:
    - Carbonite stops source writes
    - Final changed-block sync completes
    - Workload execution transfers to the target Azure Local VM
4. Confirm the target VM is serving the workload correctly

## Phase 7 — Post-cutover validation

1. Application owner runs smoke tests on the target VM
2. Validate DNS resolution, IP addressing, and gateway connectivity
3. Confirm monitoring and alerting baselines are active on the target VM
4. Verify scheduled tasks, services, and any application-specific startup items

## Cutover checklist

- [ ] Continuous replication confirmed healthy and lag is low
- [ ] Test cutover completed and reverted (if applicable)
- [ ] Application owner present for production cutover
- [ ] Change management window active
- [ ] Source writes quiesced before final sync
- [ ] Final Carbonite sync confirmed complete before declaring cutover done
- [ ] DNS / load balancer entries updated
- [ ] Target application healthy before user traffic restored

## Cleanup

1. Keep the Nutanix source VM powered off or isolated during the hold period (minimum 5 business days recommended)
2. Document final target IP, DNS, and service configuration
3. Remove Carbonite agent from source and target once the rollback window is closed
4. Remove the migration job from the Carbonite console
5. Decommission the Nutanix source only after written sign-off from the application owner and rollback window closure