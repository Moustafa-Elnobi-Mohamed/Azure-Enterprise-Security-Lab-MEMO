# MEMO Storage Security Architecture

## Purpose

The MEMO Foundation storage layer is designed around least privilege,
private access, encryption, monitoring, and controlled data exposure.

## Security Requirements

- HTTPS only
- TLS 1.2+
- Secure transfer required
- Public blob access disabled
- Shared Key access minimized
- Microsoft Entra ID authentication preferred
- RBAC used for authorization
- Encryption at rest enabled
- Infrastructure separated by environment
- Diagnostic logging enabled where appropriate
- Defender for Storage considered for production workloads
- Data classification required before deployment

## Proposed Storage Architecture

MEMO-RG-Data
|
+-- MEMO Storage
|   |
|   +-- Application Data
|   +-- Security Logs
|   +-- Backup Data
|   +-- Deployment Artifacts
|
+-- Entra ID Authentication
|
+-- RBAC
|
+-- Azure Monitor
|
+-- Defender for Cloud

## Production Restrictions

Public anonymous blob access should be disabled.

Storage account keys should not be distributed to applications
when Microsoft Entra ID authentication can be used instead.

Applications should receive only the minimum required storage role.

## SC-500 Mapping

- Data security
- Identity and access control
- Defender for Cloud
- Azure RBAC
- Monitoring
- Security governance