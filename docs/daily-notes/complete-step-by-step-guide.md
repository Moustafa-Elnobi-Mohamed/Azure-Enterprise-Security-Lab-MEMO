# MEMO Foundation: Complete Step-by-Step Build Guide

> Public, sanitized reproduction guide for the sixteen-day Azure Enterprise
> Security Lab. This guide documents what was built, how it was validated, what
> failed, how it was fixed, and what was deliberately excluded.

![MEMO Foundation enterprise security lifecycle](../architecture/memo-foundation-public-visual.svg)

## 1. Read this before running anything

The original Azure environment was decommissioned after evidence collection.
This guide is therefore a reproducible record, not a claim that the resources
are still live.

Use a dedicated training subscription and tenant. Azure pricing, free grants,
provider behavior, and portal screens can change. Review the current price of
every service before deployment, create a budget, and remove the environment
when the exercise is complete. The original project intentionally excluded paid
Defender workload plans, AKS, ACR, Logic Apps, private endpoints, and an AI
service.

Never publish:

- subscription, tenant, object, client, or principal IDs;
- personal email addresses or real tenant domains;
- passwords, secrets, tokens, access keys, or connection strings;
- public IP addresses or raw private teardown inventories;
- Terraform state, binary plan files, private keys, or credential files.

### Implementation language

| Label | Meaning |
|---|---|
| **Live** | Deployed and verified in the temporary Azure lab before teardown |
| **CI validated** | Built or statically validated in GitHub Actions without a live deployment |
| **Validated design** | Tested as code or in a temporary training environment, but not deployed as the claimed production Azure service |
| **Design-only** | Architecture and threat-model work, with no service deployment |
| **Decommissioned** | Removed after the final evidence and validation were captured |

Never claim that AKS, ACR, paid Defender plans, private endpoints, Logic Apps,
or an AI endpoint were live.

## 2. Prerequisites and working conventions

Required capabilities:

- a dedicated Azure training subscription;
- an Entra tenant where the operator can create lab users and groups;
- Azure Cloud Shell for Azure CLI and Bicep;
- PowerShell with the `Az` and Microsoft Graph modules for identity and network automation;
- Git and Python 3;
- Terraform 1.6 or later for local or CI validation;
- Docker for the hardened runtime test, or GitHub Actions as the substitute;
- a temporary free Kubernetes training environment for Day 12, not AKS.

Clone the repository:

```powershell
Set-Location "D:\drdoaa"

git clone `
  "https://github.com/Moustafa-Elnobi-Mohamed/Azure-Enterprise-Security-Lab-MEMO.git"

Set-Location "Azure-Enterprise-Security-Lab-MEMO"
git status
```

Expected: branch `main` and a clean working tree.

Use environment variables instead of copying identifiers into source files:

```powershell
$MemoLocation = "eastus"
$MemoSubscriptionId = az account show --query id --output tsv
$MemoTenantId = az account show --query tenantId --output tsv

if (-not $MemoSubscriptionId -or -not $MemoTenantId) {
    throw "STOP: Azure context was not resolved."
}
```

Do not print these values in screenshots or commit them.

## Day 1: Define the enterprise and establish the safety boundary

**Status:** planning plus live resource-group organization.

1. Confirm the authenticated Azure context:

```powershell
az account show `
  --query "{Subscription:name,SignedInAs:user.name,Tenant:tenantDisplayName}" `
  --output table
```

2. Stop if the displayed subscription or tenant is not the dedicated lab.

3. Define the project tags and resource groups:

```powershell
$MemoLocation = "eastus"
$MemoTags = "Project=MEMO" "Environment=Lab" "ManagedBy=Learning"

$MemoResourceGroups = @(
    "MEMO-RG-Identity",
    "MEMO-RG-Network",
    "MEMO-RG-Security",
    "MEMO-RG-Monitoring",
    "MEMO-RG-Engineering",
    "MEMO-RG-Finance",
    "MEMO-RG-HR",
    "MEMO-RG-Shared",
    "MEMO-RG-Sandbox",
    "MEMO-RG-Development",
    "MEMO-RG-Production",
    "MEMO-RG-Containers"
)

foreach ($MemoResourceGroup in $MemoResourceGroups) {
    az group create `
      --name $MemoResourceGroup `
      --location $MemoLocation `
      --tags $MemoTags `
      --output none
}

az group list `
  --query "[?starts_with(name, 'MEMO-RG-')].{Name:name,State:properties.provisioningState}" `
  --output table
```

Expected: twelve MEMO resource groups with `Succeeded` state.

4. Record the business model before assigning permissions:

```text
User -> Entra group -> Azure role -> Minimum required scope -> Resource
```

Decision: access will be assigned to groups, not directly to fictional users.

Evidence target: a sanitized resource-group inventory. Do not publish resource
IDs because they contain the subscription ID.

## Day 2: Create the sanitized enterprise identity model

**Status:** live in the original tenant, then deleted during teardown.

1. Review the public identity template:

```powershell
Import-Csv ".\automation\identity-data\employees.csv" |
  Select-Object FirstName,LastName,Department,Group,JobTitle
```

The public file uses `memo-foundation.example`. That reserved domain is
intentionally not deployable.

2. Create a private runtime copy under the ignored `.local` directory:

```powershell
$MemoTenantDomain = Read-Host "Enter the verified lab tenant domain"
$MemoPrivateDirectory = ".\.local\identity"
$MemoPrivateCsv = Join-Path $MemoPrivateDirectory "employees.private.csv"

New-Item -ItemType Directory -Force -Path $MemoPrivateDirectory | Out-Null

Import-Csv ".\automation\identity-data\employees.csv" |
  ForEach-Object {
      $Alias = $_.UserPrincipalName.Split("@")[0]
      $_.UserPrincipalName = "$Alias@$MemoTenantDomain"
      $_
  } |
  Export-Csv $MemoPrivateCsv -NoTypeInformation
```

3. Connect to Microsoft Graph with only the required lab administration scopes:

```powershell
Connect-MgGraph `
  -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"

Get-MgContext |
  Select-Object Account,TenantId,Scopes
```

4. Create the users with a password entered interactively. Never place the
password in the CSV or repository:

```powershell
$MemoSecurePassword = Read-Host "Enter a temporary lab password" -AsSecureString
$MemoInitialPassword = [System.Net.NetworkCredential]::new(
    "",
    $MemoSecurePassword
).Password

$MemoUsers = Import-Csv $MemoPrivateCsv

foreach ($MemoUser in $MemoUsers) {
    $MemoExistingUser = Get-MgUser `
      -Filter "userPrincipalName eq '$($MemoUser.UserPrincipalName)'" `
      -ErrorAction SilentlyContinue

    if ($MemoExistingUser) {
        Write-Host "SKIP: $($MemoUser.UserPrincipalName) already exists."
        continue
    }

    $MemoMailNickname = $MemoUser.UserPrincipalName.Split("@")[0]

    New-MgUser `
      -AccountEnabled:$true `
      -DisplayName "$($MemoUser.FirstName) $($MemoUser.LastName)" `
      -GivenName $MemoUser.FirstName `
      -Surname $MemoUser.LastName `
      -Department $MemoUser.Department `
      -JobTitle $MemoUser.JobTitle `
      -OfficeLocation $MemoUser.Office `
      -MailNickname $MemoMailNickname `
      -UserPrincipalName $MemoUser.UserPrincipalName `
      -PasswordProfile @{
          Password = $MemoInitialPassword
          ForceChangePasswordNextSignIn = $true
      } | Out-Null
}

Remove-Variable MemoInitialPassword
```

5. Verify the count without publishing UPNs:

```powershell
$MemoCreatedUsers = foreach ($MemoUser in $MemoUsers) {
    Get-MgUser `
      -Filter "userPrincipalName eq '$($MemoUser.UserPrincipalName)'" `
      -ErrorAction SilentlyContinue
}

"Resolved MEMO users: $(@($MemoCreatedUsers).Count)"
```

Expected: 31 users.

Failure and fix: a real tenant domain cannot be stored publicly. The repository
was sanitized to `.example`; the runtime copy supplies the private domain and is
ignored by Git.

## Day 3: Create groups, memberships, and application identities

**Status:** live in the original tenant, then deleted.

1. Create the eleven security groups:

```powershell
$MemoGroupNames = @(
    "MEMO-GRP-CEO",
    "MEMO-GRP-Executives",
    "MEMO-GRP-Cloud-Admins",
    "MEMO-GRP-Cloud-Engineers",
    "MEMO-GRP-Cloud-Security",
    "MEMO-GRP-Developers",
    "MEMO-GRP-Finance",
    "MEMO-GRP-HR",
    "MEMO-GRP-Help-Desk",
    "MEMO-GRP-Interns",
    "MEMO-GRP-Marketing"
)

foreach ($MemoGroupName in $MemoGroupNames) {
    $MemoExistingGroup = Get-MgGroup `
      -Filter "displayName eq '$MemoGroupName'" `
      -ErrorAction SilentlyContinue

    if (-not $MemoExistingGroup) {
        New-MgGroup `
          -DisplayName $MemoGroupName `
          -MailEnabled:$false `
          -MailNickname ($MemoGroupName.ToLower() -replace '[^a-z0-9]','') `
          -SecurityEnabled:$true | Out-Null
    }
}
```

2. Add each user to the group named in the private CSV:

```powershell
foreach ($MemoUser in $MemoUsers) {
    $MemoGroup = Get-MgGroup -Filter "displayName eq '$($MemoUser.Group)'"
    $MemoDirectoryUser = Get-MgUser `
      -Filter "userPrincipalName eq '$($MemoUser.UserPrincipalName)'"

    if (-not $MemoGroup -or -not $MemoDirectoryUser) {
        throw "STOP: Missing user or group for $($MemoUser.FirstName)."
    }

    $MemoAlreadyMember = Get-MgGroupMember -GroupId $MemoGroup.Id -All |
      Where-Object Id -eq $MemoDirectoryUser.Id

    if (-not $MemoAlreadyMember) {
        New-MgGroupMemberByRef `
          -GroupId $MemoGroup.Id `
          -BodyParameter @{
              "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($MemoDirectoryUser.Id)"
          }
    }
}
```

3. Create six app registrations without client secrets:

```powershell
$MemoApplicationNames = @(
    "MEMO Cloud Dashboard",
    "MEMO Developer Portal",
    "MEMO Executive Dashboard",
    "MEMO Finance Portal",
    "MEMO HR Portal",
    "MEMO Help Desk Portal"
)

foreach ($MemoApplicationName in $MemoApplicationNames) {
    $MemoAppId = az ad app list `
      --display-name $MemoApplicationName `
      --query "[0].appId" `
      --output tsv

    if (-not $MemoAppId) {
        $MemoAppId = az ad app create `
          --display-name $MemoApplicationName `
          --query appId `
          --output tsv

        az ad sp create --id $MemoAppId --output none
    }
}
```

Do not create client secrets just to demonstrate an application registration.

4. Verify counts without printing object IDs:

```powershell
"MEMO groups: $((Get-MgGroup -All | Where-Object DisplayName -like 'MEMO-GRP-*').Count)"

$MemoApplicationCount = 0
foreach ($MemoApplicationName in $MemoApplicationNames) {
    $MemoApplicationCount += [int](az ad app list `
      --display-name $MemoApplicationName `
      --query "length(@)" `
      --output tsv)
}
"MEMO applications: $MemoApplicationCount"
```

Expected: 11 groups and 6 applications.

## Day 4: Implement group-based RBAC and JIT workflow

**Status:** live assignments plus PowerShell automation.

1. Review the canonical matrix:

```powershell
Get-Content ".\docs\RBAC\RBAC-Matrix.md"
```

2. Resolve group IDs at runtime and assign only the documented role and scope:

```powershell
$MemoAssignments = @(
    @{ Group="MEMO-GRP-CEO"; Role="Reader"; Scope="/subscriptions/$MemoSubscriptionId" },
    @{ Group="MEMO-GRP-Cloud-Security"; Role="Security Reader"; Scope="/subscriptions/$MemoSubscriptionId" },
    @{ Group="MEMO-GRP-Cloud-Admins"; Role="Contributor"; Scope="/subscriptions/$MemoSubscriptionId/resourceGroups/MEMO-RG-Engineering" },
    @{ Group="MEMO-GRP-Cloud-Engineers"; Role="Contributor"; Scope="/subscriptions/$MemoSubscriptionId/resourceGroups/MEMO-RG-Engineering" },
    @{ Group="MEMO-GRP-Developers"; Role="Contributor"; Scope="/subscriptions/$MemoSubscriptionId/resourceGroups/MEMO-RG-Development" },
    @{ Group="MEMO-GRP-Finance"; Role="Reader"; Scope="/subscriptions/$MemoSubscriptionId/resourceGroups/MEMO-RG-Finance" },
    @{ Group="MEMO-GRP-HR"; Role="Reader"; Scope="/subscriptions/$MemoSubscriptionId/resourceGroups/MEMO-RG-HR" },
    @{ Group="MEMO-GRP-Help-Desk"; Role="Reader"; Scope="/subscriptions/$MemoSubscriptionId/resourceGroups/MEMO-RG-Shared" },
    @{ Group="MEMO-GRP-Interns"; Role="Contributor"; Scope="/subscriptions/$MemoSubscriptionId/resourceGroups/MEMO-RG-Sandbox" },
    @{ Group="MEMO-GRP-Marketing"; Role="Reader"; Scope="/subscriptions/$MemoSubscriptionId/resourceGroups/MEMO-RG-Shared" }
)

foreach ($MemoAssignment in $MemoAssignments) {
    $MemoGroupId = az ad group show `
      --group $MemoAssignment.Group `
      --query id `
      --output tsv

    az role assignment create `
      --assignee-object-id $MemoGroupId `
      --assignee-principal-type Group `
      --role $MemoAssignment.Role `
      --scope $MemoAssignment.Scope `
      --output none
}
```

3. Never grant Owner automatically. Contributor assignments stay at approved
resource-group scope.

4. Review and test the JIT model in a non-production scope:

```powershell
Get-Content ".\automation\JIT\MEMO-Grant-JIT.ps1"
Get-Content ".\automation\JIT\MEMO-Revoke-JIT.ps1"
Get-Content ".\automation\JIT\MEMO-JIT-Access.ps1"
```

The scripts log runtime details beneath ignored `.local/logs`. The sanitized
historical example is stored at `docs/evidence/jit/memo-jit-audit.csv`.

Failure and fix: early role assignments returned `PrincipalNotFound` because
directory replication had not completed. The safe response was to wait, resolve
the group again, and assign using its object ID and explicit principal type.

## Day 5: Enable monitoring, Sentinel, policy awareness, and baseline KQL

**Status:** Log Analytics and Sentinel were live; paid Defender plans were not.

1. Create the Log Analytics workspace:

```bash
az monitor log-analytics workspace create \
  --resource-group MEMO-RG-Monitoring \
  --workspace-name MEMO-LAW-SENTINEL \
  --location eastus \
  --retention-time 30 \
  --output none
```

2. Enable Microsoft Sentinel on the existing workspace:

```bash
WORKSPACE_ID="$(az monitor log-analytics workspace show \
  --resource-group MEMO-RG-Monitoring \
  --workspace-name MEMO-LAW-SENTINEL \
  --query id --output tsv)"

az rest \
  --method put \
  --url "https://management.azure.com${WORKSPACE_ID}/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2024-03-01" \
  --body '{"properties":{}}' \
  --output none
```

3. Send subscription Activity Log data to the workspace:

```bash
SUBSCRIPTION_ID="$(az account show --query id --output tsv)"

az monitor diagnostic-settings subscription create \
  --name MEMO-Subscription-Activity \
  --location eastus \
  --workspace "$WORKSPACE_ID" \
  --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true},{"category":"Policy","enabled":true}]' \
  --output none
```

4. Wait for ingestion, then run the baseline in Logs:

```kql
AzureActivity
| where TimeGenerated > ago(24h)
| summarize Events=count() by OperationNameValue, ActivityStatusValue
| order by Events desc
```

5. Run the RBAC-change query from
`monitoring/security/KQL/02-RBAC-Changes.kql`.

Failure and fix: the first query returned no useful records because the
subscription diagnostic setting did not exist. Create the diagnostic route,
generate controlled activity, then allow ingestion time before changing KQL.

Cost gate: do not enable extra connectors or paid Defender workload plans. Data
ingestion and retention are billing inputs, so verify usage before adding data.

## Day 6: Build segmented networking and NSG controls

**Status:** live VNet, four subnets, four NSGs, and controlled rules.

1. Connect through PowerShell:

```powershell
Connect-AzAccount
Set-AzContext -SubscriptionId $MemoSubscriptionId
```

2. Run the idempotent network creation scripts in order:

```powershell
& ".\infrastructure\networking\scripts\01-create-vnet.ps1"
& ".\infrastructure\networking\scripts\02-create-nsgs.ps1"
& ".\infrastructure\networking\scripts\03-configure-network-security.ps1"
```

3. Review `04-configure-nsg-rules.ps1` before running it. It contains the
additional inter-tier rules used by the lab, but `Add-AzNetworkSecurityRuleConfig`
is not idempotent. Do not rerun it against an NSG where the named rules already
exist.

4. Associate each NSG with its matching subnet:

```powershell
$MemoVnet = Get-AzVirtualNetwork `
  -Name "MEMO-VNET-CORE" `
  -ResourceGroupName "MEMO-RG-Network"

$MemoSubnetNsgMap = @{
    "MEMO-SUBNET-APP"      = "MEMO-NSG-APP"
    "MEMO-SUBNET-DATA"     = "MEMO-NSG-DATA"
    "MEMO-SUBNET-MGMT"     = "MEMO-NSG-MGMT"
    "MEMO-SUBNET-SECURITY" = "MEMO-NSG-SECURITY"
}

foreach ($MemoSubnetName in $MemoSubnetNsgMap.Keys) {
    $MemoNsg = Get-AzNetworkSecurityGroup `
      -Name $MemoSubnetNsgMap[$MemoSubnetName] `
      -ResourceGroupName "MEMO-RG-Network"

    $MemoSubnet = $MemoVnet.Subnets |
      Where-Object Name -eq $MemoSubnetName

    Set-AzVirtualNetworkSubnetConfig `
      -VirtualNetwork $MemoVnet `
      -Name $MemoSubnet.Name `
      -AddressPrefix $MemoSubnet.AddressPrefix `
      -NetworkSecurityGroup $MemoNsg | Out-Null
}

$MemoVnet | Set-AzVirtualNetwork | Out-Null
```

5. Validate:

```powershell
& ".\infrastructure\networking\scripts\05-validate-network.ps1"
```

Expected: VNet `10.10.0.0/16`, four `/24` subnets, four NSGs, and no direct
Internet management path.

Failure and fix: duplicate priorities produced `SecurityRuleConflict`. List the
existing rules first and allocate a unique priority from 100 through 4096.

## Day 7: Import the network into Terraform and prepare the data layer

**Status:** Terraform configuration validated; not every module was applied.

1. Authenticate Azure CLI using MFA:

```powershell
az login
az account set --subscription $MemoSubscriptionId
```

2. Enter the lab environment and validate formatting:

```powershell
Set-Location ".\automation\terraform\environments\lab"
terraform fmt -recursive
terraform init
terraform validate
```

3. Inspect before planning:

```powershell
terraform plan
```

Never apply a plan that unexpectedly creates private endpoints, storage, DNS,
VMs, or other resources outside the approved cost boundary.

4. For CI-style validation without a backend or deployment:

```bash
terraform fmt -check -recursive automation/terraform
terraform -chdir=automation/terraform/environments/lab init -backend=false -input=false
terraform -chdir=automation/terraform/environments/lab validate
```

Decision: networking was the principal Terraform-managed live layer. Storage,
private endpoint, private DNS, and secure VM modules remained desired-state
artifacts when deployment conflicted with cost or teardown requirements.

Failure and fix: Terraform authentication must use the correct Azure CLI tenant
and subscription context. Verify `az account show` before diagnosing the HCL.

## Day 8: Secure Key Vault, diagnostics, KQL, and storage design

**Status:** Key Vault and diagnostics live; storage module validated but excluded
from the final live footprint.

1. Create or deploy a globally unique Key Vault name. The historical name was
`MEMO-KV-SECURITY`; select another suffix if Azure reports that it is unavailable.

```bash
az keyvault create \
  --name MEMO-KV-SECURITY \
  --resource-group MEMO-RG-Security \
  --location eastus \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --retention-days 7 \
  --enable-purge-protection false \
  --output none
```

2. Assign `Key Vault Secrets Officer` only to the authorized lab operator at
Key Vault scope. Resolve IDs at runtime and do not save them:

```bash
SIGNED_IN_OBJECT_ID="$(az ad signed-in-user show --query id --output tsv)"
KEY_VAULT_ID="$(az keyvault show \
  --name MEMO-KV-SECURITY \
  --resource-group MEMO-RG-Security \
  --query id --output tsv)"

az role assignment create \
  --assignee-object-id "$SIGNED_IN_OBJECT_ID" \
  --assignee-principal-type User \
  --role "Key Vault Secrets Officer" \
  --scope "$KEY_VAULT_ID" \
  --output none
```

3. Add reversible deletion protection for the temporary lab:

```bash
az lock create \
  --name MEMO-KV-Delete-Protection \
  --lock-type CanNotDelete \
  --resource-group MEMO-RG-Security \
  --resource-name MEMO-KV-SECURITY \
  --resource-type Microsoft.KeyVault/vaults \
  --output none
```

4. Send Key Vault audit events to Log Analytics:

```bash
az monitor diagnostic-settings create \
  --name MEMO-KV-Diagnostics \
  --resource "$KEY_VAULT_ID" \
  --workspace "$WORKSPACE_ID" \
  --logs '[{"category":"AuditEvent","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]' \
  --output none
```

5. Generate only controlled test events, then query failures:

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where OperationName == "SecretGet"
| where httpStatusCode_d >= 400
| project TimeGenerated, OperationName, ResultType, httpStatusCode_d,
          CallerIPAddress, ResourceId
```

6. Review the exported live rule at
`detections/sentinel/rules/failed-keyvault-secret-access.json`.

Failure and fix: `ResultType` could report success while the HTTP status showed
401, 404, or another failure. The detection was corrected to evaluate the HTTP
status and actual schema instead of trusting one field.

Documented exceptions:

- purge protection remained disabled for complete teardown;
- public network access remained enabled because private connectivity was
  excluded for cost.

Compensating controls were soft delete, the lock, RBAC, managed identity, and
diagnostic monitoring.

## Day 9: Add workload identity and least-privilege Key Vault access

**Status:** user-assigned managed identity and Key Vault RBAC were live.

1. Create the identity:

```bash
az identity create \
  --name MEMO-ID-Workload-App \
  --resource-group MEMO-RG-Security \
  --location eastus \
  --output none
```

2. Assign only `Key Vault Secrets User` at Key Vault scope:

```bash
WORKLOAD_PRINCIPAL_ID="$(az identity show \
  --name MEMO-ID-Workload-App \
  --resource-group MEMO-RG-Security \
  --query principalId --output tsv)"

az role assignment create \
  --assignee-object-id "$WORKLOAD_PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Key Vault Secrets User" \
  --scope "$KEY_VAULT_ID" \
  --output none
```

3. Verify without publishing IDs:

```bash
az role assignment list \
  --scope "$KEY_VAULT_ID" \
  --query "[].{Role:roleDefinitionName,Type:principalType}" \
  --output table
```

4. Validate the reusable module:

```bash
terraform fmt -check -recursive automation/terraform/modules/managed-identity
```

Decision: a workload receives a managed identity and a data-access role, not a
client secret and not Contributor or Owner.

## Day 10: Validate secure storage and private connectivity without deployment

**Status:** CI-validated desired-state architecture.

1. Review the storage module controls:

- TLS 1.2 minimum;
- HTTPS only;
- anonymous blob access disabled;
- shared-key authentication disabled;
- Microsoft Entra authentication preferred;
- local users and SFTP disabled.

2. Validate Terraform without applying:

```bash
terraform fmt -check -recursive automation/terraform
terraform -chdir=automation/terraform/environments/lab init -backend=false -input=false
terraform -chdir=automation/terraform/environments/lab validate
```

3. A plan may show storage, private endpoint, private DNS zone, and VNet link
resources. Stop at the plan when those services are outside the approved budget:

```bash
terraform -chdir=automation/terraform/environments/lab plan -refresh=false
```

Expected historical design: four resources proposed for the private-connectivity
path. They were not part of the final eleven-resource live inventory.

4. Inspect the exact modules:

```text
automation/terraform/modules/storage/
automation/terraform/modules/private-endpoint/
automation/terraform/modules/private-dns/
```

Failure and fix: a configuration can validate while still proposing billable
or unwanted resources. `terraform validate` proves structure; the plan and cost
gate decide whether deployment is authorized.

## Day 11: Deploy the cost-controlled Container App

**Status:** live Azure Container Apps workload, later decommissioned.

1. Register the provider and install the CLI extension in Cloud Shell:

```bash
az provider register --namespace Microsoft.App
az extension add --name containerapp --upgrade
```

2. Create the Consumption environment:

```bash
az containerapp env create \
  --name MEMO-CAE \
  --resource-group MEMO-RG-Containers \
  --location eastus \
  --output none
```

3. Deploy the demonstration workload with minimum scale zero and maximum one:

```bash
az containerapp create \
  --name memo-secure-app \
  --resource-group MEMO-RG-Containers \
  --environment MEMO-CAE \
  --image nginxinc/nginx-unprivileged:alpine \
  --target-port 8080 \
  --ingress external \
  --allow-insecure false \
  --cpu 0.25 \
  --memory 0.5Gi \
  --min-replicas 0 \
  --max-replicas 1 \
  --output none

az containerapp identity assign \
  --name memo-secure-app \
  --resource-group MEMO-RG-Containers \
  --system-assigned \
  --output none
```

4. Resolve its managed identity and grant only Key Vault read access:

```bash
CONTAINER_PRINCIPAL_ID="$(az containerapp show \
  --name memo-secure-app \
  --resource-group MEMO-RG-Containers \
  --query identity.principalId --output tsv)"

az role assignment create \
  --assignee-object-id "$CONTAINER_PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Key Vault Secrets User" \
  --scope "$KEY_VAULT_ID" \
  --output none
```

5. Validate the security and cost controls:

```bash
az containerapp show \
  --name memo-secure-app \
  --resource-group MEMO-RG-Containers \
  --query '{Profile:properties.workloadProfileName,MinReplicas:properties.template.scale.minReplicas,MaxReplicas:properties.template.scale.maxReplicas,CPU:properties.template.containers[0].resources.cpu,Memory:properties.template.containers[0].resources.memory,External:properties.configuration.ingress.external,AllowInsecure:properties.configuration.ingress.allowInsecure,Identity:identity.type}' \
  --output jsonc
```

Expected: Consumption, 0 to 1 replicas, 0.25 CPU, 0.5Gi memory, external HTTPS,
insecure transport disabled, and system-assigned identity.

Do not publish the FQDN, static IP, or principal ID after teardown.

## Day 12: Validate hardened Kubernetes controls without AKS

**Status:** validated design in a temporary browser-based Kubernetes cluster.

1. Open a temporary free Kubernetes training environment and verify that its
nodes are disposable and not connected to the Azure subscription:

```bash
kubectl get nodes
```

2. Transfer the eight non-empty files from `infrastructure/kubernetes/`. Confirm
they did not become empty during terminal transfer:

```bash
wc -l infrastructure/kubernetes/*.yaml
```

3. Apply the namespace first, then the remaining manifests:

```bash
kubectl apply -f infrastructure/kubernetes/namespace.yaml

kubectl apply \
  -f infrastructure/kubernetes/configmap.yaml \
  -f infrastructure/kubernetes/service-account.yaml \
  -f infrastructure/kubernetes/rbac.yaml \
  -f infrastructure/kubernetes/secret-example.yaml \
  -f infrastructure/kubernetes/deployment.yaml \
  -f infrastructure/kubernetes/service.yaml \
  -f infrastructure/kubernetes/network-policy.yaml
```

4. Validate rollout and inventory:

```bash
kubectl rollout status deployment/memo-secure-app \
  --namespace memo-app --timeout=120s

kubectl get all --namespace memo-app --output wide
kubectl get networkpolicy --namespace memo-app
```

5. Run the security tests:

```bash
POD_NAME="$(kubectl get pod --namespace memo-app \
  --selector app=memo-secure-app \
  --output jsonpath='{.items[0].metadata.name}')"

kubectl exec --namespace memo-app "$POD_NAME" -- id
kubectl exec --namespace memo-app "$POD_NAME" -- \
  sh -c 'touch /security-test' || echo 'PASS: root filesystem is read-only.'

kubectl exec --namespace memo-app "$POD_NAME" -- \
  sh -c 'test ! -d /var/run/secrets/kubernetes.io/serviceaccount' \
  && echo 'PASS: no service-account token mounted.'

kubectl auth can-i list pods \
  --as system:serviceaccount:memo-app:memo-workload-sa \
  --namespace memo-app

kubectl auth can-i list pods \
  --as system:serviceaccount:memo-app:memo-auditor-sa \
  --namespace memo-app

kubectl auth can-i get secrets \
  --as system:serviceaccount:memo-app:memo-auditor-sa \
  --namespace memo-app
```

Expected: UID/GID 101, read-only filesystem, no automatic token, workload
cannot list pods, auditor can list pods, and auditor cannot read secrets.

Failure and fix: the first remote transfer produced zero-line YAML files and
`error: no objects passed to apply`. Check file length before applying and
transfer the actual content again. Do not diagnose Kubernetes until the files
contain objects.

AKS, ACR, Defender for Containers, and the Entra Workload ID federation path
remained excluded or design-only because they would introduce cost or require a
production cluster.

## Day 13: Review Defender posture and deploy audit-only governance

**Status:** free posture review plus live/validated Bicep governance.

1. Inventory Defender pricing without enabling anything:

```powershell
$MemoSubscriptionId = az account show --query id --output tsv

$MemoPricingApiVersion = az provider show `
  --namespace Microsoft.Security `
  --query "resourceTypes[?resourceType=='pricings'].apiVersions[0]" `
  --output tsv

az rest `
  --method get `
  --url "https://management.azure.com/subscriptions/$MemoSubscriptionId/providers/Microsoft.Security/pricings?api-version=$MemoPricingApiVersion" `
  --query "value[].{Plan:name,Tier:properties.pricingTier,SubPlan:properties.subPlan}" `
  --output table
```

2. Do not enable Standard workload plans. The historical Standard objects were
only the free `Discovery` and `FoundationalCspm` posture layer.

3. Build the Defender contact template:

```bash
az bicep install
az bicep build \
  --file infrastructure/bicep/defender-governance/main.bicep
```

4. Preview before deploying:

```bash
az deployment sub what-if \
  --name memo-defender-contact-preview \
  --location eastus \
  --template-file infrastructure/bicep/defender-governance/main.bicep \
  --parameters securityContactEmail='<SECURITY_CONTACT_EMAIL>'
```

5. Build and preview the audit-only tag policy:

```bash
az bicep build \
  --file infrastructure/bicep/policy-governance/main.bicep

az deployment sub what-if \
  --name memo-policy-preview \
  --location eastus \
  --template-file infrastructure/bicep/policy-governance/main.bicep
```

6. Deploy only after the preview shows the expected audit definition and three
assignments:

```bash
az deployment sub create \
  --name memo-policy-governance \
  --location eastus \
  --template-file infrastructure/bicep/policy-governance/main.bicep \
  --output none
```

Failure and fixes:

- local DNS could not reach `management.azure.com`, so Azure Cloud Shell was used;
- Bash uses `\` for continuation while PowerShell uses a backtick;
- Azure Policy compliance evaluation is asynchronous, so an immediate empty
  result is not proof that deployment failed.

## Day 14: Deploy, tune, automate, and investigate Sentinel detections

**Status:** three live rules, one native automation rule, and a completed
historical incident investigation.

1. Confirm the tables contain data before deploying detections:

```kql
Usage
| where TimeGenerated > ago(30d)
| summarize MB=sum(Quantity) by DataType, IsBillable
| order by MB desc
```

2. Build and preview the three rules:

```bash
az bicep build \
  --file infrastructure/bicep/sentinel-detections/main.bicep

az deployment group what-if \
  --name memo-sentinel-detections-preview \
  --resource-group MEMO-RG-Monitoring \
  --template-file infrastructure/bicep/sentinel-detections/main.bicep \
  --parameters workspaceName=MEMO-LAW-SENTINEL
```

3. Deploy and verify:

```bash
az deployment group create \
  --name memo-sentinel-detections \
  --resource-group MEMO-RG-Monitoring \
  --template-file infrastructure/bicep/sentinel-detections/main.bicep \
  --parameters workspaceName=MEMO-LAW-SENTINEL \
  --output none
```

4. Build, preview, and deploy native incident automation:

```bash
az bicep build \
  --file infrastructure/bicep/sentinel-automation/main.bicep

az deployment group what-if \
  --name memo-sentinel-automation-preview \
  --resource-group MEMO-RG-Monitoring \
  --template-file infrastructure/bicep/sentinel-automation/main.bicep \
  --parameters workspaceName=MEMO-LAW-SENTINEL

az deployment group create \
  --name memo-sentinel-automation \
  --resource-group MEMO-RG-Monitoring \
  --template-file infrastructure/bicep/sentinel-automation/main.bicep \
  --parameters workspaceName=MEMO-LAW-SENTINEL \
  --output none
```

5. Validate these engineering decisions in the JSON artifacts:

- five-minute frequency and ten-minute lookback;
- successful-operation filtering and `arg_max()` deduplication;
- `Failed` and `Failure` normalization;
- Account, IP, and Azure resource entity mappings;
- MITRE ATT&CK mapping;
- incident grouping;
- Key Vault thresholds that distinguish authorization failures from 404s.

6. For an authorized test alert, investigate rather than blindly close:

```text
Timestamp -> operation -> caller -> source IP -> scope -> correlation ID ->
result -> surrounding activity -> authorization/change record -> classification
```

The historical Incident 22 was closed as `BenignPositive` with reason
`SuspiciousButExpected` because the rule correctly detected an authorized RBAC
change. See `docs/evidence/day14/incident-22-investigation.md`.

Failure and fixes:

- the real Azure Activity value was `Failure`, not only `Failed`;
- Start and Success records duplicated operations, so the query retained the
  final result by correlation ID;
- Sentinel automation required full analytics-rule resource IDs, not bare GUIDs;
- native actions replaced a Logic App to avoid an unnecessary service.

## Day 15: Run final security assurance and DevSecOps validation

**Status:** 10 controls passed, 0 failed, 2 documented exceptions, and 3 CI jobs
passed.

1. Collect sanitized evidence. Never commit raw CLI output before inspecting it
for Azure resource IDs, email addresses, IPs, and object IDs.

2. Compile and run the Python validators:

```bash
python3 -m py_compile automation/python/*.py
python3 automation/python/memo_security_validator.py
python3 automation/python/validate_repo_artifacts.py
python3 automation/python/validate_repository_hygiene.py
python3 automation/python/validate_readme.py
```

3. Validate Terraform without state or deployment:

```bash
terraform fmt -check -recursive automation/terraform
terraform -chdir=automation/terraform/environments/lab init -backend=false -input=false
terraform -chdir=automation/terraform/environments/lab validate
```

4. Compile all four Bicep entry points:

```bash
for template in \
  infrastructure/bicep/defender-governance/main.bicep \
  infrastructure/bicep/policy-governance/main.bicep \
  infrastructure/bicep/sentinel-detections/main.bicep \
  infrastructure/bicep/sentinel-automation/main.bicep
do
  az bicep build --file "$template" --stdout >/dev/null
done
```

5. Validate the hardened Docker runtime locally when Docker is available:

```bash
docker build \
  --tag memo-secure-app:1.0.0 \
  infrastructure/containers/memo-secure-app

docker run --detach \
  --name memo-secure-app-test \
  --user 101:101 \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=16m \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --publish 8080:8080 \
  memo-secure-app:1.0.0

curl --fail http://127.0.0.1:8080/health
docker exec memo-secure-app-test id
docker inspect memo-secure-app-test
docker stop memo-secure-app-test
docker rm memo-secure-app-test
```

6. Push a branch and confirm all three GitHub Actions jobs pass. The workflow is
`.github/workflows/security-validation.yml` and uses read-only repository
permissions without Azure authentication.

Failure and fixes:

- the Defender evidence initially returned null tiers; fix the source query
  before trusting a zero-paid-plan result;
- Log Analytics needed the workspace customer GUID, not the ARM resource ID;
- numeric strings required `tonumber` before summing with `jq`;
- Cloud Shell had a Docker CLI but no daemon, so GitHub Actions performed the
  runtime build and test;
- a broken heredoc swallowed later content; rewrite the affected files and run
  repository validators;
- deprecated Node.js actions were upgraded and persisted checkout credentials
  were disabled.

Expected final historical result: `PASS_WITH_EXCEPTIONS`, 10 passed, 0 failed,
2 documented exceptions, and 3 successful CI jobs.

## Day 16: Add secure AI design, sanitize the repository, and release

**Status:** AI design-only; repository and release CI validated.

1. Review the AI boundary:

```text
docs/architecture/ai-security/ai-security-architecture.md
docs/architecture/ai-security/ai-threat-model.md
docs/architecture/ai-security/ai-red-team-test-plan.md
```

2. Confirm that every AI document says `DESIGN-ONLY`. The architecture must
include managed identity, least privilege, prompt-injection defenses, restricted
tools, sensitive-data minimization, output validation, human approval for every
state-changing action, monitoring, cost limits, and a kill switch.

3. Run the AI validator:

```bash
python3 automation/python/validate_ai_security_design.py
```

Expected: 12 unique risks, 12 adversarial tests, and zero failures.

4. Audit repository hygiene:

```bash
python3 automation/python/validate_repository_hygiene.py
python3 automation/python/validate_repo_artifacts.py
python3 automation/python/validate_readme.py
git status --short
git diff --check
```

5. Remove or sanitize any binary Terraform plan, temporary password, state file,
tenant-specific identifier, personal email, real UPN, malformed filename, empty
placeholder, obsolete configuration, or oversized artifact. Do not print a
detected secret-shaped value to CI logs.

6. Review the successful pipeline, tag the validated commit, and publish the
release only after all three jobs pass:

```bash
git tag -a v1.0.0 -m "MEMO Foundation v1.0.0"
git push origin v1.0.0
```

Failure and fixes:

- Cloud Shell is ephemeral; committed source and evidence must be recoverable
  from GitHub;
- the final audit found sensitive identifiers and obsolete artifacts even though
  the Azure deployment worked; repository security is a separate control;
- the old README overstated unfinished scope, so it was rebuilt around measured
  outcomes and explicit implementation boundaries.

## Final controlled decommission

**Status:** completed after Day 16 evidence collection.

This is destructive. Run it only in the dedicated lab subscription and only
after exact inventories have been reviewed privately. Never substitute a broad
name search for a saved allowlist when deleting Entra objects.

1. Confirm the signed-in administrator and subscription:

```bash
az account show \
  --query '{Subscription:name,SignedInAs:user.name,Tenant:tenantDisplayName}' \
  --output table

az ad signed-in-user show \
  --query '{DisplayName:displayName,UPN:userPrincipalName}' \
  --output table
```

2. Remove resource locks only from exact MEMO scopes, then delete the twelve
exact resource groups. Do not use a wildcard delete command:

```bash
for group in \
  MEMO-RG-Identity \
  MEMO-RG-Network \
  MEMO-RG-Security \
  MEMO-RG-Monitoring \
  MEMO-RG-Engineering \
  MEMO-RG-Finance \
  MEMO-RG-HR \
  MEMO-RG-Shared \
  MEMO-RG-Sandbox \
  MEMO-RG-Development \
  MEMO-RG-Production \
  MEMO-RG-Containers
do
  az group delete --name "$group" --yes --no-wait
done
```

3. Allow Azure to finish managed-environment deletion. Repeating the deletion
request does not accelerate a resource in `ScheduledForDelete`.

4. Delete Entra users, groups, applications, service principals, and RBAC only
from privately saved exact object-ID inventories. Before deletion, enforce the
expected counts and confirm the signed-in administrator appears zero times.

Historical safety gate:

```text
31 users
11 groups
6 app registrations
7 inventoried service principals, including managed identities
0 signed-in-administrator matches
```

Managed-identity service principals should normally disappear with their Azure
resources. Do not manually delete unrelated enterprise applications.

5. Verify the MEMO footprint is empty:

```bash
echo "MEMO RESOURCE GROUPS"
az group list \
  --query "[?starts_with(name, 'MEMO-RG-')].{Name:name,State:properties.provisioningState}" \
  --output table

echo "MEMO AZURE RESOURCES"
az resource list \
  --query "[?starts_with(resourceGroup, 'MEMO-RG-')].{Name:name,Type:type,ResourceGroup:resourceGroup}" \
  --output table

echo "MEMO LOG ANALYTICS"
az monitor log-analytics workspace list \
  --query "[?starts_with(name, 'MEMO')].{Name:name,ResourceGroup:resourceGroup}" \
  --output table
```

Expected: all three sections empty.

6. Verify the entire disposable subscription only if it was dedicated to this
lab:

```bash
echo "RESOURCE GROUP COUNT"
az group list --query 'length(@)' --output tsv

echo "RESOURCE COUNT"
az resource list --query 'length(@)' --output tsv
```

The historical subscription finished with both counts at zero after two
Azure-created default resource groups were also reviewed and removed.

Deleted users may remain temporarily under Entra **Deleted users**. Historical
cost data may remain visible after deletion; it is not proof of active workload
consumption.

## Final repository validation

Run from the repository root:

```bash
git status --short
python3 -m py_compile automation/python/*.py
python3 automation/python/validate_repo_artifacts.py
python3 automation/python/validate_ai_security_design.py
python3 automation/python/validate_repository_hygiene.py
python3 automation/python/validate_readme.py
```

Expected: clean Git status and zero failures from every validator.

## Evidence map

| Proof | Public location |
|---|---|
| Architecture and lifecycle | `docs/architecture/` |
| Identity and RBAC decisions | `docs/RBAC/` |
| Day-by-day engineering history | `docs/daily-notes/day01.md` through `day16.md` |
| Sanitized Azure and validation evidence | `docs/evidence/` |
| Sentinel rule source | `detections/sentinel/rules/` |
| KQL investigation library | `monitoring/security/KQL/` |
| Terraform modules | `automation/terraform/` |
| Bicep deployments | `infrastructure/bicep/` |
| Hardened Docker workload | `infrastructure/containers/memo-secure-app/` |
| Kubernetes manifests and threat model | `infrastructure/kubernetes/` |
| Python assurance | `automation/python/` |
| CI workflow | `.github/workflows/security-validation.yml` |
| Final technical report | `docs/reports/day15-final-security-validation.md` |
| Project closeout | `docs/reports/day16-project-closeout.md` |
| Presentation script | `docs/reports/public-project-rehearsal.md` |

## What this guide proves

The project was not one uninterrupted deployment script. It was an engineering
process: establish identity, scope access, segment the network, protect secrets,
secure workloads, collect telemetry, tune detections, investigate evidence,
convert controls into code, validate continuously, document exceptions, and
remove the live environment safely.

The most important rule remains: do not claim that a control is live merely
because its configuration exists in Git. State the boundary, show the evidence,
and document what would change in production.

## Current Microsoft command references

- [Azure subscription diagnostic settings CLI](https://learn.microsoft.com/en-us/cli/azure/monitor/diagnostic-settings/subscription)
- [Azure resource diagnostic settings CLI](https://learn.microsoft.com/en-us/cli/azure/monitor/diagnostic-settings)
- [Azure Container Apps CLI](https://learn.microsoft.com/en-us/cli/azure/containerapp)
- [Managed identities in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/managed-identity)
- [Microsoft Sentinel REST API versions](https://learn.microsoft.com/en-us/rest/api/securityinsights/api-versions)
