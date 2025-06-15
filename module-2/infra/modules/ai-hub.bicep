// params

@description('AI Hub name')
param nameAiHub string
param aiProjectName string

@description('Resource Location')
param location string

@description('Tags')
param tags object

param aiHubFriendlyName string
param aiProjectFriendlyName string
param aiHubDescription string
param aoiID string
param aoiEndpoint string
param keyVaultID string
param storageID string
param applicationInsightsID string
param aiSearchID string
param aiSearchName string

var aiSearchTarget = 'https://${aiSearchName}.search.windows.net/'

// resource
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2025-04-01' = {
  name: nameAiHub
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: aiHubFriendlyName
    description: aiHubDescription

    // dependent resources
    keyVault: keyVaultID
    storageAccount: storageID
    applicationInsights: applicationInsightsID
  }
  kind: 'hub'

  // Azure OpenAI connection
  resource aoiServicesConnection 'connections@2025-04-01' = {
    name: '${nameAiHub}-connection-AzureOpenAI'
    properties: {
      category: 'AzureOpenAI'
      target: aoiEndpoint
      authType: 'ApiKey'
      isSharedToAll: true
      credentials: {
        key: '${listKeys(aoiID, '2024-10-01').key1}'
      }
      metadata: {
        ApiType: 'Azure'
        ResourceId: aoiID
      }
    }
  }

  //AI Search connection
  resource searchConnection 'connections@2025-04-01' = {
    name: '${nameAiHub}-connection-AISearch'
    properties: {
      authType: 'ApiKey'
      category: 'CognitiveSearch'
      target: aiSearchTarget
      isSharedToAll: true
      sharedUserList: []
      credentials: {
        key: '${listAdminKeys(aiSearchID, '2025-02-01-Preview').primaryKey}'
      }
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiSearchID
        ApiVersion: '2024-05-01-preview'
        DeploymentApiVersion: '2023-11-01'
      }
    }
  }
}

resource aiHubProject 'Microsoft.MachineLearningServices/workspaces@2025-04-01' = {
  name: aiProjectName
  location: location
  kind: 'Project'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
  }
  properties: {
    friendlyName: aiProjectFriendlyName
    hubResourceId: aiHub.id
  }
  tags: tags
}

// outputs
output aiHubName string = aiHub.name
output aiProjectName string = aiHubProject.name
