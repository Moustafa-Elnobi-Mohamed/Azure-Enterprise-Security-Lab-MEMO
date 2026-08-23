targetScope = 'resourceGroup'

@description('Existing Log Analytics workspace containing Microsoft Sentinel.')
param workspaceName string = 'MEMO-LAW-SENTINEL'

@description('Stable identifier for this automation rule.')
param automationRuleId string = '2f628e0f-9d56-4c5f-bf1e-f3d0e8214f14'

param rbacRuleId string = '6494dd57-2182-49d2-872d-eef45cca279f'
param failedOperationRuleId string = '94997897-bd92-417e-a0df-61ad58fecd5b'
param keyVaultRuleId string = 'cbba06d6-b44c-4dd8-b785-f5a4878d4a71'

resource workspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: workspaceName
}

resource incidentTriage 'Microsoft.SecurityInsights/automationRules@2025-09-01' = {
  name: automationRuleId
  scope: workspace
  properties: {
    displayName: 'MEMO - Native incident triage'
    order: 100
    triggeringLogic: {
      isEnabled: true
      triggersOn: 'Incidents'
      triggersWhen: 'Created'
      conditions: [
        {
          conditionType: 'Property'
          conditionProperties: {
            propertyName: 'IncidentRelatedAnalyticRuleIds'
            operator: 'Contains'
            propertyValues: [
              '${workspace.id}/providers/Microsoft.SecurityInsights/alertRules/${rbacRuleId}'
              '${workspace.id}/providers/Microsoft.SecurityInsights/alertRules/${failedOperationRuleId}'
              '${workspace.id}/providers/Microsoft.SecurityInsights/alertRules/${keyVaultRuleId}'
            ]
          }
        }
      ]
    }
    actions: [
      {
        order: 1
        actionType: 'ModifyProperties'
        actionConfiguration: {
          labels: [
            {
              labelName: 'MEMO-Auto-Triage'
            }
          ]
        }
      }
      {
        order: 2
        actionType: 'AddIncidentTask'
        actionConfiguration: {
          title: 'Validate MEMO security incident'
          description: 'Confirm the caller or account and source IP. Review correlation IDs, operations, affected resources, and failure details. Determine whether the activity was expected or suspicious, then document the conclusion before changing incident status.'
        }
      }
    ]
  }
}

output automationRuleName string = incidentTriage.name
output automationRuleEnabled bool = incidentTriage.properties.triggeringLogic.isEnabled
