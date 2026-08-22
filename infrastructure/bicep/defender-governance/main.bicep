targetScope = 'subscription'

@description('Email address that receives Microsoft Defender for Cloud security notifications.')
param securityContactEmail string

resource defenderSecurityContact 'Microsoft.Security/securityContacts@2023-12-01-preview' = {
  name: 'default'
  properties: {
    emails: securityContactEmail
    isEnabled: true
    notificationsByRole: {
      state: 'On'
      roles: [
        'Owner'
      ]
    }
    notificationsSources: [
      {
        sourceType: 'Alert'
        minimalSeverity: 'High'
      }
    ]
  }
}

output securityContactName string = defenderSecurityContact.name
output minimumAlertSeverity string = 'High'
output ownerNotificationsEnabled bool = true
