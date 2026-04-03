# Alternative Migration Methods — Runbook

> Step-by-step execution for file-level and application-native migrations to pre-built Azure Local VMs.

---

## Common preparation

1. Create the target Azure Local VM with approved sizing
2. Join the target VM to the correct domain or identity boundary if required
3. Apply baseline configuration: patching, security tooling, monitoring, and backup policy
4. Confirm IP, DNS, firewall, and service account requirements
5. Choose the migration method that matches the workload type

---

## File and Data Migration

### Storage Migration Service (SMS)

Best for Windows file servers where full permissions, share names, and local group membership need to be transferred.

1. Deploy or identify the SMS orchestrator (Windows Admin Center or a Windows Server host with the SMS role)
2. Inventory source shares, NTFS permissions, local groups, and scheduled tasks
3. Create a new SMS transfer job in Windows Admin Center pointing from the source to the target file server
4. Run the initial inventory scan and review errors or access-denied entries
5. Start the initial transfer and monitor job health in Windows Admin Center
6. Schedule one or more delta syncs before the cutover window
7. During the cutover window:
    - Stop writes to the source (disable SMB access or put the source server in maintenance)
    - Run the final delta sync
    - Cut over share identity and, if applicable, computer name/IP via SMS
8. Validate user access from representative client systems
9. Monitor for access errors in the 24 hours following cutover

### Robocopy

Use Robocopy for simpler file-server or content-host workloads where a full SMS workflow is not required.

```powershell
robocopy \\source\share \\target\share /MIR /ZB /R:3 /W:5 /COPY:DATSO /DCOPY:DAT /MT:16 /LOG:robocopy.log
```

Recommended sequence:

1. Run an initial sync during business hours to gauge transfer time and error rate
2. Review file counts, skipped files, and permissions results in the log
3. Repeat one or more delta syncs before the cutover window
4. During the cutover window, stop application or file writes on the source
5. Run the final sync and confirm the log shows zero errors
6. Repoint users or dependent services to the Azure Local target
7. Validate share access from representative client systems

---

## Application-Native Migration

### SQL Server

1. Provision the target Azure Local SQL VM and install the required SQL Server version and edition
2. Apply SQL Server patching and configure the SQL service account
3. Back up user databases on the source system to the approved backup location:
    ```sql
    BACKUP DATABASE [YourDatabase]
    TO DISK = '\\backup\share\YourDatabase.bak'
    WITH COMPRESSION, CHECKSUM
    ```
4. Restore databases on the target SQL instance:
    ```sql
    RESTORE DATABASE [YourDatabase]
    FROM DISK = '\\backup\share\YourDatabase.bak'
    WITH MOVE 'YourDatabase' TO 'D:\Data\YourDatabase.mdf',
         MOVE 'YourDatabase_log' TO 'D:\Logs\YourDatabase_log.ldf'
    ```
5. Recreate or script-migrate SQL logins, SQL Agent jobs, linked servers, and maintenance plans
6. Update application connection strings or SQL listeners to point to the new server
7. Run application and database smoke tests with the application owner

### IIS / Windows application workloads

1. Provision and harden the target VM on Azure Local
2. Install required Windows roles, features, and application runtime dependencies
3. Export IIS configuration from the source:
    ```powershell
    & "$env:SystemRoot\system32\inetsrv\appcmd.exe" list config /xml > iis-config-export.xml
    ```
4. Export or document application pools, bindings, certificates, and service identities
5. Copy application content to the target
6. Import IIS configuration on the target and validate bindings and application pools
7. Validate site bindings, certificates, and service startup
8. Cut over DNS or load balancer entries to the target

### Linux / database-native workloads

1. Provision the target Linux VM on Azure Local
2. Install runtime packages, agents, and monitoring tools to match the source baseline
3. Sync application data using `rsync`:
    ```bash
    rsync -avz --progress /data/ user@target:/data/
    ```
4. Use database-native dump/restore for database workloads:
    ```bash
    # PostgreSQL example
    pg_dumpall -U postgres > dump.sql
    psql -U postgres -f dump.sql   # run on target
    ```
5. Validate service unit files, mount points, and firewall rules
6. Perform a dry-run start of application services before cutting over traffic
7. Cut over application traffic and monitor for post-cutover errors

---

## Cutover checklist

- [ ] Final delta sync or backup/restore complete
- [ ] Application owner present for validation
- [ ] DNS / load balancer change window active
- [ ] Source writes stopped or controlled
- [ ] Target application healthy before user traffic is restored

## Cleanup

1. Keep the source VM powered off or isolated during the hold period
2. Document final target IP, DNS, and service configuration changes
3. Remove temporary migration tooling and accounts if no longer needed
4. Decommission the Nutanix source VM only after sign-off and rollback window closure
