# Ansible — Nutanix to Azure Local Migration

Ansible playbooks and roles for orchestrating VM migration from Nutanix (AHV) to Azure Local (Hyper-V).

## Structure

```
src/ansible/
├── ansible.cfg                         # Ansible configuration
├── requirements.yml                    # Collection dependencies
├── inventory/
│   └── hosts.example.yml               # Inventory example (copy to hosts.yml)
├── playbooks/
│   ├── site.yml                        # Master playbook — runs all phases
│   ├── preflight.yml                   # Phase 1: pre-migration validation
│   ├── veeam-migration.yml             # Phase 2a: Veeam-based migration
│   ├── hycu-migration.yml              # Phase 2b: HYCU-based migration
│   └── validate.yml                    # Phase 3: post-migration validation
└── roles/
    ├── migration-preflight/            # Hyper-V role, switch, staging dir, disk space
    ├── migration-veeam/                # Veeam REST API — list replica jobs
    ├── migration-hycu/                 # HYCU REST API — cluster info, VM list
    ├── migration-azure-migrate/        # Azure Migrate project validation via az CLI
    ├── migration-reip/                 # Re-IP VMs after migration
    └── migration-validation/           # Domain join, DNS, and service validation
```

## Prerequisites

- Ansible 2.14 or later
- Python 3.10 or later
- WinRM configured on all target Hyper-V hosts
- Azure CLI installed and authenticated (for `migration-azure-migrate` role)

## Install Collections

```bash
ansible-galaxy collection install -r src/ansible/requirements.yml
```

## Configuration

Copy the example inventory and update with your environment values:

```bash
cp src/ansible/inventory/hosts.example.yml src/ansible/inventory/hosts.yml
```

Update `config/variables/variables.yml` with your environment-specific values. All roles read configuration from the inventory variables derived from the central config.

## Usage

Run full migration workflow:

```bash
ansible-playbook src/ansible/playbooks/site.yml -i src/ansible/inventory/hosts.yml
```

Run individual phases:

```bash
# Preflight only
ansible-playbook src/ansible/playbooks/preflight.yml -i src/ansible/inventory/hosts.yml

# Veeam migration
ansible-playbook src/ansible/playbooks/veeam-migration.yml -i src/ansible/inventory/hosts.yml

# HYCU migration
ansible-playbook src/ansible/playbooks/hycu-migration.yml -i src/ansible/inventory/hosts.yml

# Post-migration validation
ansible-playbook src/ansible/playbooks/validate.yml -i src/ansible/inventory/hosts.yml
```

Dry run (check mode):

```bash
ansible-playbook src/ansible/playbooks/site.yml -i src/ansible/inventory/hosts.yml --check --diff
```

## Roles

| Role | Description |
|------|-------------|
| `migration-preflight` | Validates Hyper-V role, vSwitch, staging directory, and disk space |
| `migration-veeam` | Authenticates to Veeam REST API and lists replica jobs |
| `migration-hycu` | Authenticates to HYCU REST API and retrieves VM list |
| `migration-azure-migrate` | Validates Azure Migrate project exists via Azure CLI |
| `migration-reip` | Applies new IP/DNS configuration to migrated VMs |
| `migration-validation` | Validates domain membership, DNS resolution, and critical services |

## Example Inventory (IIC)

```yaml
all:
  children:
    hyperv_hosts:
      hosts:
        hyperv-staging.iic.local:
          ansible_user: IMPROBABLE\ansibleadmin
          ansible_connection: winrm
          ansible_winrm_transport: kerberos
    migrated_vms:
      hosts:
        vm-web-01.iic.local: {}
        vm-app-01.iic.local: {}
```

## Related

- [PowerShell scripts](../powershell/README.md) — orchestration scripts for the same migration phases
- [Terraform](../terraform/README.md) — infrastructure provisioning
- [Bicep](../bicep/README.md) — alternative ARM-native infrastructure provisioning
