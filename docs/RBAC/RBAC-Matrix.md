# MEMO RBAC Matrix

This is the canonical access model for the MEMO Foundation lab. Access is
assigned to groups instead of individual users, and privileged access is scoped
to the smallest practical resource.

| Group | Responsibility | Azure RBAC | Scope | Access model | Application access |
|---|---|---|---|---|---|
| `MEMO-GRP-CEO` | Executive authority | Reader | Subscription | Standing read-only | Executive Dashboard |
| `MEMO-GRP-Executives` | Executive users | Reader | Executive resources | Standing read-only | Executive Dashboard |
| `MEMO-GRP-Cloud-Admins` | Cloud administration | Contributor | `MEMO-RG-Engineering` | Temporary/JIT preferred | Cloud Dashboard |
| `MEMO-GRP-Cloud-Engineers` | Infrastructure engineering | Contributor | `MEMO-RG-Engineering` | Temporary/JIT | Cloud Dashboard |
| `MEMO-GRP-Cloud-Security` | Security operations | Security Reader | Subscription | Read and security visibility | Cloud Dashboard |
| `MEMO-GRP-Developers` | Application development | Contributor | `MEMO-RG-Development` | Scoped to development | Developer Portal |
| `MEMO-GRP-Finance` | Finance operations | Reader | `MEMO-RG-Finance` | Standing read-only | Finance Portal |
| `MEMO-GRP-HR` | Human resources | Reader | `MEMO-RG-HR` | Standing read-only | HR Portal |
| `MEMO-GRP-Help-Desk` | User support | Reader | `MEMO-RG-Shared` | Support resources only | Help Desk Portal |
| `MEMO-GRP-Interns` | Isolated lab work | Contributor | `MEMO-RG-Sandbox` | Restricted to sandbox | Limited applications |
| `MEMO-GRP-Marketing` | Marketing operations | Reader | `MEMO-RG-Shared` | Standing read-only | Marketing resources |

## Security decisions

- Subscription Owner is not assigned automatically to any MEMO group.
- Contributor access is limited to an approved resource group.
- Privileged engineering access uses the documented JIT grant and revoke flow.
- Intern Contributor access is isolated to the sandbox resource group.
- The sanitized [RBAC evidence CSV](RBAC-Matrix.csv) contains no live
  subscription identifier.
