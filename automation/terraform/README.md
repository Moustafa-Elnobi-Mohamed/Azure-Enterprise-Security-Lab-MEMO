# MEMO Terraform

This directory contains reusable Azure infrastructure modules and the MEMO lab environment configuration.

## Security coverage

- Network segmentation and NSGs
- Azure Key Vault
- Managed identity
- Secure storage
- Private DNS design
- Private endpoint design
- Secure VM design

## Validation

GitHub Actions runs formatting, backend-free initialization, and Terraform validation.

```bash
terraform fmt -check -recursive automation/terraform
terraform -chdir=automation/terraform/environments/lab init -backend=false -input=false
terraform -chdir=automation/terraform/environments/lab validate
```

## Deployment boundary

Validation does not mean every module is deployed. Private endpoints, storage, DNS, and compute modules include desired-state designs that were excluded from the final live footprint when cost or teardown requirements applied.
