# Day 3: Groups and Access Design

Today I started organizing those identities into actual security groups.

Some of the main groups included:

```text
MEMO-GRP-Cloud-Admins
MEMO-GRP-Cloud-Engineers
MEMO-GRP-Cloud-Security
MEMO-GRP-Developers
MEMO-GRP-Help-Desk
MEMO-GRP-Interns
MEMO-GRP-Finance
```

The idea was to stop thinking about permissions as:

"Give Moustafa access."

and start thinking like:

"Cloud Engineers should have this level of access to this environment."

That is a much more scalable enterprise model.

I also started preparing the access model that would later be used for RBAC, PIM, and temporary privileged access.

I spent time understanding the difference between:

* Microsoft Entra roles
* Azure RBAC roles
* Group membership
* Resource scopes
* Subscription scope
* Resource group scope

That distinction is extremely important.

An Entra role controls things inside the identity directory.

Azure RBAC controls access to Azure resources.

They are related, but they are not the same thing.

## Problem I ran into

Microsoft Graph authentication became annoying because I was sometimes authenticating through my Microsoft consumer account instead of the actual Entra tenant context.

That caused errors such as Graph saying an API was not supported for MSA accounts.

That problem came back later and forced me to pay much more attention to:

```text
Account
Tenant
Subscription
Authentication context
```

## What I learned

Before troubleshooting the command, verify the identity context.

A perfectly valid command will still fail when I am authenticated to the wrong tenant.

---

