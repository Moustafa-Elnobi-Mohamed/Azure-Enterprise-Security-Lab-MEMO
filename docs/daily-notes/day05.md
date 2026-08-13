# Day 5: Policy, Defender, Sentinel and Monitoring

Today I moved from access control into security governance and monitoring.

I worked with Azure Policy and started enforcing security expectations across the environment.

The main idea was:

```text
Azure Resource
      |
      v
Azure Policy
      |
      v
Compliant / Non-compliant
```

This made me understand why governance becomes important once a cloud environment gets larger.

I also worked with Defender and Microsoft Sentinel.

I created the MEMO Log Analytics workspace:

```text
MEMO-LAW-Sentinel
```

and connected it to Sentinel.

Cost was a huge concern here.

I spent time checking Azure Monitor and Sentinel pricing because I did not want to accidentally create a massive log ingestion bill.

I got the Sentinel trial and kept the lab ingestion extremely small.

## Major issue

At first my KQL query returned nothing:

```kql
AzureActivity
| take 20
```

The problem was not KQL.

There were no subscription diagnostic settings sending the Azure Activity logs where I expected them.

I went into the subscription diagnostic settings and discovered:

```text
No diagnostic settings defined
```

I configured the Activity Log pipeline to the MEMO Log Analytics workspace.

After that, the data finally started showing up.

That was a huge lesson.

If KQL returns nothing, it does not automatically mean the query is wrong.

The telemetry pipeline could be broken.

The full chain is:

```text
Azure
  ↓
Diagnostic Settings
  ↓
Log Analytics
  ↓
KQL
  ↓
Sentinel
```

I also created an RBAC privilege-change analytics rule using AzureActivity.

Example:

```kql
AzureActivity
| where TimeGenerated > ago(10m)
| where OperationNameValue contains "roleAssignments"
| project
    TimeGenerated,
    Caller,
    OperationNameValue,
    ResourceGroup,
    ResourceId,
    ActivityStatusValue
```

That moved MEMO from simply controlling access to actually monitoring changes to privileged access.

---
