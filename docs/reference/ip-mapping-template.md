# IP Mapping Template

> Template for tracking IP/hostname changes across the migration. Fill in before starting each batch.

---

## Instructions

1. Copy this template to a spreadsheet before starting the PoC or production migration
2. One row per VM
3. Complete columns A–G for all VMs before starting any batch
4. Use this as input to Veeam re-IP rules, HYCU post-restore scripting, Commvault post-restore network changes, or Carbonite/deploy-first cutover planning
5. After cutover, confirm columns H–I and record actual values

---

## IP Mapping Table

| # | VM Name (Source) | VM Name (Target) | Source Network | Source IP | Target Network | Target IP | Subnet Mask | DNS Server 1 | DNS Server 2 | Default GW | Cutover Date | Validated |
|---|-----------------|-----------------|---------------|-----------|---------------|-----------|-------------|-------------|-------------|-----------|:---:|:---:|
| 1 | | | | | | | | | | | | ☐ |
| 2 | | | | | | | | | | | | ☐ |
| 3 | | | | | | | | | | | | ☐ |
| 4 | | | | | | | | | | | | ☐ |
| 5 | | | | | | | | | | | | ☐ |
| 6 | | | | | | | | | | | | ☐ |
| 7 | | | | | | | | | | | | ☐ |
| 8 | | | | | | | | | | | | ☐ |
| 9 | | | | | | | | | | | | ☐ |
| 10 | | | | | | | | | | | | ☐ |

---

## DNS Record Changes

Record DNS updates required at cutover time:

| Record Name | Record Type | Old Value | New Value | TTL Before | TTL After | Updated |
|------------|------------|----------|----------|:---:|:---:|:---:|
| | A | | | 3600 | 300 | ☐ |
| | PTR | | | 3600 | 300 | ☐ |
| | CNAME | | | 3600 | 300 | ☐ |

---

## SPN / Kerberos Tracking

If any VMs are SQL Servers or host services with SPNs, track them here:

| VM | SPN Value | Exists Before | Verified After | Action |
|----|-----------|:---:|:---:|--------|
| | MSSQLSvc/hostname:1433 | ☐ | ☐ | |
| | MSSQLSvc/hostname.domain.com:1433 | ☐ | ☐ | |
| | HTTP/hostname | ☐ | ☐ | |

After re-IP, run:
```powershell
# Verify SPN
setspn -L <computer-account>

# Re-register SPN if needed
setspn -S MSSQLSvc/<new-hostname>:1433 <domain>\<service-account>
```

---

## Naming Examples (IIC Standard)

Use the IIC naming convention for all target VMs on Azure Local:

```
Format:  <site>-<role>-<##>
Example: azlocal-iic-web-01
         azlocal-iic-sql-01
         azlocal-iic-app-01
         azlocal-iic-dc-01
```

Resource groups: `rg-iic-<purpose>-<##>`  
Example: `rg-iic-migration-01`, `rg-iic-production-01`
