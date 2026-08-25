#!/usr/bin/env python3

"""Validate the MEMO design-only AI security documentation."""

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[2]
AI_ROOT = ROOT / "docs" / "architecture" / "ai-security"
ARCHITECTURE = AI_ROOT / "ai-security-architecture.md"
THREAT_MODEL = AI_ROOT / "ai-threat-model.md"

FAILURES = 0


def check(condition: bool, message: str) -> None:
    global FAILURES

    if condition:
        print(f"PASS: {message}")
    else:
        print(f"FAIL: {message}")
        FAILURES += 1


def read_required(path: Path) -> str:
    check(path.is_file(), f"Required file exists: {path.name}")

    if not path.is_file():
        return ""

    content = path.read_text(encoding="utf-8")
    check(bool(content.strip()), f"Required file is not empty: {path.name}")
    return content


architecture = read_required(ARCHITECTURE)
threat_model = read_required(THREAT_MODEL)

architecture_controls = {
    "Explicit design-only status": "design-only",
    "Zero-cost boundary": "$0",
    "Managed identity": "managed identity",
    "Least-privilege access": "least-privilege",
    "Private endpoint design": "private endpoint",
    "Prompt-injection defense": "prompt injection",
    "Sensitive-data protection": "sensitive data",
    "Tool allowlisting": "allowlist",
    "Output security": "output security",
    "Human approval": "human approval",
    "Security monitoring": "sentinel should detect",
    "Kill switch": "kill switch",
    "AI red-team requirement": "ai red-team",
    "No live deployment claim": "does not claim",
}

architecture_lower = architecture.lower()

for control, required_text in architecture_controls.items():
    check(
        required_text in architecture_lower,
        f"Architecture control: {control}",
    )


risk_ids = re.findall(
    r"^\| (AI-\d{2}) \|",
    threat_model,
    flags=re.MULTILINE,
)

test_ids = re.findall(
    r"^\| (RT-\d{2}) \|",
    threat_model,
    flags=re.MULTILINE,
)

check(len(risk_ids) == 12, "Twelve AI risks are documented")
check(len(set(risk_ids)) == 12, "AI risk identifiers are unique")
check(len(test_ids) == 12, "Twelve AI red-team tests are documented")
check(len(set(test_ids)) == 12, "Red-team test identifiers are unique")

threat_lower = threat_model.lower()

required_threat_controls = {
    "Protected assets": "## protected assets",
    "Threat actors": "## threat actors",
    "Trust boundaries": "## trust boundaries",
    "Risk register": "## ai security risk register",
    "Red-team plan": "## ai red-team test plan",
    "Incident response": "## ai incident-response workflow",
    "Acceptance criteria": "## production acceptance criteria",
    "Validation boundary": "## validation boundary",
}

for control, required_text in required_threat_controls.items():
    check(
        required_text in threat_lower,
        f"Threat-model section: {control}",
    )


check(
    "design-only" in architecture_lower,
    "Architecture is marked DESIGN-ONLY",
)

check(
    "design-only" in threat_lower,
    "Threat model is marked DESIGN-ONLY",
)

check(
    "no ai resource was created" in architecture_lower,
    "Architecture records that no AI resource was created",
)

check(
    "no ai endpoint" in threat_lower,
    "Threat model records that no AI endpoint was deployed",
)

check(
    "status: live" not in architecture_lower,
    "Architecture does not claim LIVE status",
)

check(
    "status: live" not in threat_lower,
    "Threat model does not claim LIVE status",
)

print()
print(f"AI security design failures: {FAILURES}")

sys.exit(1 if FAILURES else 0)
