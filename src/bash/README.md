# Bash — Nutanix to Azure Local Migration

Azure CLI shell scripts for managing Azure Migrate operations during the Nutanix to Azure Local migration.

## Structure

```
src/bash/
├── az-validate-migrate-project.sh   # Validate Azure Migrate project exists
├── az-start-replication.sh          # Start replication for a batch of VMs
├── az-complete-migration.sh         # Complete cutover for migrated VMs
└── README.md
```

## Prerequisites

- Azure CLI 2.50 or later — `az --version`
- `yq` (YAML processor) — `pip install yq`
- Active Azure session — `az login`
- Bash 4.0 or later (macOS users: `brew install bash`)

## Configuration

All scripts read from `config/variables/variables.yml`. Copy the example if you haven't already:

```bash
cp config/examples/variables.example.yml config/variables/variables.yml
```

Update the `azure` section with your subscription, resource group, and project name.

## Usage

Make scripts executable:

```bash
chmod +x src/bash/*.sh
```

### Validate Azure Migrate Project

```bash
./src/bash/az-validate-migrate-project.sh
./src/bash/az-validate-migrate-project.sh --subscription <subscription-id>
./src/bash/az-validate-migrate-project.sh --config config/variables/variables.yml
```

### Start Replication

```bash
# Start replication for all discovered machines
./src/bash/az-start-replication.sh

# Start replication for a specific list of VMs
./src/bash/az-start-replication.sh --vm-list /path/to/vm-list.txt
```

The `--vm-list` file should contain one VM display name per line.

### Complete Migration Cutover

```bash
# Complete cutover for all in-progress VMs
./src/bash/az-complete-migration.sh

# Dry run — no changes made
./src/bash/az-complete-migration.sh --dry-run

# Complete cutover for a specific VM list
./src/bash/az-complete-migration.sh --vm-list /path/to/vm-list.txt
```

## Common Arguments

| Argument | Description |
|----------|-------------|
| `--config <path>` | Path to `variables.yml` (default: `config/variables/variables.yml`) |
| `--subscription <id>` | Azure subscription ID to target |
| `--vm-list <file>` | Text file with one VM name per line |
| `--dry-run` | Preview actions without making changes (supported by cutover script) |

## Related

- [PowerShell scripts](../powershell/README.md) — Windows-native orchestration for the same operations
- [Ansible playbooks](../ansible/README.md) — end-to-end migration automation
- [Terraform](../terraform/README.md) — infrastructure provisioning
