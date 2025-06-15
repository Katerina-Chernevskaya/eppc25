// params

@description('Azure OpenAI name')
param name string

@description('Resource Location')
param location string

@description('Tags')
param tags object

// resource

resource open_ai 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: toLower(name)
  }
}

resource open_ai_ada 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  name: '${name}-ada'
  sku: {
    capacity: 50
    name: 'Standard'
  }
  parent: open_ai
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
    raiPolicyName: 'Microsoft.Default'
    versionUpgradeOption: 'OnceCurrentVersionExpired'
  }
}

resource open_ai_gpt4o 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  name: '${name}-gpt4o'
  sku: {
    capacity: 10
    name: 'GlobalStandard'
  }
  parent: open_ai
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-11-20'
    }
    raiPolicyName: 'Microsoft.Default'
    versionUpgradeOption: 'OnceCurrentVersionExpired'
  }
  dependsOn: [
    open_ai_ada
  ]
}

// outputs
output aoi_id string = open_ai.id
output aoi_endpoint string = open_ai.properties.endpoint
output aoiName string = open_ai.name
