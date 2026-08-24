#!/usr/bin/env python3

"""Validate MEMO infrastructure and workload artifacts without cloud writes."""

from pathlib import Path
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


kubernetes_root = ROOT / "infrastructure" / "kubernetes"
container_root = ROOT / "infrastructure" / "containers" / "memo-secure-app"
bicep_root = ROOT / "infrastructure" / "bicep"
terraform_root = ROOT / "automation" / "terraform"

expected_kubernetes_files = {
    "configmap.yaml",
    "deployment.yaml",
    "namespace.yaml",
    "network-policy.yaml",
    "rbac.yaml",
    "secret-example.yaml",
    "service-account.yaml",
    "service.yaml",
}

actual_kubernetes_files = {
    path.name for path in kubernetes_root.glob("*.yaml")
}

check(
    actual_kubernetes_files == expected_kubernetes_files,
    "All eight Kubernetes manifests are present",
)

for filename in sorted(expected_kubernetes_files):
    path = kubernetes_root / filename
    check(
        path.is_file() and path.stat().st_size > 0,
        f"Kubernetes manifest is not empty: {filename}",
    )

kubernetes_content = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted(kubernetes_root.glob("*.yaml"))
)

kubernetes_controls = {
    "Restricted Pod Security": "pod-security.kubernetes.io/enforce: restricted",
    "Non-root execution": "runAsNonRoot: true",
    "No privilege escalation": "allowPrivilegeEscalation: false",
    "Read-only root filesystem": "readOnlyRootFilesystem: true",
    "Dropped capabilities": "drop:",
    "RuntimeDefault seccomp": "type: RuntimeDefault",
    "Disabled token mounting": "automountServiceAccountToken: false",
    "Resource limits": "limits:",
    "NetworkPolicy": "kind: NetworkPolicy",
    "ClusterIP service": "type: ClusterIP",
    "Version-pinned workload image": (
        "image: nginxinc/nginx-unprivileged:1.28.1-alpine"
    ),
}

for name, marker in kubernetes_controls.items():
    check(marker in kubernetes_content, name)

expected_container_files = {
    "Dockerfile",
    ".dockerignore",
    "default.conf",
    "index.html",
    "README.md",
}

actual_container_files = {
    path.name for path in container_root.iterdir()
    if path.is_file()
}

check(
    expected_container_files.issubset(actual_container_files),
    "All secure-container artifacts are present",
)

for filename in sorted(expected_container_files):
    path = container_root / filename
    check(
        path.is_file() and path.stat().st_size > 0,
        f"Container artifact is not empty: {filename}",
    )

dockerfile = (container_root / "Dockerfile").read_text(encoding="utf-8")
nginx_config = (container_root / "default.conf").read_text(encoding="utf-8")
container_content = dockerfile + "\n" + nginx_config

container_controls = {
    "Version-specific container base": "1.28.1-alpine",
    "Explicit container UID and GID": "USER 101:101",
    "Unprivileged container port": "EXPOSE 8080",
    "Container health check": "HEALTHCHECK",
    "NGINX server tokens disabled": "server_tokens off",
    "Content-type response protection": "X-Content-Type-Options",
    "Frame response protection": "X-Frame-Options",
    "Content Security Policy": "Content-Security-Policy",
}

for name, marker in container_controls.items():
    check(marker in container_content, name)

check("USER root" not in dockerfile, "Dockerfile never switches to root")
check(
    "COPY . " not in dockerfile and "ADD . " not in dockerfile,
    "Dockerfile copies only required artifacts",
)

terraform_files = [
    path
    for path in terraform_root.rglob("*.tf")
    if ".terraform" not in path.parts
]
bicep_files = list(bicep_root.rglob("*.bicep"))
generated_arm_files = list(bicep_root.rglob("*.json"))

check(
    len(terraform_files) >= 20,
    f"Terraform module inventory is present: {len(terraform_files)} files",
)
check(
    len(bicep_files) == 4,
    "All four Bicep deployments are present",
)
check(
    not generated_arm_files,
    "No generated ARM JSON files are tracked beside Bicep",
)

print()
print(f"Repository artifact failures: {FAILURES}")
sys.exit(1 if FAILURES else 0)
