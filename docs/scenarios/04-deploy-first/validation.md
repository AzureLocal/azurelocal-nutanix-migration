# Deploy-First Validation & Checklist

> Validation and rollback guidance for build-first migrations to Azure Local.

---

## Common validation checks

For every Deploy-First migration, validate the target Azure Local VM before sign-off:

- [ ] VM boots and remains stable on Azure Local
- [ ] Correct CPU, memory, disk, and NIC layout applied
- [ ] DNS resolution and gateway connectivity succeed
- [ ] Monitoring and management baselines are active
- [ ] Application owner confirms core smoke tests

## Variant-specific validation

=== "SMS / Robocopy"

    - [ ] File counts match agreed tolerance
    - [ ] Share permissions and NTFS permissions are correct
    - [ ] User access tests succeed from representative clients
    - [ ] Final sync completed after source writes stopped

=== "Application-native"

    - [ ] Database/application restore completed without corruption
    - [ ] Service accounts, bindings, and certificates are correct
    - [ ] Logs and scheduled tasks/jobs function on target
    - [ ] Application owner signs off on functional tests

=== "Carbonite Migrate"

    - [ ] Source and target agents report healthy
    - [ ] Initial mirror completed successfully
    - [ ] Continuous replication remained healthy before cutover
    - [ ] Final cutover completed inside the approved downtime window

## Azure Local validation

- [ ] Target workload is visible and healthy in the Azure portal
- [ ] Update and monitoring integrations are active as required
- [ ] Security tooling and policy baselines are applied
- [ ] Backup/protection model for the new VM is confirmed

## Rollback decision points

Rollback should be considered if any of the following occurs:

- Target application fails smoke testing and cannot be remediated quickly
- Data integrity or permissions validation fails
- Performance or dependency failures block business use

## Rollback pattern

1. Stop traffic to the Azure Local target
2. Restore traffic to the Nutanix source VM
3. Revert DNS/load balancer changes
4. Confirm source workload health with the application owner
5. Document root cause before reattempting cutover

## Pre-cutover checklist

- [ ] IP / DNS plan approved
- [ ] Source hold period defined
- [ ] App owner validation steps documented
- [ ] Tool-specific migration logs reviewed
- [ ] Final delta or final backup completed
- [ ] Rollback owner on call during cutover