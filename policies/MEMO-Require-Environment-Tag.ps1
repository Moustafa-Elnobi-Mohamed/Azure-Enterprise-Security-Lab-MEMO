$PolicyName = "MEMO-Require-Environment-Tag"

$PolicyRule = @'
{
  "if": {
    "field": "tags['Environment']",
    "exists": "false"
  },
  "then": {
    "effect": "audit"
  }
}
'@

New-AzPolicyDefinition `
    -Name $PolicyName `
    -DisplayName "MEMO - Require Environment Tag" `
    -Description "MEMO resources must contain an Environment tag." `
    -Policy $PolicyRule `
    -Mode Indexed