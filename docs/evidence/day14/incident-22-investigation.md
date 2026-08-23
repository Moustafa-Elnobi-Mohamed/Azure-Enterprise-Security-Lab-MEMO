# Sentinel Incident Investigation: Incident 22

## Incident summary

| Field | Value |
|---|---|
| Incident | 22 |
| Title | MEMO - RBAC Privilege Change Detection |
| Severity | Medium |
| Initial status | New |
| Alert count | 1 |
| Detected activity | Azure RBAC role-assignment write |
| Resource scope | MEMO-RG-SECURITY |
| Final status | Closed |
| Classification | BenignPositive |
| Classification reason | SuspiciousButExpected |

## Investigation objective

Determine whether the detected Azure RBAC privilege change represented unauthorized privilege escalation or an expected administrative operation.

## Evidence reviewed

The Sentinel incident was correlated with the AzureActivity table using:

- Incident activity timestamp
- Analytics rule identifier
- Operation name
- Activity result
- Caller identity
- Source IP
- Resource group
- Correlation ID

The investigation found one successful Azure RBAC role-assignment write at the same time recorded by the incident.

## Findings

- The operation was `Microsoft.Authorization/roleAssignments/write`.
- The activity completed successfully.
- The caller matched the authorized MEMO lab administrator.
- The change occurred within the expected `MEMO-RG-SECURITY` scope.
- The AzureActivity timestamp matched the incident activity time.
- No unexplained or malicious follow-up activity was identified.
- Sensitive identifiers, account details, and source IP information are intentionally excluded from this public report.

## Conclusion

The analytics rule correctly detected a real privilege-related operation. However, the operation was an authorized lab administration activity rather than malicious privilege escalation.

The incident was therefore closed as:

- **Classification:** BenignPositive
- **Reason:** SuspiciousButExpected
- **Label:** MEMO-Investigated-Day14

## Detection improvements completed

During Day 14, the related Sentinel analytics rules were improved by adding:

- Successful-operation filtering
- Correlation ID deduplication
- Account and IP entity mappings
- MITRE ATT&CK mappings
- Custom investigation details
- Incident grouping
- Bicep-based lifecycle management

A native Sentinel automation rule was also deployed to label future MEMO incidents and add an investigation task without using a paid Logic App or playbook.

## Cost control

This investigation introduced no additional paid services.

- No new data connector was enabled.
- No paid Defender workload plan was enabled.
- No Logic App or playbook was deployed.
- Existing Log Analytics data was queried.
- Sentinel incident metadata was updated through the Azure management API.
