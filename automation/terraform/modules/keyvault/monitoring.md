# MEMO Key Vault Monitoring

Diagnostic setting:
MEMO-KV-Diagnostics

Destination:
MEMO-LAW-Sentinel

Log category:
AuditEvent

Purpose:
Monitor secret, key, and vault activity through Azure Monitor and Microsoft Sentinel.

## Validation

Diagnostic setting validated through Azure CLI.

Key Vault audit events are routed to the existing
MEMO Log Analytics / Microsoft Sentinel workspace.