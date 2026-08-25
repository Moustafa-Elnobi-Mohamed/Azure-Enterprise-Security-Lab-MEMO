# Day 16: Secure AI Design, Repository Hardening, and Final Project Closure

Day 16 was the final project day.

The engineering foundation was already complete, so today was about closing the remaining security gaps, introducing AI security honestly, cleaning the public repository, and turning sixteen days of work into a project another person could understand and validate.

I did not deploy an AI service simply to claim that the project included AI.

That would have added cost without providing enough time or telemetry to validate the implementation properly.

Instead, I built the security architecture, threat model, adversarial test plan, automation, and deployment boundaries that would be required before an enterprise AI workload could be approved.

## Reestablishing the final workspace

Cloud Shell started with a fresh filesystem, so the previous local clone and authentication session were gone.

I authenticated GitHub CLI again, cloned the repository into a new Day 16 workspace, verified the remote main branch, and confirmed the latest engineering commits were intact.

This reinforced an important lesson: Cloud Shell is temporary, but committed source code and evidence remain recoverable.

## Designing the secure AI workload

The proposed workload is an internal Security Operations AI Assistant.

Its purpose is to summarize incidents, explain KQL, retrieve approved procedures, identify investigation paths, and draft analyst notes.

The assistant is not allowed to close incidents, disable identities, change RBAC, modify networks, delete resources, retrieve unrestricted secrets, or execute arbitrary commands.

The architecture includes:

- Microsoft Entra authentication
- Managed workload identity
- Least-privilege Azure RBAC
- Private connectivity as the production target
- Disabled local authentication where supported
- Prompt-injection defenses
- Sensitive-data minimization
- Restricted tool access
- Output validation
- Human approval for state-changing operations
- Log Analytics and Sentinel monitoring
- Token and cost limits
- A documented kill switch

## Threat modeling and red-team planning

I documented twelve AI security risks, including direct and indirect prompt injection, sensitive-data disclosure, excessive agency, insecure retrieval, improper output handling, identity compromise, supply-chain risk, misinformation, prompt leakage, denial of wallet, and sensitive logging.

I also designed twelve adversarial tests.

The tests attempt to bypass instructions, poison retrieved documents, extract secrets, fake human approval, call undefined tools, access another role's documents, generate executable output, and exhaust the token budget.

A Python validator now checks that the architecture contains the required controls, all twelve risk identifiers are unique, all twelve red-team tests exist, and both documents remain marked `DESIGN-ONLY`.

The validator completed with zero failures and was added to the existing GitHub Actions security pipeline.

All three CI jobs passed after the change.

## Auditing the public repository

The final audit found several problems that did not affect the live environment but reduced the quality and privacy of the public repository.

The findings included:

- One malformed filename containing an accidental colored Git diff
- Ten empty tracked placeholder files
- Eleven occurrences of the full subscription ID
- One personal email address
- Thirty-one fictional users using the real tenant domain
- One obsolete file containing hardcoded tenant and group identifiers
- Zero credential-shaped matches
- Zero files larger than five MiB

I removed the malformed artifact, empty placeholders, and obsolete hardcoded RBAC file.

I replaced the subscription ID with a public placeholder, replaced the personal audit identity, and changed the fictional employee accounts to a reserved documentation domain.

## Preventing the problems from returning

I created another standard-library Python validator for repository hygiene.

It checks for:

- Non-portable filenames
- Empty tracked files
- Oversized repository artifacts
- Terraform state and prohibited key files
- Credential-shaped content
- Full Azure subscription resource IDs
- Unapproved public email addresses

The hygiene validator reports only the rule and filename. It never prints the detected secret-shaped value.

The validator completed with zero failures and was added to GitHub Actions.

## Rebuilding the project presentation

The original README still described the project as unfinished and showed Days 2 through 5 as incomplete.

I replaced it with a recruiter-facing project overview that now explains:

- The final engineering outcome
- Measured project results
- Live, CI-validated, and design-only boundaries
- Identity and non-human identity security
- Platform, container, and Kubernetes controls
- Detection engineering and incident response
- Secure AI architecture
- Continuous security assurance
- Cost decisions and documented exceptions
- Repository navigation and validation commands

A Python README validator checks required sections, deployment-boundary statements, and local links.

I also rebuilt the architecture index, Terraform guide, and evidence index so the repository is easier to navigate.

## Final result

The completed project now demonstrates Azure identity, RBAC, managed identities, networking, Key Vault, governance, containers, Kubernetes, Sentinel, KQL, incident response, Terraform, Bicep, Python, GitHub Actions, secure AI design, and cost-aware engineering.

The final assurance position remains:

- Passed controls: 10
- Failed controls: 0
- Documented exceptions: 2
- New paid services added during final validation: 0

## What I learned

The biggest lesson was that project completion is not the same as deployment completion.

A strong security project must distinguish what is live, what was tested, what exists only as validated design, and what risk was consciously accepted.

I also learned that automation should verify documentation and repository hygiene, not only infrastructure.

The project is now closed as an engineering build. It can be used as a portfolio, interview walkthrough, study reference, and reproducible guide for other students.
