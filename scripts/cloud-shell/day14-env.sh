# Source this file after every new Azure Cloud Shell session.

export LAB_RG="MEMO-RG-Monitoring"
export LAB_WS="MEMO-LAW-SENTINEL"

export LAB_SUB
LAB_SUB=$(az account show --query id --output tsv)

export LAB_WS_ID
LAB_WS_ID=$(az monitor log-analytics workspace show \
  --resource-group "$LAB_RG" \
  --workspace-name "$LAB_WS" \
  --query customerId \
  --output tsv)

export LAB_SENTINEL_BASE
LAB_SENTINEL_BASE="https://management.azure.com/subscriptions/$LAB_SUB/resourceGroups/$LAB_RG/providers/Microsoft.OperationalInsights/workspaces/$LAB_WS/providers/Microsoft.SecurityInsights"

export RBAC_RULE_ID="6494dd57-2182-49d2-872d-eef45cca279f"
export FAILED_RULE_ID="94997897-bd92-417e-a0df-61ad58fecd5b"
export KEYVAULT_RULE_ID="cbba06d6-b44c-4dd8-b785-f5a4878d4a71"

export RBAC_RULE_URL="$LAB_SENTINEL_BASE/alertRules/$RBAC_RULE_ID?api-version=2025-09-01"
export FAILED_RULE_URL="$LAB_SENTINEL_BASE/alertRules/$FAILED_RULE_ID?api-version=2025-09-01"
export KEYVAULT_RULE_URL="$LAB_SENTINEL_BASE/alertRules/$KEYVAULT_RULE_ID?api-version=2025-09-01"

echo "Day 14 environment loaded."
echo "Subscription loaded: $([ -n "$LAB_SUB" ] && echo yes || echo no)"
echo "Workspace loaded: $([ -n "$LAB_WS_ID" ] && echo yes || echo no)"
