targetScope = 'subscription'

var requiredTags = [
  {
    name: 'Environment'
    assignmentName: 'memo-tag-environment'
  }
  {
    name: 'Owner'
    assignmentName: 'memo-tag-owner'
  }
  {
    name: 'CostCenter'
    assignmentName: 'memo-tag-costcenter'
  }
]

resource requiredTagPolicy 'Microsoft.Authorization/policyDefinitions@2025-03-01' = {
  name: 'memo-audit-required-tag'
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'MEMO Audit required enterprise tag'
    description: 'Audits taggable Azure resources that are missing a required enterprise governance tag.'
    metadata: {
      category: 'Tags'
      version: '1.0.0'
      project: 'MEMO Foundation'
    }
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Required tag name'
          description: 'Name of the enterprise tag that resources must contain.'
        }
      }
    }
    policyRule: {
      if: {
        field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
        exists: 'false'
      }
      then: {
        effect: 'audit'
      }
    }
  }
}

resource requiredTagAssignments 'Microsoft.Authorization/policyAssignments@2025-03-01' = [
  for requiredTag in requiredTags: {
    name: requiredTag.assignmentName
    properties: {
      displayName: 'MEMO Audit ${requiredTag.name} tag'
      description: 'Audits Azure resources missing the ${requiredTag.name} enterprise tag.'
      enforcementMode: 'Default'
      policyDefinitionId: requiredTagPolicy.id
      parameters: {
        tagName: {
          value: requiredTag.name
        }
      }
      nonComplianceMessages: [
        {
          message: 'Resource is missing the required ${requiredTag.name} tag.'
        }
      ]
    }
  }
]

output policyDefinitionId string = requiredTagPolicy.id
output requiredTags array = [for requiredTag in requiredTags: requiredTag.name]
output policyEffect string = 'audit'
