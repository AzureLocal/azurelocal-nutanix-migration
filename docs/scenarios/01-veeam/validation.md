# Veeam Migration Path — Validation & Checklist

> Validation steps for each migration hop and the complete pre-migration checklist.

---

## Hop 1 Validation — Hyper-V Staging

After Veeam failover, validate each VM before committing:

| Check | Command / Method | Expected Result |
|-------|-----------------|-----------------|
| VM boots | Hyper-V Manager — check VM state | Running |
| Network connectivity | `ping <gateway>` from inside VM | Successful |
| DNS resolution | `nslookup <hostname>` | Resolves to correct IP |
| AD domain membership | `Test-ComputerSecureChannel` (Windows) | True |
| Services running | `Get-Service` / `systemctl status` | Expected services active |
| Application smoke test | Browser/curl to app URL or DB query | Expected response |
| Disk integrity | Check Event Viewer or `dmesg` for disk errors | No errors |

!!! tip "Document your baseline"
    Before starting any migration, record the expected state for each VM (IP, service list, app test URL/query). This becomes your validation checklist post-migration.

---

## Hop 2 Validation — Azure Local

After Azure Migrate cutover, repeat all Hop 1 checks plus:

| Check | Method | Expected Result |
|-------|--------|-----------------|
| Arc status | Azure portal → Azure Local → VMs | Connected |
| Azure Monitor agent | Azure portal → Monitor → Agents | Reporting |
| Defender for Cloud | Azure portal → Defender for Cloud | VM appears, no critical alerts |
| Update Manager | Azure portal → Update Manager | VM inventoried |
| DNS (if re-IPed) | `nslookup <hostname>` from multiple clients | Resolves to new IP |
| SPN registration | `setspn -L <computer-account>` | SPNs intact for SQL/IIS services |
| Kerberos authentication | Test app login with domain account | Successful |
| Application sign-off | App owner performs full functional test | Pass |

---

## IP and DNS Verification

=== "Preserved IPs (same VLAN)"

    - `ipconfig /all` (Windows) or `ip addr` (Linux) — verify IP matches expected
    - `nslookup <hostname>` — verify forward DNS resolves to correct IP
    - `nslookup <ip>` — verify reverse DNS (PTR) resolves to correct hostname
    - From other servers: ping by hostname to verify DNS propagation

=== "Re-IPed (new subnet via Veeam re-IP rules)"

    - Verify new IP assigned correctly after Veeam failover
    - Update DNS A records: `Set-DnsServerResourceRecord` or via DNS Manager
    - Update PTR records (reverse zone)
    - Flush DNS caches on key servers: `ipconfig /flushdns` (Windows), `systemd-resolve --flush-caches` (Linux)
    - Verify SPN registrations if SQL Server, IIS with Windows Auth, or other Kerberos services are present

---

## Rollback Decision Points

| Stage | Rollback Action |
|-------|----------------|
| After Veeam failover — validation fails | **Undo Failover** in Veeam → source AHV VMs power back on |
| After Commit Failover — Azure Migrate test fails | Power off Azure Local test VMs, restore source AHV VMs from Nutanix snapshots |
| After Azure Migrate cutover — issues found | Open source AHV VMs (still powered off, not deleted) and power them back on |

!!! danger "Never delete source VMs until holding period expires"
    Maintain source Nutanix VMs in a powered-off state for a defined holding period (typically 2–4 weeks per batch) after Azure Local validation is complete. Only then decommission them permanently.

---

## Pre-Migration Checklist

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| Veeam B&R v12+ installed | ☐ | Infra | Confirm version |
| Veeam licensed (VUL count confirmed) | ☐ | Infra | Minimum 10 VUL for rolling batches |
| Nutanix AHV/ESXi added to Veeam | ☐ | Infra | AHV proxy deployed and healthy |
| Hyper-V staging host(s) added to Veeam | ☐ | Infra | Transport service installed |
| Hyper-V storage sized and available | ☐ | Infra | ≥ used disk of largest batch |
| Azure Migrate project created | ☐ | Cloud | Subscription + RG selected |
| Azure Migrate appliance deployed | ☐ | Cloud | Registered, discovery complete |
| Azure Local cluster healthy | ☐ | Infra | Arc-registered, CSV capacity available |
| Network ports verified open | ☐ | Networking | All ports in prerequisites table |
| VM inventory sorted into batches | ☐ | Migration Lead | Batch spreadsheet complete |
| IP/VLAN mapping spreadsheet complete | ☐ | Networking | Source → target for all VMs |
| DNS TTLs lowered (if re-IPing) | ☐ | Networking | Set to 300 seconds, 48 hours before Batch 1 |
| Application baseline documented per VM | ☐ | App Owners | IPs, services, smoke test procedure |
| Rollback procedure documented and tested | ☐ | All | Undo Failover confirmed working |
| Stakeholder maintenance windows approved | ☐ | PM | Per-batch windows scheduled |
| Source VM holding period policy agreed | ☐ | All | Minimum 2 weeks recommended |
