# Day 10: Private PaaS Networking and Secure Storage

Today I focused on securing the network path to Azure Storage instead of just securing the storage account itself.

The main question for today was simple:

If the storage account contains sensitive company data, why should it even be reachable from the public internet?

That led into Azure Private Link, Private Endpoints, Private DNS, and network isolation.

## Where I Started

The storage Terraform module was already configured with several security settings:

```text
HTTPS only
TLS 1.2 minimum
Blob public access disabled
Shared key authentication disabled
OAuth authentication preferred
Local users disabled
SFTP disabled
```

The main weakness left was:

```text
public_network_access_enabled = true
```

So even though the storage account itself had several security controls, it still had a public network path.

The goal was to remove that.

## Private Endpoint

I created a reusable Terraform module for a private endpoint:

```text
automation/
└── terraform/
    └── modules/
        └── private-endpoint/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

The private endpoint connects the Azure Storage Blob service directly to:

```text
MEMO-SUBNET-DATA
```

inside:

```text
MEMO-VNET-CORE
```

The idea is that workloads inside the MEMO network can reach storage using a private IP instead of going through the public network.

The architecture became:

```text
MEMO-VNET-CORE
        |
MEMO-SUBNET-DATA
        |
Private Endpoint
        |
Azure Private Link
        |
Azure Storage
```

## Private DNS

A private endpoint alone is not enough.

Applications normally connect to Azure Storage using a hostname such as:

```text
memosecdata48219.blob.core.windows.net
```

That hostname needs to resolve to the private endpoint IP when the request comes from inside the VNet.

I created another Terraform module for Private DNS.

The zone used was:

```text
privatelink.blob.core.windows.net
```

I then linked that Private DNS zone to:

```text
MEMO-VNET-CORE
```

and connected the DNS zone to the storage private endpoint.

The final DNS flow became:

```text
Application
    |
DNS lookup
    |
Private DNS Zone
    |
Private IP
    |
Private Endpoint
    |
Azure Storage
```

## Public Network Access

After the private network design was complete, I changed:

```hcl
public_network_access_enabled = true
```

to:

```hcl
public_network_access_enabled = false
```

This means the final Terraform design does not depend on the public Azure Storage endpoint.

The intended access path is now through Private Link.

## Terraform Validation

I ran:

```powershell
terraform fmt -recursive
terraform validate
terraform plan
```

Terraform returned:

```text
Success! The configuration is valid.
```

The final plan showed:

```text
Plan: 4 to add, 0 to change, 0 to destroy.
```

The four planned resources were:

```text
Azure Storage Account
Private Endpoint
Private DNS Zone
Private DNS VNet Link
```

The private endpoint was also correctly connected to the Private DNS zone.

## Cost Control

I did not blindly apply the final plan.

Private Endpoints and some related Azure networking resources can generate charges, so I used Terraform plan as a validation and security gate.

The infrastructure is fully represented and validated as code without leaving unnecessary billable resources running.

This was also a good reminder that infrastructure planning is not only about security.

Cost is part of cloud engineering too.

## What I Learned

The biggest lesson today was that making a service private is more than changing one setting.

If I simply disable public network access without building another access path, I can make the service secure but unusable.

The correct sequence is:

```text
Build private connectivity
Configure private DNS
Verify the architecture
Disable the public path
```

I also understood Private Link better today.

Private Endpoint gives the service a private network interface inside the VNet.

Private DNS makes the normal Azure hostname resolve to that private IP.

Public network access can then be removed.

## Troubleshooting

I ran into a few Terraform issues while building the modules.

One was caused by empty module files.

Another came from placing the `private_dns_zone_group` block incorrectly.

I fixed the module structure, reinitialized Terraform, validated the configuration, and kept checking the plan until the dependencies were correct.

This helped me understand Terraform modules better instead of just copying configuration.

## SC-500 Mapping

Today covered:

* Azure Private Link
* Private Endpoints
* Private DNS
* Azure Storage security
* Network isolation
* Secure PaaS connectivity
* Virtual network integration
* Infrastructure as Code
* Terraform validation
* Public network exposure reduction
* Defense in depth

## Main Takeaway

Securing a cloud service does not stop at authentication and encryption.

The network path matters too.

Today I moved the MEMO storage architecture from a publicly reachable PaaS design toward a private network model where access is intended to stay inside the MEMO virtual network.
