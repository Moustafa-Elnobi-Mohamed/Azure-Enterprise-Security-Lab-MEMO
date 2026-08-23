# Day 14: Microsoft Sentinel Detection Engineering and Incident Response

Today I moved beyond simply creating Sentinel alerts. The goal was to make the detections more accurate, manageable through code, easier for an analyst to investigate, and less likely to produce duplicate incidents.

I also kept the lab cost controlled by using existing telemetry, native Sentinel automation, and Bicep instead of adding paid Defender plans, new connectors, Logic Apps, or playbooks.

## 1. Reviewed the existing telemetry

I started by checking what data was actually reaching the Log Analytics workspace.

The Usage table showed:

* AzureActivity
* AzureDiagnostics
* SecurityAlert
* SecurityIncident
* Operation

The only billable data was a very small amount of AzureDiagnostics data. The Key Vault produced only a few kilobytes of diagnostic events during the recent period.

This taught me that security monitoring should begin with understanding the available data. A detection cannot work if the required table is empty, and every unnecessary data source can increase cost.

## 2. Inventoried the Sentinel analytics rules

The workspace contained three custom scheduled rules:

1. MEMO - RBAC Privilege Change Detection
2. MEMO - Failed Azure Operation Detection
3. MEMO - Failed Key Vault Secret Access

Each rule ran every five minutes and searched the previous ten minutes of data.

That overlapping schedule is useful because it reduces the chance of missing delayed events. However, without deduplication or incident grouping, the same operation can produce multiple alerts and incidents.

## 3. Tuned the RBAC privilege-change detection

The original RBAC query returned both the Start and Success records for the same operation.

Historical testing showed:

* Original query: 6 results
* Tuned query: 3 results

I filtered for successful operations and used `arg_max()` with `CorrelationId` to keep one final record for each Azure operation.

I also added:

* Account entity mapping
* Source IP entity mapping
* Custom investigation details
* Incident grouping by account
* MITRE ATT&CK technique T1098
* Persistence and Privilege Escalation tactics

The rule now produces cleaner evidence and fewer duplicate incidents.

## 4. Fixed the failed-operation detection

The original query searched for an activity status of `Failed`, but the real AzureActivity data used `Failure`.

This is an important detection-engineering lesson. A query can look correct and remain enabled while still missing the actual events because the expected field value is wrong.

The tuned rule now:

* Accepts both Failed and Failure values
* Deduplicates operations by CorrelationId
* Groups activity by caller and source IP
* Requires at least three unique failures within ten minutes
* Maps Account and IP entities
* Includes useful custom details
* Groups related incidents
* Maps the behavior to T1078

Historical data identified six distinct failed network security group operations from the same account and IP in approximately two minutes.

## 5. Tuned the Key Vault detection

The Key Vault rule originally created one result for every failed secret request.

I changed the logic so it alerts when:

* Three or more failed secret reads occur within ten minutes, or
* At least one 401 or 403 authorization failure occurs

The query now fingerprints and deduplicates events, distinguishes authorization failures from 404 responses, and maps the IP and Azure resource entities.

The rule was aligned with Credential Access and MITRE ATT&CK T1555. The description records the more specific T1555.006 Cloud Secrets Management Stores behavior.

## 6. Exported the live detections

I exported the three live Sentinel rules into JSON files under:

`detections/sentinel/rules/`

This preserves the complete rule configuration, including:

* KQL
* Severity
* Scheduling
* MITRE mappings
* Entity mappings
* Custom details
* Alert grouping
* Incident settings

This moves the detections from portal-only objects into version-controlled detection-as-code artifacts.

## 7. Managed the detections with Bicep

I created a Bicep deployment that manages all three Sentinel analytics rules.

Before deployment, I ran `what-if`. It reported that the three rules required no changes, proving that the Bicep configuration matched the live Sentinel configuration.

The deployment then completed successfully in Incremental mode.

This gave the rules a repeatable lifecycle:

1. Edit the source-controlled rule
2. Validate the Bicep template
3. Review the what-if output
4. Deploy
5. Verify the resulting Sentinel resource

## 8. Added native incident automation

I created a Sentinel automation rule using Bicep.

For incidents created by the three MEMO analytics rules, it:

* Adds the `MEMO-Auto-Triage` label
* Adds a task called `Validate MEMO security incident`
* Provides an investigation checklist

I intentionally did not deploy a Logic App or playbook. Native Sentinel actions were enough for this lab and avoided introducing another potentially billable service.

The automation API required the complete Azure resource IDs of the analytics rules rather than only their GUIDs. This was an important troubleshooting lesson about ARM resource references.

## 9. Investigated a real historical incident

I selected Sentinel incident #22:

`MEMO - RBAC Privilege Change Detection`

The incident contained one alert and recorded one RBAC event.

I correlated the incident with AzureActivity using:

* Activity timestamp
* Operation name
* Caller
* Source IP
* Resource group
* Correlation ID
* Activity result

The investigation found one successful role-assignment write performed by the recognized lab administrator in `MEMO-RG-SECURITY`.

The rule correctly detected the activity, but the activity was an authorized part of the MEMO lab.

## 10. Closed the incident correctly

I closed incident #22 with:

* Status: Closed
* Classification: BenignPositive
* Reason: SuspiciousButExpected
* Label: MEMO-Investigated-Day14

I did not classify it as a false positive because the detection logic worked correctly. It detected real privilege-related activity. The activity was simply authorized and expected.

## What I learned

Today connected several parts of real security operations:

* Telemetry validation
* KQL tuning
* Duplicate reduction
* Detection-as-code
* MITRE ATT&CK mapping
* Entity enrichment
* Native incident automation
* Alert investigation
* Evidence-based incident classification
* Cost-aware security engineering

The biggest lesson was that generating an alert is only the beginning. A useful detection must be accurate, explainable, reproducible, and connected to an investigation process.

## Cost result

No new paid service was introduced today.

I reused existing telemetry, deployed Bicep through the Azure management plane, used native Sentinel automation, and avoided Logic Apps, playbooks, paid Defender workload plans, and additional data connectors.
