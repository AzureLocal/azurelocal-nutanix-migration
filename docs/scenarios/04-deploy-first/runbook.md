# Deploy-First Runbook

> Step-by-step execution patterns for build-first migrations to Azure Local.

---

## Common preparation

1. Create the target Azure Local VM with approved sizing
2. Join the target VM to the correct domain or identity boundary if required
3. Apply baseline configuration: patching, security tooling, monitoring, and backup policy
4. Confirm IP, DNS, firewall, and service account requirements
5. Choose the migration variant that matches the workload

## Option A — File and content migration

### Storage Migration Service (SMS)

1. Prepare the source and target Windows file servers
2. Inventory shares, NTFS permissions, local groups, and scheduled tasks
3. Create the SMS transfer job from source to target
4. Run the initial transfer and review job health
5. Schedule the cutover window for the final delta
6. Cut over the identity/share presentation and validate access from client systems

### Robocopy

Use Robocopy for simpler file-server or content-host workloads where a full SMS workflow is unnecessary.

```powershell
robocopy \\source\share \\target\share /MIR /ZB /R:3 /W:5 /COPY:DATSO /DCOPY:DAT /MT:16 /LOG:robocopy.log
```

Recommended sequence:

1. Run an initial sync during business hours
2. Review file counts, skipped files, and permissions results
3. Repeat one or more delta syncs before cutover
4. Stop application/file writes during the final sync
5. Repoint users or dependent services to the Azure Local target

## Option B — Application-native migration

### SQL Server

1. Provision the target Azure Local SQL VM and install the required SQL version
2. Back up user databases on the source system to the approved backup location
3. Restore databases on the target SQL instance
4. Recreate or validate logins, SQL Agent jobs, linked servers, and maintenance plans
5. Update application connection strings or listeners
6. Run application and database smoke tests with the application owner

### IIS / Windows application workloads

1. Provision and harden the target VM
2. Install required roles/features and application dependencies
3. Export or document IIS bindings, application pools, certificates, and service identities
4. Copy application content and import configuration to the target
5. Validate site bindings, certificates, and service startup
6. Cut over DNS / load balancer entries

### Linux / database-native workloads

1. Provision the target Linux VM on Azure Local
2. Install runtime packages, agents, and monitoring tools
3. Use `rsync`, database-native dump/restore, or app-native replication to move state
4. Validate service unit files, mount points, SELinux/AppArmor policy, and firewall rules
5. Cut over application traffic and monitor for post-cutover errors

## Option C — Carbonite Migrate

1. Install the Carbonite Migrate agent on the source VM
2. Install the Carbonite Migrate agent on the pre-built target Azure Local VM
3. Create the source-to-target migration job in Carbonite
4. Allow the initial mirror to complete
5. Let continuous replication run until the cutover window
6. Initiate cutover, perform final validation, then hold the source for rollback coverage

## Cutover checklist

- [ ] Final delta sync complete
- [ ] Application owner present for validation
- [ ] DNS/load balancer change window active
- [ ] Source writes stopped or controlled
- [ ] Target application healthy before user traffic is restored

## Cleanup

1. Keep the source VM powered off or isolated during the hold period
2. Document final target IP, DNS, and service changes
3. Remove temporary migration tooling and accounts if no longer needed
4. Decommission the Nutanix source only after sign-off and rollback window closure