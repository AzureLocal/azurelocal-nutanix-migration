// ─── Azure Migrate Project Module ─────────────────────────────────────────────
// Organization: Infinite Improbability Corp (IIC)

@description('Azure Migrate project name.')
param projectName string

@description('Azure region.')
param location string

@description('Tags.')
param tags object = {}

resource migrateProject 'Microsoft.Migrate/migrateProjects@2020-05-01' = {
  name: projectName
  location: location
  tags: tags
  properties: {}
}

output projectName string = migrateProject.name
output projectId string = migrateProject.id
