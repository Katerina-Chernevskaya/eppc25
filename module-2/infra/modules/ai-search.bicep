// params

@description('AI Search name')
param name string

@description('Resource Location')
param location string

@description('Tags')
param tags object

@description('Storage Account')
param storageName string

// resource

resource aiSearch 'Microsoft.Search/searchServices@2025-02-01-Preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource existStorageAcc 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: storageName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiSearch.id, 'StorageBlobDataReader')
  scope: existStorageAcc
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: aiSearch.identity.principalId
  }
}

// outputs
output name string = aiSearch.name
output id string = aiSearch.id
