# MEMO Secure AI Architecture

## Implementation status

**Status: DESIGN-ONLY**

This document defines how MEMO Foundation would securely introduce a generative AI assistant into Azure.

No Azure OpenAI, Microsoft Foundry, Azure AI Search, Azure AI Content Safety, private endpoint, or paid AI resource was deployed.

This decision:

- Preserves the zero-cost objective
- Avoids claiming that a design is a live control
- Documents the required production security controls
- Establishes an approval boundary for future deployment

## Proposed use case

The proposed workload is an internal Security Operations AI Assistant.

Authorized analysts could use it to:

- Summarize Microsoft Sentinel incidents
- Explain and suggest KQL
- Identify investigation paths
- Retrieve approved security procedures
- Draft incident notes
- Recommend response actions

The assistant cannot autonomously close incidents, disable identities, change RBAC, modify networks, delete resources, access secrets, or execute arbitrary commands.

## Security objectives

The architecture must:

1. Authenticate every human and workload identity.
2. Eliminate stored application credentials.
3. Enforce least-privilege authorization.
4. Treat prompts, documents, outputs, and tool results as untrusted.
5. Prevent unrestricted model and tool access.
6. Protect sensitive organizational information.
7. Require human approval for high-impact actions.
8. Monitor abuse without unnecessarily recording sensitive content.
9. Support immediate containment through a kill switch.
10. Control token consumption and cost.

## Proposed security flow

1. The SOC analyst authenticates through Microsoft Entra ID.
2. The MEMO application verifies the analyst's authorization.
3. Input validation checks the prompt for injection and sensitive data.
4. The application calls the model using managed identity.
5. Retrieval is limited to approved documents the analyst may access.
6. Tool requests pass through a restricted tool gateway.
7. State-changing actions require human approval.
8. Model output passes through content and data-loss validation.
9. Security metadata is sent to Log Analytics and Sentinel.
10. Operators can disable the application, identity, tools, or model.

The main trust boundaries are:

- Analyst to application
- Application to model
- Model to retrieval system
- Model to tool gateway
- Tool gateway to Azure
- Application to monitoring

## Identity and non-human identity security

Human analysts authenticate through Microsoft Entra ID.

Production access should require:

- Phishing-resistant MFA
- Conditional Access
- Approved devices
- Named analyst groups
- Just-in-time privileged access where required
- No shared user accounts

The application uses a system-assigned or user-assigned managed identity.

It stores no:

- Client secret
- Model API key
- Azure password
- Long-lived bearer token
- Credential inside source code or a container image

Proposed least-privilege access:

| Identity | Resource | Minimum proposed access |
|---|---|---|
| AI application managed identity | Azure OpenAI | Cognitive Services OpenAI User |
| AI application managed identity | Approved search index | Search Index Data Reader |
| AI application managed identity | Key Vault | Key Vault Secrets User only when unavoidable |
| Deployment identity | AI infrastructure | Separate deployment-time role |

The runtime identity must never receive Owner, Contributor, User Access Administrator, or unrestricted subscription access.

Role assignments must use the narrowest practical resource scope.

## Authentication and network security

Microsoft Entra ID and managed identities are the primary authentication methods.

Local key authentication should be disabled wherever supported.

The production design would:

- Disable public access for AI and search resources
- Use private endpoints and private DNS
- Restrict application egress
- Allow only approved Azure destinations
- Separate application and private endpoint networks
- Block public administrative access

Private endpoints were not deployed because they conflict with the zero-cost lab constraint.

Any unavoidable external secret must be stored in Key Vault and excluded from code, images, prompts, logs, and GitHub Actions.

## Prompt injection and data protection

Prompts, documents, webpages, attachments, and tool responses are untrusted input.

The application must:

- Inspect direct and indirect prompt injection
- Separate system instructions from user content
- Prevent documents from changing authorization
- Reject requests for credentials or policy bypass
- Apply request, token, and rate limits
- Use Prompt Shields or equivalent protection
- Avoid storing unnecessary raw prompt content

Before model submission, unnecessary secrets, tokens, personal information, subscription IDs, tenant IDs, and confidential incident details must be removed.

Retrieval must preserve the analyst's existing authorization boundary.

## Tool and output security

The model never receives a generic terminal, unrestricted REST client, or broad Azure credential.

Every tool requires:

- A fixed purpose and strict input schema
- Server-side authorization
- An operation and resource allowlist
- Bounded execution time
- Rate, token, and cost limits
- Complete audit logging

Model output is also untrusted.

Structured output must pass schema validation. Browser content must be encoded. Commands outside the allowlist must be rejected.

Generated Bash, PowerShell, KQL, or Azure CLI must never execute automatically.

## Human approval and monitoring

Human approval is mandatory before:

- Closing or reclassifying incidents
- Disabling identities
- Changing RBAC
- Rotating or deleting secrets
- Modifying network rules
- Deploying or deleting resources
- Running containment
- Sending external communications

Security telemetry should record identities, correlation IDs, tool decisions, approvals, filter results, prompt-injection results, token usage, and errors.

Raw prompts and completions should not be logged by default.

Sentinel should detect repeated injection attempts, sensitive-data extraction, abnormal consumption, denied tool requests, unexpected identities, RBAC changes, disabled filters, and public-access changes.

## Kill switch and validation

Operators must be able to:

1. Disable the application revision.
2. Remove the managed identity's model role.
3. Disable the tool gateway.
4. Revoke active sessions.
5. Block network access.
6. Disable the model deployment.
7. Preserve logs for investigation.

Before production, the workload requires secret scanning, static analysis, container scanning, prompt-injection tests, disclosure tests, tool authorization tests, output validation, denial-of-wallet testing, AI red-team exercises, and incident-response testing.

## Implementation boundary and cost

The live MEMO lab provides Entra ID, managed identities, RBAC, Key Vault, Container Apps, network controls, Log Analytics, Sentinel, infrastructure as code, GitHub Actions, and incident response.

This architecture extends those foundations to an AI workload. It does not claim that an AI service was deployed or tested live.

No AI resource was created.

**Day 16 introduces $0 in new Azure services.**

## References

- [Azure OpenAI network and access configuration](https://learn.microsoft.com/en-us/azure/foundry-classic/openai/how-to/on-your-data-configuration)
- [Azure AI Content Safety Prompt Shields](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection)
- [Microsoft Foundry content filtering](https://learn.microsoft.com/en-us/azure/foundry-classic/foundry-models/concepts/content-filter)
- [Foundry data privacy and security](https://learn.microsoft.com/en-us/azure/foundry/responsible-ai/openai/data-privacy)
- [OWASP Top 10 for LLM and Generative AI Applications](https://genai.owasp.org/llm-top-10/)
