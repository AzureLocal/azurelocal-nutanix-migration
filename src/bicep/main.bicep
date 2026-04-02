// ─── Nutanix to Azure Local Migration — Infrastructure Entry Point ───────────
// Organization: Infinite Improbability Corp (IIC)
// Deploys: resource group scope resources for migration pipeline

targetScope = 'subscription'

@description('Azure region for all resources.')
param location string = 'eastus'

@description('Short environment identifier used in resource names.')
param environment string = 'iic'

@description('Numeric suffix for resource names, zero-padded (e.g. 01).')
param suffix string = '01'

@description('Azure Migrate project name.')
param migrateProjectName string = 'migrate-iic-nutanix-01'

@description('Key Vault name.')
param keyVaultName string = 'kv-iic-migration'

@description('Tags applied to all resources.')
param tags object = {
  environment: 'iic'
  project: 'nutanix-migration'
  managedBy: 'bicep'
}

// ─── Resource Group ───────────────────────────────────────────────────────────
resource migrationRG 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${environment}-migration-${suffix}'
  location: location
  tags: tags
}

// ─── Module: Key Vault ────────────────────────────────────────────────────────
module keyVault 'modules/keyvault.bicep' = {
  name: 'deploy-keyvault'
  scope: migrationRG
  params: {
    name: keyVaultName
    location: location
    tags: tags
  }
}

// ─── Module: Azure Migrate ────────────────────────────────────────────────────
module azureMigrate 'modules/azure-migrate.bicep' = {
  name: 'deploy-azure-migrate'
  scope: migrationRG
  params: {
    projectName: migrateProjectName
    location: location
    tags: tags
  }
}

// ─── Outputs ─────────────────────────────────────────────────────────────────
output resourceGroupName string = migrationRG.name
output keyVaultName string = keyVault.outputs.name
output keyVaultUri string = keyVault.outputs.uri
output migrateProjectName string = azureMigrate.outputs.projectName
