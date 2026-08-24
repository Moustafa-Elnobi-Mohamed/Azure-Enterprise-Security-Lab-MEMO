# MEMO Day 15 Python Security Assurance Report

Generated: `2026-08-24T23:08:22.673276+00:00`

Overall result: **PASS_WITH_EXCEPTIONS**

- Passed controls: **10**
- Failed controls: **0**
- Documented exceptions: **2**

| Control | Status | Evidence |
|---|---|---|
| Enterprise resource-group structure | PASS | All 12 expected resource groups are healthy. |
| Cost-controlled Azure footprint | PASS | Inventory contains 11 active MEMO resources. |
| Microsoft Defender pricing | PASS | Only free foundational Discovery and Foundational CSPM are active; paid workload protection plans remain disabled. |
| Container Apps cost controls | PASS | Consumption profile, scale 0-1, 0.25 vCPU, and 0.5Gi memory. |
| Container Apps identity and transport | PASS | System-assigned identity is enabled and insecure ingress is disabled. |
| Key Vault authorization | PASS | Azure RBAC authorization is enabled. |
| Key Vault deletion recovery | PASS | Soft delete and the MEMO-KV-Delete-Protection lock are active. |
| Key Vault purge protection | DOCUMENTED_EXCEPTION | Purge protection remains disabled so the temporary lab can be fully removed. A reversible CanNotDelete lock mitigates deletion risk. |
| Key Vault network isolation | DOCUMENTED_EXCEPTION | Public access remains enabled for the non-VNet-integrated lab workload. RBAC and diagnostic monitoring provide compensating controls; a paid private endpoint was intentionally excluded. |
| Microsoft Sentinel analytics | PASS | All three selected analytics rules are enabled with incident grouping. |
| Native Sentinel automation | PASS | Native labeling and investigation tasks are enabled with no playbook. |
| Log Analytics ingestion control | PASS | 3.881714 MB ingested and 0.063201 MB marked billable over 30 days. |

## Result interpretation

A documented exception is an intentional lab design decision with a recorded reason and compensating control. It is not treated as a silent pass.

The validator performs no Azure writes and uses only sanitized evidence committed to the repository.
