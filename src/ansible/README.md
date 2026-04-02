# Ansible Automation

Ansible playbooks and roles for Nutanix to Azure Local migration.

## Structure

```
ansible/
  inventory/          # Inventory files and host groups
  playbooks/          # Top-level playbooks (call roles)
    site.yml          # Full migration orchestration
    01-veeam.yml      # Veeam-path playbook
    02-hycu.yml       # HYCU-path playbook
    validate.yml      # Post-migration validation
  roles/
    migration-preflight/      # Pre-migration checks (cluster health, network ports)
    migration-veeam/          # Veeam job creation and cutover automation
    migration-hycu/           # HYCU backup policy and restore automation
    migration-azure-migrate/  # Azure Migrate appliance config and replication
    migration-reip/           # Post-restore IP/DNS remediation
    migration-validation/     # Post-migration health checks
```

## Usage

```bash
# Run pre-flight checks against all hosts
ansible-playbook -i inventory/hosts.yml playbooks/site.yml --tags preflight

# Run Veeam migration path
ansible-playbook -i inventory/hosts.yml playbooks/01-veeam.yml

# Run validation
ansible-playbook -i inventory/hosts.yml playbooks/validate.yml
```
