# MEMO RBAC Matrix

| Group                    | Primary Responsibility  | Azure RBAC             | Entra Role                     | Application Access   |
| ------------------------ | ----------------------- | ---------------------- | ------------------------------ | -------------------- |
| MEMO-GRP-CEO             | Executive authority     | Reader                 | Business role only             | Executive Dashboard  |
| MEMO-GRP-Executives      | Executive users         | Reader                 | None                           | Executive Dashboard  |
| MEMO-GRP-Cloud-Admins    | Cloud administration    | Contributor*           | Limited admin                  | Cloud Dashboard      |
| MEMO-GRP-Cloud-Engineers | Infrastructure          | Contributor - scoped   | None                           | Cloud Dashboard      |
| MEMO-GRP-Cloud-Security  | Security                | Security Reader        | Security roles where available | Cloud Dashboard      |
| MEMO-GRP-Developers      | Application development | Contributor - Dev RG   | None                           | Developer Portal     |
| MEMO-GRP-Finance         | Finance                 | Reader - Finance scope | None                           | Finance Portal       |
| MEMO-GRP-HR              | HR                      | Reader - HR scope      | None                           | HR Portal            |
| MEMO-GRP-Help-Desk       | Support                 | Reader - support scope | None                           | Help Desk Portal     |
| MEMO-GRP-Interns         | Limited users           | Reader - limited scope | None                           | Limited applications |
| MEMO-GRP-Marketing       | Marketing               | Reader - limited scope | None                           | Marketing resources  |

*Scoped to appropriate resources rather than automatically granting subscription Owner.