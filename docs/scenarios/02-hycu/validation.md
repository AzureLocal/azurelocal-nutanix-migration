# HYCU Migration Path — Validation & Checklist

> Validation steps for each migration hop and the complete pre-migration checklist.

---

## Hop 1 Validation — Hyper-V Staging

After HYCU restore, validate each VM before proceeding to Azure Migrate:

| Check | Command / Method | Expected Result |
|-------|-----------------|-----------------|
| VM boots | Hyper-V Manager — check VM state | Running |
| Network connectivity | `ping <gateway>` from VM | Successful |
| IP address correct | `ipconfig /all` / `ip addr` | Matches expected (or new IP if re-IPed) |
| DNS resolution | `nslookup <hostname>` | Resolves correctly |
| AD domain membership | `Test-ComputerSecureChannel` | True |
| Services running | `Get-Service` / `systemctl status` | Expected services active |
| Application smoke test | Browser / curl / DB query | Expected response |
| Disk integrity | Event Viewer / `dmesg` | No disk errors |

!!! tip "Re-IP verification"
    If subnets differ and you ran the re-IP script, verify the correct IP was applied before testing connectivity. Run `ipconfig /all` (Windows) or `ip addr show` (Linux) to confirm.

---

## Hop 2 Validation — Azure Local

After Azure Migrate cutover, repeat all Hop 1 checks plus:

| Check | Method | Expected Result |
|-------|--------|-----------------|
| Arc status | Azure portal → Azure Local → VMs | Connected |
| Azure Monitor agent | Azure portal → Monitor → Agents | Reporting |
| Defender for Cloud | Azure portal → Defender | VM visible, no critical alerts |
| Update Manager | Azure portal → Update Manager | VM inventoried |
| DNS (if re-IPed) | `nslookup <hostname>` from multiple clients | Resolves to correct IP |
| Kerberos / SPN | `setspn -L <computer-account>` | Intact for SQL/IIS services |
| Application sign-off | App owner full functional test | Pass |

---

## Rollback Decision Points

| Stage | Rollback Action |
|-------|----------------|
| After HYCU restore to Hyper-V — validation fails | Delete restored HV VMs → power source Nutanix VMs back on |
| After Azure Migrate test migration — issues found | Clean up test VMs; source VMs still safe on Nutanix (powered off) |
| After Azure Migrate cutover — issues found | Power source Nutanix VMs back on (they are powered off, not deleted) |

!!! danger "Never delete source VMs until holding period expires"
    Maintain source Nutanix VMs powered-off for at least 2–4 weeks after Azure Local validation. Only decommission after the holding period.

---

## Pre-Migration Checklist

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| HYCU controller VM deployed on AHV cluster | ☐ | Infra | 4 vCPU / 8 GB RAM / static IP |
| HYCU licensed and activated | ☐ | Infra | Confirm VM count or socket licensing |
| Nutanix AHV/ESXi cluster added as HYCU source | ☐ | Infra | All VMs discovered |
| HYCU backup target configured and tested | ☐ | Infra | SMB/NFS/S3 with sufficient capacity |
| Hyper-V staging host(s) provisioned | ☐ | Infra | Hyper-V role, virtual switches, storage |
| Hyper-V registered as HYCU restore target | ☐ | Infra | Credentials and storage path verified |
| Re-IP script prepared and tested | ☐ | Infra | Only if staging subnet differs from source |
| Azure Migrate project created | ☐ | Cloud | Subscription + RG selected |
| Azure Migrate appliance deployed and registered | ☐ | Cloud | Discovery complete |
| Azure Local cluster healthy and Arc-registered | ☐ | Infra | CSV capacity available |
| Network ports open between all components | ☐ | Networking | See prerequisites table |
| VM inventory sorted into batches | ☐ | Migration Lead | Batch spreadsheet complete |
| IP/VLAN mapping complete | ☐ | Networking | Source → target for all VMs |
| DNS TTLs lowered (if re-IPing) | ☐ | Networking | Set to 300s, 48 hours before Batch 1 |
| Application baselines documented | ☐ | App Owners | IPs, services, smoke test procedures |
| Rollback procedure tested | ☐ | All | Verified: delete HV restore → power AHV back on |
| Stakeholder maintenance windows approved | ☐ | PM | Per-batch windows scheduled |
| Source VM holding period policy agreed | ☐ | All | Minimum 2 weeks recommended |
