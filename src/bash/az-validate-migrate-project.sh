#!/usr/bin/env bash
# az-validate-migrate-project.sh
# Validates that the Azure Migrate project exists and is accessible.
# Usage: ./az-validate-migrate-project.sh [--config <path>] [--subscription <id>]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="${SCRIPT_DIR}/../../config/variables/variables.yml"
SUBSCRIPTION_ID=""

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)      CONFIG_PATH="$2";      shift 2 ;;
    --subscription) SUBSCRIPTION_ID="$2"; shift 2 ;;
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
LOCATION=$(yq       '.azure.location'              "$CONFIG_PATH" | tr -d '"')

if [[ -n "$SUBSCRIPTION_ID" ]]; then
  az account set --subscription "$SUBSCRIPTION_ID"
fi

echo "Validating Azure Migrate project..."
echo "  Resource Group : $RESOURCE_GROUP"
echo "  Project Name   : $PROJECT_NAME"
echo "  Location       : $LOCATION"
echo ""

# ---------------------------------------------------------------------------
# Validate resource group exists
# ---------------------------------------------------------------------------
if ! az group show --name "$RESOURCE_GROUP" --output none 2>/dev/null; then
  echo "ERROR: Resource group '$RESOURCE_GROUP' not found." >&2
  exit 1
fi
echo "[OK] Resource group '$RESOURCE_GROUP' exists."

# ---------------------------------------------------------------------------
# Validate Azure Migrate project exists
# ---------------------------------------------------------------------------
PROJECT_JSON=$(az resource show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PROJECT_NAME" \
  --resource-type "Microsoft.Migrate/MigrateProjects" \
  --output json 2>/dev/null || true)

if [[ -z "$PROJECT_JSON" ]]; then
  echo "ERROR: Azure Migrate project '$PROJECT_NAME' not found in '$RESOURCE_GROUP'." >&2
  exit 1
fi

echo "[OK] Azure Migrate project '$PROJECT_NAME' exists."
echo ""
echo "Validation complete."
