#!/usr/bin/env python3

"""Validate sanitized Day 15 MEMO security evidence.

This script uses only the Python standard library. It performs no Azure
writes and evaluates evidence previously collected through read-only queries.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / "docs" / "evidence" / "day15"
RESULTS: list[dict[str, str]] = []


def load_json(filename: str) -> Any:
    path = EVIDENCE / filename
    if not path.is_file():
        raise FileNotFoundError(f"Required evidence file missing: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def add(control: str, status: str, evidence: str) -> None:
    RESULTS.append(
        {
            "control": control,
            "status": status,
            "evidence": evidence,
        }
    )


def number(value: Any) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return 0.0


groups = load_json("01-resource-groups.json")
inventory = load_json("02-resource-inventory-summary.json")
defender = load_json("03-defender-pricing.json")
container = load_json("04-container-app-validation.json")
vault = load_json("05-key-vault-validation.json")
locks = load_json("06-resource-locks.json")
sentinel = load_json("07-sentinel-rules.json")
automation = load_json("08-sentinel-automation.json")
usage = load_json("09-log-analytics-usage.json")

expected_groups = {
    "MEMO-RG-Security",
    "MEMO-RG-Network",
    "MEMO-RG-Identity",
    "MEMO-RG-Development",
    "MEMO-RG-Production",
    "MEMO-RG-Monitoring",
    "MEMO-RG-Sandbox",
    "MEMO-RG-Engineering",
    "MEMO-RG-Finance",
    "MEMO-RG-HR",
    "MEMO-RG-Shared",
    "MEMO-RG-Containers",
}

actual_groups = {item.get("ResourceGroup") for item in groups}
missing_groups = sorted(expected_groups - actual_groups)
groups_healthy = all(item.get("State") == "Succeeded" for item in groups)

add(
    "Enterprise resource-group structure",
    "PASS" if not missing_groups and groups_healthy else "FAIL",
    (
        f"All {len(expected_groups)} expected resource groups are healthy."
        if not missing_groups and groups_healthy
        else f"Missing or unhealthy groups: {missing_groups}"
    ),
)

resource_total = int(inventory.get("TotalResources", 0))
add(
    "Cost-controlled Azure footprint",
    "PASS" if resource_total == 11 else "FAIL",
    f"Inventory contains {resource_total} active MEMO resources.",
)

allowed_standard = {"Discovery", "FoundationalCspm"}
standard_plans = {
    item.get("Plan")
    for item in defender
    if str(item.get("Tier") or "").lower() == "standard"
}
unexpected_standard = sorted(standard_plans - allowed_standard)

add(
    "Microsoft Defender pricing",
    "PASS" if not unexpected_standard else "FAIL",
    (
        "Only free foundational Discovery and Foundational CSPM are active; "
        "paid workload protection plans remain disabled."
        if not unexpected_standard
        else f"Unexpected Standard plans: {unexpected_standard}"
    ),
)

container_cost_ok = (
    container.get("WorkloadProfile") == "Consumption"
    and container.get("MinReplicas") == 0
    and container.get("MaxReplicas") == 1
    and number(container.get("CPU")) <= 0.25
    and container.get("Memory") == "0.5Gi"
)

add(
    "Container Apps cost controls",
    "PASS" if container_cost_ok else "FAIL",
    (
        "Consumption profile, scale 0-1, 0.25 vCPU, and 0.5Gi memory."
        if container_cost_ok
        else "Container Apps cost settings differ from the approved baseline."
    ),
)

container_security_ok = (
    container.get("ProvisioningState") == "Succeeded"
    and "SystemAssigned" in str(container.get("Identity") or "")
    and container.get("AllowInsecure") is False
)

add(
    "Container Apps identity and transport",
    "PASS" if container_security_ok else "FAIL",
    (
        "System-assigned identity is enabled and insecure ingress is disabled."
        if container_security_ok
        else "Container identity or transport security validation failed."
    ),
)

add(
    "Key Vault authorization",
    "PASS" if vault.get("RBACAuthorization") is True else "FAIL",
    "Azure RBAC authorization is enabled."
    if vault.get("RBACAuthorization") is True
    else "Azure RBAC authorization is not enabled.",
)

lock_names = {item.get("Name") for item in locks}
recovery_ok = (
    vault.get("SoftDelete") is True
    and "MEMO-KV-Delete-Protection" in lock_names
)

add(
    "Key Vault deletion recovery",
    "PASS" if recovery_ok else "FAIL",
    (
        "Soft delete and the MEMO-KV-Delete-Protection lock are active."
        if recovery_ok
        else "Soft delete or the deletion lock is missing."
    ),
)

add(
    "Key Vault purge protection",
    "PASS"
    if vault.get("PurgeProtection") is True
    else "DOCUMENTED_EXCEPTION",
    (
        "Purge protection is enabled."
        if vault.get("PurgeProtection") is True
        else
        "Purge protection remains disabled so the temporary lab can be "
        "fully removed. A reversible CanNotDelete lock mitigates deletion risk."
    ),
)

add(
    "Key Vault network isolation",
    "PASS"
    if vault.get("PublicNetworkAccess") == "Disabled"
    else "DOCUMENTED_EXCEPTION",
    (
        "Public network access is disabled."
        if vault.get("PublicNetworkAccess") == "Disabled"
        else
        "Public access remains enabled for the non-VNet-integrated lab workload. "
        "RBAC and diagnostic monitoring provide compensating controls; a paid "
        "private endpoint was intentionally excluded."
    ),
)

expected_rules = {
    "MEMO - RBAC Privilege Change Detection",
    "MEMO - Failed Azure Operation Detection",
    "MEMO - Failed Key Vault Secret Access",
}
actual_rules = {item.get("Name") for item in sentinel}
rules_ok = (
    actual_rules == expected_rules
    and all(item.get("Enabled") is True for item in sentinel)
    and all(item.get("Grouping") is True for item in sentinel)
)

add(
    "Microsoft Sentinel analytics",
    "PASS" if rules_ok else "FAIL",
    (
        "All three selected analytics rules are enabled with incident grouping."
        if rules_ok
        else "Sentinel rule inventory differs from the approved baseline."
    ),
)

automation_rules = automation.get("AutomationRules", [])
action_types = {
    action
    for rule in automation_rules
    for action in rule.get("ActionTypes", [])
}
automation_ok = (
    any(rule.get("Enabled") is True for rule in automation_rules)
    and {"ModifyProperties", "AddIncidentTask"}.issubset(action_types)
    and automation.get("RunPlaybookActions") == 0
)

add(
    "Native Sentinel automation",
    "PASS" if automation_ok else "FAIL",
    (
        "Native labeling and investigation tasks are enabled with no playbook."
        if automation_ok
        else "Sentinel automation differs from the approved baseline."
    ),
)

total_ingested = sum(number(item.get("TotalMB")) for item in usage)
total_billable = sum(number(item.get("BillableMB")) for item in usage)
usage_ok = total_billable < 1.0

add(
    "Log Analytics ingestion control",
    "PASS" if usage_ok else "FAIL",
    (
        f"{total_ingested:.6f} MB ingested and "
        f"{total_billable:.6f} MB marked billable over 30 days."
    ),
)

counts = {
    status: sum(1 for result in RESULTS if result["status"] == status)
    for status in ("PASS", "FAIL", "DOCUMENTED_EXCEPTION")
}

overall = (
    "FAIL"
    if counts["FAIL"]
    else "PASS_WITH_EXCEPTIONS"
    if counts["DOCUMENTED_EXCEPTION"]
    else "PASS"
)

generated = datetime.now(timezone.utc).isoformat()

report = {
    "generatedUtc": generated,
    "overallStatus": overall,
    "summary": counts,
    "results": RESULTS,
}

json_path = EVIDENCE / "10-python-security-assurance.json"
json_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

markdown_lines = [
    "# MEMO Day 15 Python Security Assurance Report",
    "",
    f"Generated: `{generated}`",
    "",
    f"Overall result: **{overall}**",
    "",
    f"- Passed controls: **{counts['PASS']}**",
    f"- Failed controls: **{counts['FAIL']}**",
    f"- Documented exceptions: **{counts['DOCUMENTED_EXCEPTION']}**",
    "",
    "| Control | Status | Evidence |",
    "|---|---|---|",
]

for result in RESULTS:
    evidence = result["evidence"].replace("|", "\\|")
    markdown_lines.append(
        f"| {result['control']} | {result['status']} | {evidence} |"
    )

markdown_lines.extend(
    [
        "",
        "## Result interpretation",
        "",
        "A documented exception is an intentional lab design decision with a "
        "recorded reason and compensating control. It is not treated as a "
        "silent pass.",
        "",
        "The validator performs no Azure writes and uses only sanitized "
        "evidence committed to the repository.",
    ]
)

markdown_path = EVIDENCE / "10-python-security-assurance.md"
markdown_path.write_text(
    "\n".join(markdown_lines) + "\n",
    encoding="utf-8",
)

for result in RESULTS:
    print(f"[{result['status']}] {result['control']}")

print()
print(
    f"Overall: {overall} | "
    f"Pass: {counts['PASS']} | "
    f"Fail: {counts['FAIL']} | "
    f"Exceptions: {counts['DOCUMENTED_EXCEPTION']}"
)
print(f"JSON report: {json_path}")
print(f"Markdown report: {markdown_path}")

sys.exit(1 if counts["FAIL"] else 0)
