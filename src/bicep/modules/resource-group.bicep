// ─── Resource Group Module ─────────────────────────────────────────────────────
// Organization: Infinite Improbability Corp (IIC)

targetScope = 'subscription'

@description('Resource group name.')
param name string

@description('Azure region.')
param location string

@description('Tags.')
param tags object = {}

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: name
  location: location
  tags: tags
}

output name string = rg.name
output id string = rg.id
