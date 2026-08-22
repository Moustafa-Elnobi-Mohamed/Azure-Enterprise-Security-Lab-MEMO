# Day 13: Defender for Cloud, Bicep, Azure Policy, and Cost-Aware Governance

## Goal

My goal today was to assess the Azure environment using Microsoft Defender for Cloud, improve the controls that were genuinely free, introduce Bicep without conflicting with Terraform, and document paid recommendations instead of blindly enabling them.

The main rule remained unchanged: no paid Defender plans, no trials, and no infrastructure that could quietly generate charges.

## 1. Defender for Cloud pricing inventory

The normal Azure CLI pricing command returned no visible results, so I queried the Microsoft Security pricing API directly.

```powershell
$SubscriptionId = az account show --query id --output tsv

$PricingApiVersion = az provider show `
  --namespace Microsoft.Security `
  --query "resourceTypes[?resourceType=='pricings'].apiVersions[0]" `
  --output tsv

$PricingResponse = az rest `
  --method get `
  --url "https://management.azure.com/subscriptions/$SubscriptionId/providers/Microsoft.Security/pricings?api-version=$PricingApiVersion" |
  ConvertFrom-Json
```

The results confirmed:

* Defender CSPM was not enabled.
* Defender for Servers was not enabled.
* Defender for Storage was not enabled.
* Defender for Key Vault was not enabled.
* Defender for Containers was not enabled.
* All paid workload-protection plans remained on the Free tier.
* Foundational CSPM and its discovery component were available without enabling paid workload protection.

A lesson from this step was that the word `Standard` by itself does not always prove that a paid Defender plan is active. The plan name and purpose must also be evaluated.

## 2. Secure Score baseline

The Defender for Cloud Secure Score showed:

* Current score: 5
* Maximum score: 5
* Percentage: 100%

This was a strong result for the resources currently included in the assessment, but I did not present it as proof that the entire subscription was perfectly secure. The maximum score was still limited.

## 3. Defender recommendation inventory

I retrieved 28 Defender assessments:

* Healthy: 5
* Not applicable: 12
* Unhealthy: 11

The unhealthy recommendations included:

* Enable Microsoft Defender CSPM
* Enable Defender for Storage
* Enable Defender for Key Vault
* Enable Defender for Resource Manager
* Configure security contact information
* Enable high-severity email notifications
* Notify subscription owners
* Add another subscription owner
* Enable Key Vault deletion protection
* Use Private Link for Key Vault
* Enable the Key Vault firewall

I divided these recommendations into three categories.

### Implemented at no cost

* Security contact email
* High-severity alert notifications
* Subscription owner notifications
* Audit-only Azure Policy governance

### Accepted or deferred risks

* Key Vault firewall
* Key Vault Private Link
* Purge protection
* Having only one subscription owner
* Missing enterprise tags

### Rejected because they could create charges

* Defender CSPM
* Defender for Storage
* Defender for Key Vault
* Defender for Resource Manager

I did not create exemptions to hide the recommendations or artificially improve the score. The findings remain documented as real risks.

## 4. Key Vault security review

The Key Vault inspection showed:

* RBAC authorization: enabled
* Soft delete: enabled
* Public network access: enabled
* Firewall: not configured
* Purge protection: disabled
* Resource deletion lock: enabled with `CanNotDelete`

The existing resource lock provides reversible protection against accidental deletion.

I did not enable purge protection because it is irreversible and could interfere with Terraform cleanup during the lab lifecycle.

I also confirmed that the Container App did not currently contain a direct Key Vault secret reference. However, I still avoided changing the firewall without a complete network-access design.

## 5. Using Bicep without installing it locally

Bicep was not available on my Windows system or initially inside Cloud Shell.

I used an ephemeral Azure Cloud Shell session and installed Bicep there:

```bash
az bicep install
az bicep version
```

The installation existed only inside the temporary Cloud Shell session. It did not install anything on my computer, create an Azure resource, or add a persistent storage account.

## 6. Defender security contact with Bicep

I created a subscription-scope Bicep template under:

```text
infrastructure/bicep/defender-governance/main.bicep
```

The template configured:

* A designated security contact
* High-severity Defender alert notifications
* Notifications for the subscription Owner role
* No paid Defender plans

The email address was passed as a deployment parameter instead of being hardcoded into the public repository.

Before deployment, I ran:

```bash
az bicep build \
  --file infrastructure/bicep/defender-governance/main.bicep
```

I then ran a what-if preview:

```bash
az deployment sub what-if \
  --name memo-defender-contact-preview \
  --location eastus \
  --template-file infrastructure/bicep/defender-governance/main.bicep \
  --parameters securityContactEmail='<security-email>'
```

The preview showed exactly one resource:

```text
Microsoft.Security/securityContacts/default
```

After confirming that no Defender pricing resources were included, I deployed the template.

The deployment completed successfully and verified:

* Security contact enabled
* High-severity threshold enabled
* Owner notifications enabled

## 7. Audit-only Azure Policy with Bicep

I created another Bicep template under:

```text
infrastructure/bicep/policy-governance/main.bicep
```

This template created one reusable custom policy definition and three assignments.

Required tags:

* Environment
* Owner
* CostCenter

The policy used:

```text
Mode: Indexed
Effect: audit
```

It did not use:

* Deny
* Modify
* DeployIfNotExists
* Managed identity
* Remediation tasks

The what-if preview showed exactly four creations:

* One custom policy definition
* Environment tag assignment
* Owner tag assignment
* CostCenter tag assignment

The deployment completed successfully.

## 8. Policy compliance results

I triggered an Azure Policy compliance scan and evaluated 13 taggable Azure resources.

Results:

| Tag                 | Evaluated | Compliant | Noncompliant |
| ------------------- | --------: | --------: | -----------: |
| Environment         |        13 |         6 |            7 |
| Owner               |        13 |         0 |           13 |
| CostCenter          |        13 |         0 |           13 |
| Total policy states |        39 |         6 |           33 |

The policy successfully detected real governance gaps without changing or blocking any resource.

I did not manually add tags because several resources are managed by Terraform or generated by Azure. Manual changes could create configuration drift. Tag remediation will be handled through the correct infrastructure owner during the final project-polish day.

## 9. Problems encountered

### Local DNS failure

My Windows system temporarily failed to resolve:

```text
management.azure.com
```

This caused the Azure CLI assessment request to fail. The empty PowerShell variable initially appeared as an assessment count of zero, but that was not a valid result because the request never reached Azure.

I switched to ephemeral Azure Cloud Shell and completed the assessment successfully.

### PowerShell and Bash syntax

I initially used Bash continuation characters inside Windows PowerShell.

Bash uses:

```bash
\
```

PowerShell uses:

```powershell
`
```

Using one-line commands inside Cloud Shell helped avoid further syntax confusion.

### Policy evaluation delay

The first policy query returned zero states because the new assignments had not been evaluated yet.

After triggering a compliance scan and waiting for the evaluation, Azure returned 39 actual policy states.

## 10. Cost controls

Today I intentionally avoided:

* Paid Defender workload-protection plans
* Defender trials
* Private Endpoints
* AKS
* Azure Container Registry
* Virtual machines
* Logic Apps
* Remediation identities
* Automatic tag modification
* Persistent Cloud Shell storage

Azure Policy and the security-contact configuration introduced no additional billable workload.

## Final result

Day 13 added real cloud-security governance without adding paid services.

I now have:

* A verified Defender for Cloud baseline
* A Secure Score baseline
* A documented recommendation and risk inventory
* Defender security notifications deployed through Bicep
* A reusable custom Azure Policy definition
* Three audit-only enterprise tag assignments
* Compliance results across 13 Azure resources
* Clear separation between Terraform infrastructure ownership and Bicep governance ownership
* Evidence supporting every major implementation

The next phase is Microsoft Sentinel, KQL detection engineering, incident investigation, and automation design.
