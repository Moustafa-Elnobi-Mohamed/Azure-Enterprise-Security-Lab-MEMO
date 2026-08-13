# Day 2: Enterprise Identity

Today I focused heavily on Microsoft Entra ID.

Instead of working with only one or two test users, I wanted MEMO to actually look like a company.

I prepared a CSV-based employee structure and used Microsoft Graph PowerShell to create the users.

The environment included employees across different departments and roles instead of everyone being an administrator.

That was important because later I want security controls to follow business roles.

The basic idea was:

```text
MEMO Company
|
├── Executives
├── Cloud
├── Security
├── Developers
├── Help Desk
├── Finance
└── Interns
```

I created more than 25 users through automation instead of manually creating them one by one.

I verified the users through Graph after creation.

This was one of the first points where MEMO started feeling like an actual enterprise lab instead of a single-user Azure subscription.

## Why I did this

RBAC, Conditional Access, PIM, JIT, monitoring, and security policies are much easier to understand when there are actual identities and job roles to protect.

A company would not give permissions individually to every employee.

The better model is:

```text
User
  ↓
Group
  ↓
Role
  ↓
Resource
```

That became one of the main identity principles for MEMO.

## What I learned

Automation saves a ridiculous amount of time.

More importantly, identity design needs to happen before access control.

If the users and groups are messy, RBAC will also become messy.

---

