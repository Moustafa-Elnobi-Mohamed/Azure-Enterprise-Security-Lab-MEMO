#!/usr/bin/env python3

"""Validate public repository hygiene without exposing matched values."""

from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[2]
FAILURES = 0


def check(condition: bool, message: str) -> None:
    global FAILURES

    if condition:
        print(f"PASS: {message}")
    else:
        print(f"FAIL: {message}")
        FAILURES += 1


result = subprocess.run(
    ["git", "ls-files", "-z"],
    cwd=ROOT,
    check=True,
    capture_output=True,
)

tracked_files = [
    raw.decode("utf-8")
    for raw in result.stdout.split(b"\0")
    if raw
]

check(bool(tracked_files), "Tracked repository inventory is available")


unusual_names = []
empty_files = []
large_files = []
forbidden_files = []

for filename in tracked_files:
    path = ROOT / filename

    if any(ord(character) < 32 or ord(character) > 126 for character in filename):
        unusual_names.append(filename)

    if path.is_file() and path.stat().st_size == 0:
        empty_files.append(filename)

    if path.is_file() and path.stat().st_size > 5 * 1024 * 1024:
        large_files.append(filename)

    lower_name = filename.lower()

    if (
        lower_name.endswith(".tfstate")
        or lower_name.endswith(".tfplan")
        or "tfplan" in Path(filename).name.lower()
        or ".tfstate." in lower_name
        or lower_name.endswith(".pem")
        or lower_name.endswith(".pfx")
        or lower_name.endswith(".key")
        or lower_name.endswith("/.env")
        or lower_name == ".env"
    ):
        forbidden_files.append(filename)

check(not unusual_names, "Tracked filenames use portable ASCII characters")
check(not empty_files, "No empty placeholder files are tracked")
check(not large_files, "No tracked file exceeds 5 MiB")
check(not forbidden_files, "No prohibited secret or state files are tracked")


patterns = {
    "GitHub token": re.compile(
        r"gh[pousr]_[A-Za-z0-9_]{20,}"
    ),
    "Private key": re.compile(
        r"-----BEGIN [A-Z ]*PRIVATE KEY-----"
    ),
    "Azure storage credential": re.compile(
        r"(AccountKey|SharedAccessSignature)=",
        flags=re.IGNORECASE,
    ),
    "Public subscription resource ID": re.compile(
        r"/subscriptions/"
        r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-"
        r"[0-9a-f]{4}-[0-9a-f]{12}",
        flags=re.IGNORECASE,
    ),
}

findings = []

for filename in tracked_files:
    path = ROOT / filename

    if not path.is_file():
        continue

    data = path.read_bytes()

    if b"\0" in data:
        continue

    text = data.decode("utf-8", errors="ignore")

    for rule, pattern in patterns.items():
        if pattern.search(text):
            findings.append((rule, filename))

for rule, filename in findings:
    print(f"REVIEW: {rule} detected in {filename}")

check(not findings, "No credential or public subscription patterns detected")


email_pattern = re.compile(
    r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b"
)

email_findings = []

for filename in tracked_files:
    path = ROOT / filename

    if not path.is_file():
        continue

    data = path.read_bytes()

    if b"\0" in data:
        continue

    text = data.decode("utf-8", errors="ignore")

    for email in email_pattern.findall(text):
        lower_email = email.lower()

        domain = lower_email.rsplit("@", 1)[1]

        if (
            domain.endswith(".example")
            or domain.endswith(".invalid")
            or domain == "users.noreply.github.com"
        ):
            continue

        email_findings.append(filename)
        break

for filename in email_findings:
    print(f"REVIEW: Public email address detected in {filename}")

check(not email_findings, "No unintended public email addresses detected")

print()
print(f"Repository hygiene failures: {FAILURES}")

sys.exit(1 if FAILURES else 0)
