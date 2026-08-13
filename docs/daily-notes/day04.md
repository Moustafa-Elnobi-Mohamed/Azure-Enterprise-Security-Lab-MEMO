# Day 4: RBAC and Privileged Access

Today was one of the first heavy security days.

I started applying Azure RBAC to the MEMO environment.

I already had multiple resource groups such as:

```text
MEMO-RG-Security
MEMO-RG-Monitoring
MEMO-RG-Engineering
MEMO-RG-Finance
MEMO-RG-HR
MEMO-RG-Shared
MEMO-RG-Sandbox
MEMO-RG-Development
MEMO-RG-Production
MEMO-RG-Network
MEMO-RG-Identity
```

I began assigning permissions based on group and scope.

For example:

```text
MEMO-GRP-Developers
        |
        | Contributor
        v
MEMO-RG-Development
```

and:

```text
MEMO-GRP-Cloud-Engineers
        |
        | Contributor
        v
MEMO-RG-Engineering
```

One of the biggest problems happened when Azure said:

```text
PrincipalNotFound
```

The group clearly existed, but Azure RBAC could not find the principal.

I learned that the principal ID has to exist in the same tenant and that newly created directory objects can also have replication delays.

I eventually fixed the role assignment by using the correct group object and specifying the object type.

That was a good lesson because Azure RBAC looks simple in the portal, but underneath it depends heavily on identity objects and scopes.

## JIT and temporary privileged access

I also started building my own temporary privileged access workflow.

The idea was:

```text
Normal user
    |
    | request temporary access
    v
Contributor role
    |
    | limited time
    v
Access revoked
```

I created scripts for granting and revoking temporary privileges.

At first, my revoke script failed because I used an `ObjectType` parameter that the command did not support.

I fixed the script instead of rebuilding everything.

Eventually the workflow worked.

The script could:

* Find the group
* Grant temporary privileged access
* Record the start time
* Record the expiration time
* Write an audit record
* Revoke the access

That gave me a practical understanding of JIT and PIM-style access instead of only reading about it.

---

