# MEMO Secrets and Key Management

## Objective

Protect credentials, application secrets, certificates, and encryption
material using centralized identity and access controls.

## Security Design

Application
    |
    v
Managed Identity
    |
    v
Secret / Key Store
    |
    +---- Secrets
    +---- Certificates
    +---- Encryption Keys
    |
    v
Protected Application Resources

## Security Controls

- Microsoft Entra ID
- Azure RBAC
- Least privilege
- Managed identities
- Encryption at rest
- Encryption in transit
- Secret rotation
- Certificate management
- Key lifecycle management
- Audit logging
- Defender for Cloud
- Azure Monitor
- KQL

## MEMO Principle

Applications should not store credentials directly in source code.

Secrets should never be committed to GitHub.

Access should be granted to identities rather than embedding
long-lived credentials into applications.

## Cost Strategy

The MEMO lab will avoid deploying paid resources solely for demonstration.

Architecture, Terraform configuration, PowerShell automation, KQL,
documentation, and local container security testing will be used wherever
possible before deploying billable Azure services.