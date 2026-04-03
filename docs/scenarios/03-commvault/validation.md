# Commvault Migration Path — Validation & Checklist

> Validation steps for each migration hop and the complete pre-migration checklist.

---

## Hop 1 Validation — Hyper-V Staging

After the Commvault restore, validate each VM before proceeding to Azure Migrate:

| Check | Command / Method | Expected Result |
|-------|------------------|-----------------|
| VM boots | Hyper-V Manager — check VM state | Running |
| Network connectivity | `ping <gateway>` from VM | Successful |
| IP address correct | `ipconfig /all` / `ip addr` | Matches expected (or new IP if re-IPed) |
| DNS resolution | `nslookup <hostname>` | Resolves correctly |
| AD domain membership | `Test-ComputerSecureChannel` | True |
| Services running | `Get-Service` / `systemctl status` | Expected services active |
| Application smoke test | Browser / curl / DB query | Expected response |
| Disk integrity | Event Viewer / `dmesg` | No disk errors |

---

## Hop 2 Validation — Azure Local

After Azure Migrate cutover, repeat all Hop 1 checks plus:

| Check | Method | Expected Result |
|-------|--------|-----------------|
| Azure Local VM status | Azure portal -> Azure Local -> VMs | Connected |
| Azure Monitor agent | Azure portal -> Monitor -> Agents | Reporting |
| Defender for Cloud | Azure portal -> Defender | VM visible, no critical alerts |
| Update Manager | Azure portal -> Update Manager | VM inventoried |
| DNS (if re-IPed) | `nslookup <hostname>` from multiple clients | Resolves to correct IP |
| Application sign-off | App owner full functional test | Pass |

---

## Rollback Decision Points

| Stage | Rollback Action |
|-------|-----------------|
| After restore to Hyper-V — validation fails | Power off restored VMs -> power source Nutanix VMs back on |
| After Azure Migrate test migration — issues found | Clean up test VMs; source VMs still safe on Nutanix |
| After Azure Migrate cutover — issues found | Power source Nutanix VMs back on while target issues are remediated |

!!! danger "Never delete source VMs until holding period expires"
    Maintain source Nutanix VMs powered off for at least 2-4 weeks after Azure Local validation. Only decommission after the holding period.

---

## Pre-Migration Checklist

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| Commvault release and module support confirmed | ☐ | Infra | Validate AHV or ESXi workflow |
| Commvault control plane healthy | ☐ | Infra | No service degradation |
| Media or worker components sized for batch | ☐ | Infra | Throughput confirmed |
| Commvault storage target tested | ☐ | Infra | Capacity available |
| Hyper-V staging target provisioned | ☐ | Infra | Storage and switch mapping verified |
| Restore workflow validated in pilot | ☐ | Infra | One representative VM completed end-to-end |
| Re-IP procedure prepared and tested | ☐ | Infra | Only if staging subnet differs |
| Azure Migrate project created | ☐ | Cloud | Subscription and RG selected |
| Azure Migrate appliance deployed and registered | ☐ | Cloud | Discovery complete |
| Azure Local cluster healthy and integrated | ☐ | Infra | CSV capacity available |
| Network ports open between all components | ☐ | Networking | See prerequisites table |
| VM inventory sorted into batches | ☐ | Migration Lead | Batch spreadsheet complete |
| IP and VLAN mapping complete | ☐ | Networking | Source to target for all VMs |
| Application baselines documented | ☐ | App Owners | Services and smoke tests captured |
| Rollback procedure tested | ☐ | All | Source VM power-on verified |