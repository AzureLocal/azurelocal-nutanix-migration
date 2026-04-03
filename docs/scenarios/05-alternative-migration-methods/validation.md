# Alternative Migration Methods — Validation & Checklist

> Validation and rollback guidance for file-level and application-native deploy-first migrations.

---

## Common validation checks

For every migration in this section, validate the target Azure Local VM before sign-off:

- [ ] VM boots and remains stable on Azure Local
- [ ] Correct CPU, memory, disk, and NIC layout applied
- [ ] DNS resolution and gateway connectivity succeed
- [ ] Monitoring and management baselines active
- [ ] Application owner confirms core smoke tests

## Method-specific validation

=== "SMS / Robocopy"

    - [ ] File counts match the agreed tolerance from the final transfer log
    - [ ] Share permissions and NTFS permissions match source
    - [ ] User access tests succeed from representative client systems
    - [ ] Final sync completed after source writes stopped
    - [ ] No access-denied entries present in the migration log

=== "Application-native"

    - [ ] Database or application restore completed without corruption
    - [ ] SQL logins, Agent jobs, and maintenance plans verified
    - [ ] IIS bindings, application pools, and certificates correct
    - [ ] Service accounts, scheduled tasks, and background services running
    - [ ] Application owner signs off on functional tests

## Azure Local validation

- [ ] Target workload visible and healthy in the Azure portal
- [ ] Update and monitoring integrations active
- [ ] Security tooling and policy baselines applied
- [ ] Backup/protection policy applied to the new VM

## Rollback decision points

Rollback should be considered if:

- Target application fails smoke testing and cannot be quickly remediated
- Data integrity or permissions validation fails
- Performance or dependency failures block business use

## Rollback pattern

1. Stop traffic to the Azure Local target
2. Restore traffic to the Nutanix source VM
3. Revert DNS and load balancer changes to point back to source
4. Confirm source workload health with the application owner
5. Document root cause before attempting a second cutover

## Pre-cutover checklist

- [ ] IP / DNS plan approved
- [ ] Source VM hold period defined
- [ ] App owner validation steps documented and assigned
- [ ] Migration logs reviewed and errors resolved
- [ ] Final delta or final backup confirmed complete
- [ ] Rollback owner on call during cutover window
