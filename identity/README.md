# MEMO Managed Identity Architecture

## Problem

Applications frequently require credentials to access Azure resources.

Storing credentials creates additional security risk.

## MEMO Solution

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
    +--> Storage
    +--> Key Vault
    +--> Database
    +--> Monitoring

## Security Principle

No application should receive Contributor access simply because it
needs to read one resource.

Access should be scoped to the smallest practical resource and role.

## Example

Application:
MEMO-App-Identity

Required access:
Storage Blob Data Reader

Not:
Contributor

Not:
Owner

Not:
Subscription Administrator