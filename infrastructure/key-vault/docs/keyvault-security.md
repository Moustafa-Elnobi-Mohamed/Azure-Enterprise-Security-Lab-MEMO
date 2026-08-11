# MEMO Key Vault Security Architecture

## Objective

Protect application secrets, certificates, and cryptographic material
without embedding credentials inside source code.

## Security Model

Application
    |
    v
Managed Identity
    |
    v
Microsoft Entra ID
    |
    v
Azure RBAC
    |
    v
Key Vault
    |
    +-- Secrets
    +-- Certificates
    +-- Keys

## Security Controls

- Microsoft Entra ID authentication
- Azure RBAC authorization
- Least privilege
- Soft delete
- Purge protection for production
- Logging and monitoring
- No secrets committed to Git
- Managed identities preferred over stored credentials

## MEMO Principle

Applications should authenticate using workload identity rather
than storing long-lived passwords, API keys, or client secrets.