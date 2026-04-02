# Network Requirements

> Comprehensive network port and firewall requirements for all migration paths.

---

## Veeam Migration Path

| Source | Destination | Protocol | Port | Description |
|--------|-------------|----------|------|-------------|
| Veeam Server | Prism Element (AHV) | HTTPS | 9440 | AHV cluster management and API |
| Veeam Server | vCenter/ESXi | HTTPS | 443 | ESXi source management |
| Veeam Server | Hyper-V Staging Host | WinRM | 5985/5986 | Remote management |
| Veeam Server | AHV Proxy VM | TCP | 2500–3300 | Veeam data channel |
| AHV Proxy VM | Prism Element | HTTPS | 9440 | Proxy → AHV API |
| AHV Proxy VM | Hyper-V Staging | TCP | 2500–3300 | Backup data transfer |
| Admin Workstation | Veeam Console | TCP | 9392 | Veeam management console |

## HYCU Migration Path

| Source | Destination | Protocol | Port | Description |
|--------|-------------|----------|------|-------------|
| HYCU Controller VM | Prism Element (AHV) | HTTPS | 9440 | AHV snapshot API |
| HYCU Controller VM | vCenter/ESXi | HTTPS | 443 | ESXi API |
| HYCU Controller VM | Backup Target (SMB) | SMB | 445 | Backup data write |
| HYCU Controller VM | Backup Target (NFS) | NFS | 2049 | Backup data write |
| HYCU Controller VM | Backup Target (S3) | HTTPS | 443 | Object storage API |
| HYCU Controller VM | Hyper-V Host (WinRM) | WinRM | 5985/5986 | Restore operations |
| Admin Workstation | HYCU Web UI | HTTPS | 8443 | Management console |

## Azure Migrate (Both Paths)

| Source | Destination | Protocol | Port | Description |
|--------|-------------|----------|------|-------------|
| Azure Migrate Appliance | Azure | HTTPS | 443 | Control plane, metadata |
| Hyper-V Host | Azure Migrate Appliance | WinRM | 5985/5986 | VM discovery |
| Hyper-V Host | Azure Local Cluster | SMB | 445 | Replication data |
| Azure Local ARM Agent | Azure | HTTPS | 443 | Arc registration |

## Nutanix Move (Hop 1)

| Source | Destination | Protocol | Port | Description |
|--------|-------------|----------|------|-------------|
| Move Appliance | Prism Element | HTTPS | 9440 | AHV source API |
| Move Appliance | Hyper-V Target | HTTPS | 443 | Hyper-V target API |
| Move Appliance | Admin Browser | HTTPS | 443 | Move web console |

---

## Firewall Rule Summary (Minimum Required)

Apply these rules in your network/firewall for all paths:

```
# From: Contoso Management VLAN → Nutanix Management VLAN
Allow TCP 9440  # Prism Element HTTPS

# From: Migration VLAN → Hyper-V Staging VLAN
Allow TCP 5985, 5986  # WinRM
Allow TCP 2500-3300   # Veeam data channel
Allow TCP 445         # SMB (backup target, Azure Migrate replication)

# From: Migration VLAN → Internet / Azure
Allow TCP 443 outbound  # Azure Migrate, Arc, Azure portal

# From: Admin VLAN → Migration VLAN
Allow TCP 8443  # HYCU web console
Allow TCP 9392  # Veeam console
```

## Network Validation Commands

Run these before starting any migration batch:

```powershell
# Test Prism Element connectivity
Test-NetConnection -ComputerName prism.contoso.local -Port 9440

# Test Hyper-V WinRM
Test-WSMan -ComputerName hyperv-staging.contoso.local

# Test SMB (backup target or Azure Local)
Test-NetConnection -ComputerName fileserver.contoso.local -Port 445

# Test Azure connectivity from appliance
Test-NetConnection -ComputerName login.microsoftonline.com -Port 443
Test-NetConnection -ComputerName management.azure.com -Port 443
```
