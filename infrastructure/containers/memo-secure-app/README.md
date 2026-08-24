# MEMO Secure Container

This directory contains the reproducible container artifact for the MEMO secure workload.

## Security controls

- NGINX unprivileged base image
- Explicit non-root UID and GID 101
- Unprivileged port 8080
- No additional operating-system packages
- No embedded credentials or secrets
- Health-check endpoint
- Security response headers
- Restricted Docker build context
- Read-only root filesystem compatibility
- Dropped Linux capabilities compatibility
- RuntimeDefault seccomp compatibility

## Build

Run:

    docker build --tag memo-secure-app:1.0.0 infrastructure/containers/memo-secure-app

## Hardened runtime test

Run:

    docker run --detach --name memo-secure-app-test --user 101:101 --read-only --tmpfs /tmp:rw,noexec,nosuid,size=16m --cap-drop ALL --security-opt no-new-privileges:true --publish 8080:8080 memo-secure-app:1.0.0

The image is built and tested in GitHub Actions. It is not pushed to Azure Container Registry because ACR was intentionally excluded from this zero-cost lab.
