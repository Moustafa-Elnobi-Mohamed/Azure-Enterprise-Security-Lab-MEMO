# Azure Enterprise Security Lab: MEMO Foundation

> A production-inspired Azure security project covering identity, networking, secrets, containers, detection engineering, incident response, infrastructure as code, DevSecOps, and secure AI architecture.

[![Azure](https://img.shields.io/badge/Azure-Cloud%20Security-0078D4?logo=microsoftazure)](https://azure.microsoft.com/)
[![Security Validation](https://github.com/Moustafa-Elnobi-Mohamed/Azure-Enterprise-Security-Lab-MEMO/actions/workflows/security-validation.yml/badge.svg)](https://github.com/Moustafa-Elnobi-Mohamed/Azure-Enterprise-Security-Lab-MEMO/actions/workflows/security-validation.yml)
![Terraform](https://img.shields.io/badge/Terraform-Validated-844FBA?logo=terraform)
![Python](https://img.shields.io/badge/Python-Security%20Assurance-3776AB?logo=python)
![Project](https://img.shields.io/badge/Engineering-Complete-success)

## Executive summary

MEMO Foundation is a fictional enterprise used to demonstrate how an Azure environment can be designed, secured, automated, monitored, tested, and investigated.

The objective was not to collect portal screenshots. It was to prove that I could build controls, test them, find weaknesses, fix them, and document the final risk honestly.

## Engineering lifecycle

The project demonstrates the complete security lifecycle:

1. Design the enterprise environment.
2. Deploy selected Azure controls.
3. Apply least privilege.
4. Protect human and workload identities.
5. Centralize security telemetry.
6. Engineer and tune detections.
7. Investigate and classify an incident.
8. Manage security controls as code.
9. Validate everything continuously.
10. Document cost and residual risk.

## Final measurements

| Measurement | Result |
|---|---|
| Resource groups validated | 12 |
| Active Azure resources inventoried | 11 |
| Assurance controls passed | 10 |
| Assurance controls failed | 0 |
| Documented lab exceptions | 2 |
| Live Sentinel rules | 3 |
| Repository detection artifacts | More than 20 |
| Terraform files validated | 24 |
| Bicep deployments compiled | 4 |
| Kubernetes objects validated | 12 |
| AI risks and red-team tests | 12 each |
| New paid services during final validation | 0 |

Final assurance result: **PASS_WITH_EXCEPTIONS**

## Implementation boundary

This repository clearly separates live controls from validated designs.

| Capability | Status |
|---|---|
| Entra users, groups, and RBAC | Live |
| Managed workload identities | Live |
| Azure networking and NSGs | Live |
| Key Vault security controls | Live |
| Azure Container Apps workload | Live |
| Sentinel detections and automation | Live |
| Incident investigation lifecycle | Live demonstration |
| Bicep security deployments | Live and CI validated |
| Terraform modules | Repository validated |
| Hardened Docker workload | CI validated |
| Kubernetes security | Validated design |
| Secure AI architecture | Design-only |

No design-only artifact is represented as a live Azure deployment.

## Architecture flow

Employees and analysts authenticate through Microsoft Entra ID.
Groups, RBAC, JIT access, and managed identities control authorization.
Azure networking, Key Vault, and Container Apps host the secured platform.
Azure Activity and diagnostics feed Log Analytics and Microsoft Sentinel.
Sentinel provides detections, automation, investigation, and closure.

Terraform and Bicep manage infrastructure and security controls.
GitHub Actions validates Python, infrastructure as code, repository hygiene, AI design, and the hardened container runtime.

## Identity and non-human identity security

The project includes:

- Department-based Entra users and groups
- Azure RBAC and separation of duties
- Just-in-time privileged access automation
- Enterprise applications and service principals
- User-assigned and system-assigned managed identities
- Key Vault access without embedded workload credentials
- Restricted Kubernetes service accounts
- Disabled automatic service-account token mounting
- Sanitized public identity datasets

## Platform and container security

Implemented or validated controls include:

- VNet, subnet, and NSG segmentation
- Controlled RDP and SSH management paths
- Key Vault RBAC authorization and deletion protection
- Container Apps scale from zero to one replica
- System-assigned workload identity
- HTTPS-only application ingress
- Non-root Docker execution as UID and GID 101
- Read-only container filesystem
- Dropped Linux capabilities
- RuntimeDefault seccomp
- Default-deny Kubernetes NetworkPolicies

## Detection engineering and incident response

Three representative Sentinel rules are live:

1. Azure RBAC privilege changes
2. Repeated failed Azure operations
3. Failed Key Vault secret access

The repository contains more than twenty additional detection artifacts.

Only three were deployed because they had supporting telemetry and demonstrated KQL tuning, deduplication, entity mapping, MITRE mapping, grouping, automation, investigation, and closure.

Deploying unsupported rules would create inactive detections, misleading coverage, unnecessary noise, and possible ingestion cost.

Incident 22 was correlated with AzureActivity and closed as `BenignPositive` with the reason `SuspiciousButExpected`.

## Secure AI architecture

The proposed Security Operations AI Assistant is explicitly marked `DESIGN-ONLY`.

The design covers:

- Managed identity and least-privilege RBAC
- Private connectivity and disabled local authentication
- Direct and indirect prompt-injection defenses
- Sensitive-data minimization
- Restricted and allowlisted tools
- Output validation
- Human approval for state-changing actions
- Monitoring, cost limits, and a kill switch
- Twelve risks and twelve red-team tests

No AI endpoint or paid AI service was deployed.

## Automated security assurance

Python validators evaluate:

- Sanitized Azure evidence
- Repository infrastructure artifacts
- Secure AI architecture and threat modeling
- Public repository hygiene

GitHub Actions runs three independent jobs:

1. Python Security Assurance
2. Terraform and Bicep
3. Hardened Docker Runtime

The workflow uses read-only repository permissions and disables persisted checkout credentials.

## Cost-aware engineering

The project intentionally excludes paid Defender workload plans, AKS, ACR, Logic App playbooks, private endpoints, and AI services.

Container Apps uses the Consumption profile, scales to zero, and is limited to one replica.

Thirty-day Log Analytics evidence recorded 3.881714 MB ingested and 0.063201 MB marked billable.

Two risks remain documented:

- Key Vault purge protection remains disabled so the temporary lab can be fully removed. Soft delete and a CanNotDelete lock provide compensating protection.
- Key Vault public access remains enabled because private connectivity was excluded for cost. RBAC and diagnostic monitoring provide compensating controls.

These are documented exceptions, not silent passes.

## Repository navigation

| Area | Location |
|---|---|
| Final project closeout | [Day 16 closeout](docs/reports/day16-project-closeout.md) |
| Technical validation report | [Day 15 validation](docs/reports/day15-final-security-validation.md) |
| Enterprise control matrix | [Security control matrix](docs/security-control-matrix.md) |
| AI architecture | [Secure AI architecture](docs/architecture/ai-security/ai-security-architecture.md) |
| AI threat model | [AI threat model](docs/architecture/ai-security/ai-threat-model.md) |
| Daily engineering notes | [Daily notes](docs/daily-notes/) |
| Sentinel detections | [Detection artifacts](detections/) |
| Terraform | [Terraform automation](automation/terraform/) |
| Bicep | [Bicep deployments](infrastructure/bicep/) |
| Kubernetes | [Kubernetes security](infrastructure/kubernetes/) |
| Secure container | [Container artifact](infrastructure/containers/memo-secure-app/) |
| Python assurance | [Python validators](automation/python/) |
| Validation workflow | [GitHub Actions](.github/workflows/security-validation.yml) |
| Project evidence | [Evidence index](docs/evidence/) |

## Run the security assurance

Compile and execute the repository validators:

```bash
python3 -m py_compile automation/python/*.py
python3 automation/python/validate_repo_artifacts.py
python3 automation/python/validate_ai_security_design.py
python3 automation/python/validate_repository_hygiene.py
python3 automation/python/validate_readme.py
```

Terraform and Bicep validation, container building, runtime hardening, security-header checks, and Python assurance also run automatically through GitHub Actions.

## Scope and limitations

- This is a portfolio lab, not a production tenant.
- Resource identifiers and personal data are sanitized.
- Paid Defender workload plans were not enabled.
- AKS and ACR were excluded for cost.
- Kubernetes is represented by validated manifests and prior temporary-cluster evidence.
- Some Terraform modules represent secure desired state rather than currently deployed resources.
- The AI workload is architecture and threat-model work only.
- Screenshots and evidence do not contain credentials or authentication tokens.

These boundaries keep the project accurate, reproducible, and honest.

## Project outcome

This project demonstrates identity engineering, cloud security, non-human identity protection, infrastructure as code, container hardening, Kubernetes security, detection engineering, incident response, Python automation, DevSecOps, secure AI design, and cost governance.

The engineering phase is complete. The repository now serves as both a portfolio project and a technical reference for students who want to understand how enterprise Azure security controls connect in practice.

Built by [Moustafa Elnobi Mohamed](https://github.com/Moustafa-Elnobi-Mohamed).

> Do not just claim that you can do the job. Build proof, test it, break it, fix it, and document the result.
