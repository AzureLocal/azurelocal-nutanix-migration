// ─── Key Vault Module ─────────────────────────────────────────────────────────
// Organization: Infinite Improbability Corp (IIC)

@description('Key Vault name.')
param name string

@description('Azure region.')
param location string

@description('Tags.')
param tags object = {}

var tenantId = subscription().tenantId

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: null  // allow purge for dev/migration use
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

output name string = keyVault.name
output id string = keyVault.id
output uri string = keyVault.properties.vaultUri
