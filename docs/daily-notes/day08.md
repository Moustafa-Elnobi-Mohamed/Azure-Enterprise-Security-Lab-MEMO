# Day 8: Key Vault, Detection Engineering and Data Security

Today was probably one of the best security-engineering days in the project so far.

I started with Azure Key Vault.

The Key Vault was deployed through Terraform:

```text
MEMO-KV-SECURITY
```

I configured it to use Azure RBAC instead of legacy access policies.

I gave myself:

```text
Key Vault Secrets Officer
```

at the Key Vault scope.

Then I created a harmless lab secret so I could test access and monitoring without putting real credentials into the vault.

The design is:

```text
Identity
   ↓
Azure RBAC
   ↓
Key Vault
   ↓
Secret
```

## Logging

Next I created a diagnostic setting:

```text
MEMO-KV-Diagnostics
```

and sent:

```text
AuditEvent
```

logs into:

```text
MEMO-LAW-Sentinel
```

The telemetry path became:

```text
Key Vault
   ↓
Azure Monitor Diagnostic Settings
   ↓
Log Analytics
   ↓
Microsoft Sentinel
```

At first my KQL returned nothing.

I waited for ingestion, generated additional secret operations, and eventually the Key Vault `AuditEvent` logs started appearing in:

```text
AzureDiagnostics
```

That confirmed the logging pipeline worked.

## KQL troubleshooting

This became the most interesting part.

My first query expected fields such as:

```text
identity_claim_upn_s
Caller_s
clientIP_s
```

Some of those fields showed up when I inspected the global AzureDiagnostics schema but were not actually usable for my Key Vault records.

So I stopped assuming the schema and started testing the actual telemetry.

I ran:

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| getschema
```

Then I looked directly at the Key Vault rows.

I found usable fields including:

```text
OperationName
ResultType
httpStatusCode_d
CallerIPAddress
Resource
ResourceId
```

Then I found something even more important.

My first detection logic was:

```text
ResultType != Success
```

That looked correct.

But the actual telemetry showed:

```text
SecretGet       ResultType = Success       HTTP = 404
Authentication  ResultType = Success       HTTP = 401
SecretGet       ResultType = Success       HTTP = 200
```

So `ResultType` was not reliable for this detection.

That was a real detection-engineering lesson.

The telemetry decides what the rule should be.

I changed the final detection to:

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where OperationName == "SecretGet"
| where httpStatusCode_d >= 400
```

I intentionally excluded generic Authentication 401 events because they were normal authentication noise in this environment.

## Sentinel Analytics Rule

I created the final analytics rule:

```text
MEMO - Failed Key Vault Secret Access
```

Settings:

```text
Severity: Medium
Run every: 5 minutes
Lookback: 10 minutes
Trigger when results > 0
Create incidents: Enabled
Defender incident correlation: Enabled
```

I also mapped:

```text
CallerIPAddress
```

as an IP entity.

Then I generated controlled requests for nonexistent secrets.

That produced:

```text
SecretGet
HTTP 404
```

events.

The KQL successfully detected them.

Then Sentinel created real incidents.

I ended up seeing:

```text
MEMO - Key Vault Failed Operations

MEMO - Failed Key Vault Secret Access
```

inside the Defender incident queue.

That completed the full pipeline:

```text
Failed Secret Request
        ↓
Key Vault
        ↓
AuditEvent
        ↓
Log Analytics
        ↓
KQL
        ↓
Sentinel Analytics Rule
        ↓
Defender Incident
        ↓
Investigation
```

## Storage IaC

I also finished preparing the secure Storage Terraform configuration.

The planned Storage Account includes:

```text
Standard LRS
TLS 1.2 minimum
HTTPS only
Anonymous blob access disabled
Shared Key disabled
Microsoft Entra authentication preferred
Local users disabled
```

Terraform currently shows the Storage Account as a planned resource, but I intentionally did not deploy it because MEMO is operating under a strict cost-control rule.

This means the design is deployment-ready without paying for something I do not currently need.

## Biggest lesson from Day 8

A detection can look correct and still be wrong.

My first logic was based on what I expected the logs to mean.

The final logic was based on what the logs actually showed.

That difference is basically the whole point of detection engineering.

---

# Current MEMO Foundation Status After Day 8

At this point, the project has grown into:

```text
                         MEMO FOUNDATION
                               |
       +-----------------------+-----------------------+
       |                       |                       |
    IDENTITY                NETWORK                   DATA
       |                       |                       |
   Entra ID             MEMO-VNET-CORE            Key Vault
   Users                 10.10.0.0/16              Secrets
   Groups                      |                     RBAC
   RBAC                 +------+------+               |
   PIM/JIT              |      |      |               |
                       APP    DATA   MGMT          Storage IaC
                        |      |      |
                       NSGs   NSGs   NSGs
                               |
                         SECURITY
                               |
                    Defender / Policies
                               |
                         Azure Monitor
                               |
                        Log Analytics
                               |
                     Microsoft Sentinel
                               |
                             KQL
                               |
                       Analytics Rules
                               |
                      Defender Incidents
                               |
                          AUTOMATION
                               |
                    PowerShell + Terraform
```

## What I have learned so far

The biggest thing I understand now is that enterprise security is not one tool.

It is a chain.

```text
Identity
   ↓
Authorization
   ↓
Network segmentation
   ↓
Resource security
   ↓
Data protection
   ↓
Logging
   ↓
Detection
   ↓
Investigation
   ↓
Response
   ↓
Automation
```

That is what MEMO is slowly becoming.

I am not trying to rush through Azure services just to say I used them.

I want every service in the project to have a reason for being there.

The next major step is going to be workload and application security, including managed identities, Docker, container security, secrets injection, Kubernetes, and eventually CI/CD security.
---