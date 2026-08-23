targetScope = 'resourceGroup'

@description('Existing Log Analytics workspace containing Microsoft Sentinel.')
param workspaceName string = 'MEMO-LAW-SENTINEL'

@description('Stable resource identifier for the RBAC privilege-change rule.')
param rbacRuleId string = '6494dd57-2182-49d2-872d-eef45cca279f'

@description('Stable resource identifier for the failed Azure-operation rule.')
param failedOperationRuleId string = '94997897-bd92-417e-a0df-61ad58fecd5b'

@description('Stable resource identifier for the failed Key Vault-access rule.')
param keyVaultRuleId string = 'cbba06d6-b44c-4dd8-b785-f5a4878d4a71'

var rbacRuleDefinition = loadJsonContent('../../../detections/sentinel/rules/rbac-privilege-change.json')
var failedOperationDefinition = loadJsonContent('../../../detections/sentinel/rules/failed-azure-operation.json')
var keyVaultRuleDefinition = loadJsonContent('../../../detections/sentinel/rules/failed-keyvault-secret-access.json')

resource workspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: workspaceName
}

resource rbacRule 'Microsoft.SecurityInsights/alertRules@2025-09-01' = {
  name: rbacRuleId
  scope: workspace
  kind: rbacRuleDefinition.kind
  properties: rbacRuleDefinition.properties
}

resource failedOperationRule 'Microsoft.SecurityInsights/alertRules@2025-09-01' = {
  name: failedOperationRuleId
  scope: workspace
  kind: failedOperationDefinition.kind
  properties: failedOperationDefinition.properties
}

resource keyVaultRule 'Microsoft.SecurityInsights/alertRules@2025-09-01' = {
  name: keyVaultRuleId
  scope: workspace
  kind: keyVaultRuleDefinition.kind
  properties: keyVaultRuleDefinition.properties
}

output managedRuleNames array = [
  rbacRule.name
  failedOperationRule.name
  keyVaultRule.name
]
