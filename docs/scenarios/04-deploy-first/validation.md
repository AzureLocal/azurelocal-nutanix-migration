# Deploy-First Validation & Checklist (Carbonite Migrate)

> Validation, rollback, and sign-off guidance for Carbonite Migrate deployments.

---

## Pre-cutover validation

Before initiating production cutover, confirm:

- [ ] Carbonite initial mirror completed without errors
- [ ] Continuous replication is active and lag is consistently low
- [ ] Management console shows both agents healthy
- [ ] Test cutover performed and reverted (strongly recommended before production)
- [ ] Application owner has reviewed test cutover results and approved the production window

## Post-cutover validation

### Target VM validation

- [ ] VM boots and remains stable on Azure Local
- [ ] Correct CPU, memory, disk, and NIC layout confirmed
- [ ] DNS resolution and gateway connectivity succeed
- [ ] Monitoring and management baseline active
- [ ] Security tooling and policy baselines applied

### Carbonite-specific items

- [ ] Final Carbonite sync confirmed complete in management console
- [ ] Carbonite cutover reported successful in job log
- [ ] Source agent disconnected cleanly after cutover
- [ ] Re-IP rules applied correctly (if configured)
- [ ] No replication errors logged in the 24 hours before cutover

### Application validation

- [ ] Application owner confirms core smoke tests pass
- [ ] Service accounts and certificates are correct
- [ ] Scheduled tasks and background services running as expected
- [ ] Application logs show no unexpected errors post-cutover
- [ ] Dependent systems can reach the migrated workload

## Azure Local validation

- [ ] Target workload visible and healthy in the Azure portal
- [ ] Update compliance and monitoring integrations active
- [ ] Backup/protection policy applied to the new VM
- [ ] VM tagged and governed per organizational standards

## Rollback decision points

Initiate rollback if any of the following occurs:

- Target application fails smoke testing and cannot be quickly remediated
- Carbonite cutover reports errors or the final sync does not complete cleanly
- DNS or IP transition causes broader connectivity failures
- Performance issues prevent the application from serving users

## Rollback pattern

1. Stop traffic to the Azure Local target VM
2. Re-enable access to the Nutanix source VM
3. Revert DNS and any load balancer changes to point back to source
4. Confirm source workload health with the application owner
5. Notify change management and document root cause
6. Confirm whether Carbonite replication should resume toward a second cutover attempt or whether the migration job should be reset

## Pre-cutover checklist

- [ ] IP / DNS plan approved
- [ ] Source VM hold period defined (minimum 5 business days recommended)
- [ ] Application validation steps documented and assigned to app owner
- [ ] Carbonite replication lag confirmed low and stable
- [ ] Carbonite agents healthy on source and target
- [ ] Change management window confirmed
- [ ] Rollback owner identified and available during cutover