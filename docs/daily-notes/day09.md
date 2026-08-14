# Day 9: Workload Identity, Key Vault and Governance

Today I moved more into workload identity and governance instead of only securing human users.

The main thing I worked with was a user-assigned managed identity called:

`MEMO-ID-Workload-App`

I learned that a managed identity basically gives an Azure workload its own identity in Entra instead of me putting a username, password, API key, or secret directly inside the application.

One thing that confused me at first was the difference between the Client ID and Principal ID.

The Client ID identifies the identity when it is being used for authentication.

The Principal ID is the actual service principal/object that Azure RBAC works with.

I gave the workload:

`Key Vault Secrets User`

on:

`MEMO-KV-SECURITY`

I scoped the permission directly to the Key Vault instead of giving the identity Contributor or Owner over an entire resource group.

That was a good example of least privilege.

The flow basically became:

```text
Workload
→ Managed Identity
→ Entra ID
→ Azure RBAC
→ Key Vault Secrets User
→ MEMO-KV-SECURITY
```

I also worked on putting the managed identity into Terraform.

I made a reusable module under:

```text
automation/terraform/modules/managed-identity
```

with:

```text
main.tf
variables.tf
outputs.tf
```

I made the mistake of pasting Terraform `resource` code directly into PowerShell.

That helped make the separation clearer:

Terraform code goes inside `.tf` files.

PowerShell runs commands such as:

```powershell
terraform fmt
terraform validate
terraform plan
```

After fixing the module files, Terraform worked correctly.

I also added a protection lock to the Key Vault:

`MEMO-KV-Delete-Protection`

using:

`CanNotDelete`

This means the Key Vault can still be configured, but it cannot just be accidentally deleted.

Then I moved into Azure Policy.

I created a custom policy to audit resources that do not have:

`Project = MEMO`

I used Audit instead of Deny because I want to first see what is non-compliant without breaking deployments.

The biggest thing I learned today was the difference between these three controls:

```text
RBAC = who can do something

Azure Policy = what configurations are allowed or compliant

Resource Lock = protects a resource from deletion or modification
```

Using all three together makes more sense than depending on permissions alone.

## What I Completed

* User-assigned managed identity
* Managed identity verification
* Client ID vs Principal ID
* Key Vault Secrets User RBAC
* Least-privilege workload access
* Managed identity Terraform module
* Terraform validation
* Key Vault CanNotDelete lock
* Azure Policy introduction
* Custom tag auditing policy
* Governance concepts

## SC-500 Topics

* Managed identities
* Workload identity
* Azure RBAC
* Key Vault
* Infrastructure as Code
* Azure Policy
* Resource locks
* Governance
* Least privilege

## Main Takeaway

Azure security is not only about protecting users.

Applications, services, automation, and other workloads also have identities and permissions.

Those identities need the same least-privilege thinking as human accounts, and governance controls need to exist above individual resources so insecure configurations can be detected or blocked.
