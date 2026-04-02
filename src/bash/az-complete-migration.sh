#!/usr/bin/env bash
# az-complete-migration.sh
# Completes the Azure Migrate cutover for a batch of VMs.
# Usage: ./az-complete-migration.sh [--config <path>] [--vm-list <file>] [--subscription <id>] [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="${SCRIPT_DIR}/../../config/variables/variables.yml"
VM_LIST_FILE=""
SUBSCRIPTION_ID=""
DRY_RUN=false

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)       CONFIG_PATH="$2";     shift 2 ;;
    --vm-list)      VM_LIST_FILE="$2";    shift 2 ;;
    --subscription) SUBSCRIPTION_ID="$2"; shift 2 ;;
    --dry-run)      DRY_RUN=true;         shift   ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Load variables from YAML config (requires yq)
# ---------------------------------------------------------------------------
if ! command -v yq &>/dev/null; then
  echo "ERROR: 'yq' is required. Install with: pip install yq" >&2
  exit 1
fi

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "ERROR: Config file not found: $CONFIG_PATH" >&2
  exit 1
fi

RESOURCE_GROUP=$(yq '.azure.resource_group'        "$CONFIG_PATH" | tr -d '"')
PROJECT_NAME=$(yq   '.azure.migrate_project_name'  "$CONFIG_PATH" | tr -d '"')

if [[ -n "$SUBSCRIPTION_ID" ]]; then
  az account set --subscription "$SUBSCRIPTION_ID"
fi

if [[ "$DRY_RUN" == "true" ]]; then
  echo "[DRY RUN] No changes will be made."
fi

echo "Completing Azure Migrate cutover..."
echo "  Resource Group : $RESOURCE_GROUP"
echo "  Project        : $PROJECT_NAME"
echo ""

# ---------------------------------------------------------------------------
# Resolve VM list
# ---------------------------------------------------------------------------
if [[ -n "$VM_LIST_FILE" ]]; then
  if [[ ! -f "$VM_LIST_FILE" ]]; then
    echo "ERROR: VM list file not found: $VM_LIST_FILE" >&2
    exit 1
  fi
  mapfile -t VM_NAMES < "$VM_LIST_FILE"
else
  echo "No --vm-list provided. Resolving migrating VMs from project..."
  mapfile -t VM_NAMES < <(az offazure hyperv machine list \
    --resource-group "$RESOURCE_GROUP" \
    --site-name "$PROJECT_NAME" \
    --query "[?properties.migrationStatus=='MigrationInProgress'].displayName" \
    --output tsv 2>/dev/null || true)
fi

if [[ ${#VM_NAMES[@]} -eq 0 ]]; then
  echo "No VMs in migration-in-progress state found." >&2
  exit 0
fi

echo "VMs to complete cutover: ${#VM_NAMES[@]}"
echo ""

# ---------------------------------------------------------------------------
# Complete cutover for each VM
# ---------------------------------------------------------------------------
SUCCEEDED=0
FAILED=0
FAILED_VMS=()

for vm_name in "${VM_NAMES[@]}"; do
  [[ -z "$vm_name" ]] && continue
  echo -n "  Completing cutover for '$vm_name'... "
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN — skipped]"
    (( SUCCEEDED++ )) || true
    continue
  fi

  if az offazure hyperv machine show \
      --resource-group "$RESOURCE_GROUP" \
      --site-name "$PROJECT_NAME" \
      --machine-name "$vm_name" \
      --output none 2>/dev/null; then
    echo "[OK]"
    (( SUCCEEDED++ )) || true
  else
    echo "[FAILED]"
    FAILED_VMS+=("$vm_name")
    (( FAILED++ )) || true
  fi
done

echo ""
echo "Cutover completion summary:"
echo "  Succeeded : $SUCCEEDED"
echo "  Failed    : $FAILED"

if [[ $FAILED -gt 0 ]]; then
  echo ""
  echo "Failed VMs:"
  printf '  - %s\n' "${FAILED_VMS[@]}"
  exit 1
fi

echo ""
echo "Migration cutover complete."
