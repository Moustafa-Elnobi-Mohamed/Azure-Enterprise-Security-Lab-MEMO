# Day 15: Final Security Assurance and DevSecOps Validation

Today was the final engineering day of the MEMO Azure Enterprise Security Lab.

The goal was not to add more random Azure resources. The goal was to prove that everything I built actually worked, document the limitations honestly, automate the validation, and close the technical phase without introducing new costs.

## Starting with the live Azure audit

I began by creating a fresh Cloud Shell clone and collecting a sanitized baseline.

The environment contained:

- Twelve MEMO resource groups
- Eleven active Azure resources
- One Container App
- One Container Apps environment
- One Key Vault
- One managed identity
- Four NSGs
- One VNet
- One Log Analytics workspace
- One Sentinel solution

This confirmed that the project remained intentionally lightweight.

## Fixing the Defender pricing check

My first Defender query returned every pricing tier as null.

The first calculation said that no paid plans were enabled, but that result could not be trusted because the source fields were empty.

I corrected the Azure CLI output structure and reran the check.

The only Standard objects were:

- Discovery
- FoundationalCspm

These are part of the free foundational posture-management layer. Every paid workload-protection plan remained disabled.

The lesson was simple: a passing result is useless if the evidence behind it is wrong.

## Fixing the Log Analytics query

The Log Analytics query originally failed with PathNotFoundError.

I had passed the workspace ARM resource ID where the command expected the workspace customer GUID.

After creating separate variables for the ARM resource ID and customer ID, the query worked.

Azure then returned the ingestion values as strings. My first jq total concatenated the values instead of adding them.

I fixed that by converting each value with `tonumber`.

The final thirty-day totals were:

- 3.881714 MB ingested
- 0.063201 MB marked billable

## Introducing Python security assurance

I created a Python security assurance engine using only the standard library.

The script evaluates sanitized evidence and classifies each control as:

- PASS
- FAIL
- DOCUMENTED_EXCEPTION

It checks resource groups, Defender pricing, Container Apps, Key Vault, Sentinel, automation, and ingestion.

The final result was:

- 10 passed controls
- 0 failed controls
- 2 documented exceptions

The two exceptions were Key Vault purge protection and public network isolation.

I did not hide them or mark them as passing. I documented the reason and the compensating controls.

## Validating Terraform and Bicep

Terraform passed:

- Recursive formatting
- Initialization without a backend
- Configuration validation

I did not run apply, refresh state, or deploy anything.

All four Bicep entry points compiled successfully:

- Defender governance
- Policy governance
- Sentinel detections
- Sentinel automation

The Cloud Shell initialization added one provider checksum to the Terraform lock file. The provider version did not change.

## Revalidating Kubernetes

All eight Kubernetes YAML files contained real content and totaled 255 lines.

The saved remote-cluster context required new credentials, so kubectl could not complete API discovery. That was an authentication limitation, not a YAML failure.

I used offline YAML parsing instead.

The result was:

- 8 files
- 12 Kubernetes objects
- 0 structural failures
- 10 hardened security controls passed

The deployment image was also changed from a floating Alpine tag to a version-specific tag.

## Adding the Docker security artifact

Cloud Shell had the Docker CLI but no Docker daemon.

Instead of trying to install or force a local daemon, I created a reproducible hardened container artifact and moved the real build test into GitHub Actions.

The Docker configuration includes:

- NGINX unprivileged
- UID and GID 101
- Port 8080
- No root switch
- No additional packages
- Health checks
- Security headers
- Restricted build context

A long terminal paste broke the first HTML and README files. I identified that the heredoc had swallowed later commands, rewrote both files cleanly, and reran the static checks.

The repaired artifact passed every check.

## Building continuous security validation

I created a GitHub Actions workflow with three jobs:

1. Python Security Assurance
2. Terraform and Bicep
3. Hardened Docker Runtime

The Docker job performed the test Cloud Shell could not:

- Built the image
- Started the container
- Confirmed the health endpoint
- Verified security headers
- Confirmed UID and GID 101
- Confirmed a read-only root filesystem
- Confirmed all capabilities were dropped
- Confirmed no-new-privileges

The first commit failed because the fresh clone had no Git author identity. I fixed it with a repository-only GitHub noreply identity.

The first workflow then passed all three jobs, but GitHub warned that older action versions used the deprecated Node.js 20 runtime.

I upgraded the workflow to Node.js 24-compatible actions and disabled persisted checkout credentials.

The second workflow completed successfully with all three jobs passing and no deprecation warning.

## Why only three Sentinel rules are live

The repository contains more than twenty detection artifacts, but I intentionally deployed only three representative rules.

Those rules cover:

- Identity and privilege changes
- Azure management-plane failures
- Key Vault secret access

Three focused rules made it possible to demonstrate the full lifecycle clearly:

- Real telemetry
- KQL tuning
- Deduplication
- Entity mapping
- MITRE ATT&CK mapping
- Incident grouping
- Native automation
- Investigation
- Classification
- Bicep management

Deploying every rule without its required telemetry would add noise and make the demonstration less accurate.

## Final result

Day 15 completed the engineering phase.

The project now has:

- Live Azure security controls
- Infrastructure as code
- Python assurance
- GitHub Actions
- Hardened Docker validation
- Kubernetes security
- Sentinel detection engineering
- Incident response
- Cost governance
- Evidence-backed exceptions

Tomorrow is Day 16.

No new engineering scope will be added. The remaining work is architecture, README quality, navigation, evidence organization, consistency, recruiter presentation, and the final launch.
