# ARM Templates — Nutanix to Azure Local Migration

ARM (Azure Resource Manager) templates for migration infrastructure deployment.
Subscription-scoped: creates the resource group and nested deployments within it.

## Files

- `azuredeploy.json` — Main ARM template (subscription scope)
- `azuredeploy.parameters.example.json` — Example parameters — copy and populate

## Usage

```bash
# 1. Copy and populate parameters
cp azuredeploy.parameters.example.json azuredeploy.parameters.json

# 2. Deploy via Azure CLI
az deployment sub create \
  --location eastus \
  --template-file azuredeploy.json \
  --parameters azuredeploy.parameters.json \
  --subscription 00000000-0000-0000-0000-000000000000

# 3. What-if (dry run)
az deployment sub what-if \
  --location eastus \
  --template-file azuredeploy.json \
  --parameters azuredeploy.parameters.json
```

## Notes

- For new deployments, prefer the Bicep templates in `src/bicep/` — they are more readable and maintainable.
- ARM templates are provided here for environments where Bicep is not available or policy requires ARM JSON.
