# MEMO Automation

Automation is grouped by execution purpose.

| Area | Purpose |
|---|---|
| [Cloud Shell](cloud-shell/) | Reusable shell environment helpers |
| [Governance](governance/) | Azure Policy definitions and deployment scripts |
| [Identity data](identity-data/) | Sanitized source data for lab provisioning |
| [JIT](JIT/) | Temporary RBAC grant, audit, and revocation workflows |
| [PowerShell](powershell/) | Entra provisioning and environment verification |
| [Python](python/) | Security assurance and repository validators |
| [RBAC](RBAC/) | Role-assignment audit automation |
| [Terraform](terraform/) | Reusable infrastructure modules and lab composition |

Runtime audit output is written beneath the ignored `.local/` directory so
tenant-specific details are not accidentally committed.
