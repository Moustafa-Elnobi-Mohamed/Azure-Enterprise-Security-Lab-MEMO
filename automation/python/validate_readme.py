#!/usr/bin/env python3

"""Validate the recruiter-facing MEMO repository README."""

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[2]
README = ROOT / "README.md"
FAILURES = 0


def check(condition: bool, message: str) -> None:
    global FAILURES

    if condition:
        print(f"PASS: {message}")
    else:
        print(f"FAIL: {message}")
        FAILURES += 1


check(README.is_file(), "README exists")
content = README.read_text(encoding="utf-8") if README.is_file() else ""
check(bool(content.strip()), "README is not empty")


required_sections = [
    "## Executive summary",
    "## Engineering lifecycle",
    "## Final measurements",
    "## Implementation boundary",
    "## Architecture flow",
    "## Identity and non-human identity security",
    "## Platform and container security",
    "## Detection engineering and incident response",
    "## Secure AI architecture",
    "## Automated security assurance",
    "## Cost-aware engineering",
    "## Repository navigation",
    "## Run the security assurance",
    "## Scope and limitations",
    "## Project outcome",
]

for section in required_sections:
    check(section in content, f"README section: {section}")


required_boundaries = [
    "PASS_WITH_EXCEPTIONS",
    "Design-only",
    "No AI endpoint or paid AI service was deployed.",
    "No design-only artifact is represented as a live Azure deployment.",
]

for boundary in required_boundaries:
    check(boundary in content, f"README boundary: {boundary}")

links = re.findall(r"\[[^\]]+\]\(([^)]+)\)", content)
local_links = [
    link
    for link in links
    if not link.startswith(("http://", "https://", "#"))
]

broken_links = [
    link
    for link in local_links
    if not (ROOT / link).exists()
]

for link in broken_links:
    print(f"FAIL: Broken README link: {link}")

check(not broken_links, "All local README links resolve")
check(len(local_links) >= 10, "README provides useful repository navigation")

print()
print(f"README validation failures: {FAILURES}")

sys.exit(1 if FAILURES else 0)
