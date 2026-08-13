# MEMO Foundation Daily Notes

These notes are different from my professional documentation.

The documentation folder explains the finished architecture and how the security controls work.

These notes are my actual journey building MEMO. What I did, what broke, what I fixed, why I made certain decisions, and what I learned while studying for SC-500.

---

# Day 1: Building the Foundation

Today was mostly about getting the project started correctly instead of randomly creating Azure resources.

I created the main MEMO Foundation repository and started organizing the project into sections for things like:

* Infrastructure
* Identity
* Networking
* Security
* Detection
* Automation
* Documentation

I wanted the repo to eventually look like a real enterprise security project and not just a folder full of random PowerShell scripts.

I also got my Azure environment ready and started working with Microsoft Entra ID.

The first big lesson was that Azure identity is going to sit in the middle of almost everything I build.

The general idea started becoming:

```text
Users
  |
Entra ID
  |
Groups
  |
RBAC
  |
Azure Resources
```

I also started working with PowerShell and Microsoft Graph because I did not want to manually create every user through the portal.

The goal from Day 1 was already clear:

Build an enterprise-style Azure security environment while learning the same concepts I need for SC-500.

Another important rule I made early:

I do not want this lab turning into a giant Azure bill.

Cost control is going to be part of the architecture.

## What I learned

Azure security is not one product.

Identity, networking, access control, logging, detection, automation, and data protection all connect together.

Today was mostly foundation work, but it gave the rest of MEMO somewhere to grow.

---