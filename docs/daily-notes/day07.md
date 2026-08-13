# Day 7: Terraform and the Beginning of the Data Layer

Today was a major shift.

Until now, a lot of MEMO had been built through the portal and PowerShell.

Today I started moving toward real Infrastructure as Code with Terraform.

At first Terraform was not installed correctly.

Then Terraform worked, but Azure CLI was missing.

Then Azure CLI worked, but MFA blocked authentication.

I had to fix the whole authentication chain:

```text
Terraform
    ↓
AzureRM Provider
    ↓
Azure CLI
    ↓
MFA
    ↓
Azure Tenant
    ↓
Subscription
```

Once that worked, Terraform could finally talk to Azure.

## Important discovery

My first Terraform configuration basically managed nothing.

`terraform plan` said:

```text
No changes
```

but that did NOT mean Terraform was managing MEMO.

The state was empty.

That was an important lesson.

Terraform only knows about infrastructure that exists in its configuration and state.

So I started importing the existing MEMO infrastructure.

I created the networking module and imported:

```text
MEMO-VNET-CORE

MEMO-SUBNET-APP
MEMO-SUBNET-DATA
MEMO-SUBNET-MGMT
MEMO-SUBNET-SECURITY

MEMO-NSG-APP
MEMO-NSG-DATA
MEMO-NSG-MGMT
MEMO-NSG-SECURITY
```

Then I added all seven existing NSG rules into Terraform and imported those too.

I had some Terraform drift at first.

For example:

```text
default_outbound_access_enabled
```

did not match the real Azure subnets.

I updated the configuration so Terraform matched the actual secure configuration instead of changing Azure unnecessarily.

I also had description drift on the NSG rules.

Terraform wanted to remove the descriptions because they existed in Azure but not in the Terraform code.

Instead of deleting useful documentation, I added the existing descriptions into Terraform.

Eventually I reached:

```text
No changes. Your infrastructure matches the configuration.
```

That was a major milestone.

The live Azure network and my Terraform configuration finally matched.

## Data security preparation

I also started preparing the data layer.

I wrote KQL around:

* Storage activity
* RBAC changes
* Administrative failures
* Key and secret operations

I created the Storage Terraform module and started thinking about:

* Encryption
* TLS
* Shared Key
* Entra authentication
* Anonymous access
* Data monitoring

I did not deploy Storage because of the strict cost-control rule.

## What I learned

Writing Terraform is not the same as managing infrastructure with Terraform.

The real value came when I imported existing resources, reconciled configuration drift, and got a clean plan.

---

