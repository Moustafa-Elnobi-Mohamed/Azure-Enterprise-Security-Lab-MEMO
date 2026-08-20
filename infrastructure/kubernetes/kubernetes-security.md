# Day 12: Kubernetes Security

## Goal

Today I wanted to move beyond deploying a Docker container and understand how I would secure the same type of workload in Kubernetes.

I had one strict requirement: I was not going to create an AKS bill. The AKS control plane can have a free tier, but the worker nodes still cost money. Instead of pretending AKS was free, I built the manifests locally and validated them in a temporary browser-based Kubernetes cluster.

That gave me real deployment and security evidence without adding anything billable to my Azure subscription.

## What I built

I created a dedicated Kubernetes folder under:

```text
infrastructure/kubernetes/
```

The folder contains:

- A dedicated `memo-app` namespace
- A workload service account
- A hardened deployment
- A private ClusterIP service
- A ConfigMap for non-sensitive settings
- An example secret containing no real credentials
- Namespace-scoped RBAC
- Default-deny NetworkPolicies

## Namespace and Pod Security

I labeled the namespace to enforce the restricted Pod Security standard. This means Kubernetes should reject pods that do not meet the required security baseline.

The application container was configured to:

- Run as a non-root user
- Use UID and GID 101
- Disable privilege escalation
- Disable privileged mode
- Drop all Linux capabilities
- Use the `RuntimeDefault` seccomp profile
- Mount the root filesystem as read-only
- Use a small memory-backed `/tmp` volume
- Apply CPU and memory limits
- Use readiness and liveness probes

I used the unprivileged NGINX Alpine image because the standard NGINX image expects more privileged behavior and writable system paths.

## Identity and RBAC

The application uses `memo-workload-sa`, but it does not automatically receive a Kubernetes API token. It also has no Kubernetes RBAC permissions because the web application has no reason to control the cluster.

I created a separate `memo-auditor-sa` identity with read-only access to pods, services, ConfigMaps, events, deployments, ReplicaSets, and NetworkPolicies inside the namespace.

The auditor cannot read secrets, create resources, delete workloads, or make cluster-wide changes.

This was a practical least-privilege design instead of giving every identity broad access.

## Network security

I started with a default-deny NetworkPolicy for both ingress and egress.

I then added only the traffic the workload required:

- Internal access to the application on TCP port 8080
- DNS resolution through TCP and UDP port 53

The Kubernetes service uses `ClusterIP`, so the workload is not publicly exposed through a cloud load balancer.

## Deployment and troubleshooting

The first Git commit created the YAML filenames but recorded them as empty because I had not saved the files before committing. I noticed the problem when the cloud clone showed zero lines and `kubectl apply` reported that no objects were passed.

I went back, saved the files, committed the actual content, pulled the corrected commit into the temporary cluster, and verified all 255 lines were present.

After that, the namespace, ConfigMap, service accounts, RBAC, secret example, deployment, service, and three NetworkPolicies were created successfully. The application rolled out with one healthy replica and zero restarts.

The lesson was simple: creating a file in VS Code is not the same as saving it, and a successful Git push does not automatically prove that the intended content was committed. Checking file sizes, line counts, and the committed blob matters.

## Security tests

I tested the controls instead of only reading the YAML.

### Non-root runtime

The running container reported:

```text
uid=101(nginx) gid=101(nginx)
```

### Privilege escalation

The deployment returned:

```text
false
```

for `allowPrivilegeEscalation`.

### Read-only filesystem

I attempted to create `/security-test` inside the container. Kubernetes returned a read-only filesystem error.

### Service-account token

The standard Kubernetes service-account token directory was not present inside the workload.

### Workload permissions

The workload service account could not list pods and could not read secrets.

### Auditor permissions

The auditor could list pods, but it could not read secrets or delete deployments.

### Pod Security enforcement

I deliberately attempted to deploy an insecure `nginx:alpine` pod. Kubernetes rejected it because it lacked non-root enforcement, an approved seccomp profile, dropped capabilities, and privilege-escalation protection.

The rejected pod was never created.

### Network egress

The application responded successfully on its local port. An outbound HTTP request was blocked by the default-deny egress policy.

## Workload identity design

For a production AKS version, the Kubernetes service account would federate to the existing MEMO user-assigned managed identity through Microsoft Entra Workload ID.

The intended path is:

```text
memo-secure-app pod
    -> memo-workload-sa
    -> AKS OIDC federation
    -> Microsoft Entra Workload ID
    -> MEMO managed identity
    -> Key Vault Secrets User
    -> MEMO-KV-SECURITY
```

This allows the workload to retrieve approved secrets without storing a client secret in Git, application code, or Kubernetes YAML.

## Cost decision

I did not deploy:

- AKS
- Azure Container Registry
- Defender for Containers
- Log Analytics ingestion for Kubernetes
- Microsoft Sentinel ingestion for Kubernetes
- Any paid worker nodes

The temporary browser cluster automatically expires. The permanent outputs are the Kubernetes manifests, screenshots, security validation, workload identity design, and threat model.

## SC-500 concepts covered

Today covered:

- Kubernetes and application-platform security
- Secure compute configuration
- Managed and workload identity design
- Key Vault access architecture
- Least-privilege RBAC
- Namespace isolation
- Restricted Pod Security
- Network segmentation
- Secret-handling decisions
- Infrastructure as code security
- Container posture and runtime risk concepts

## Result

I finished Day 12 with a working hardened Kubernetes workload, real negative security tests, RBAC evidence, network-policy evidence, a production AKS identity design, and no Azure spending.

The next phase is Defender for Cloud and CSPM. I will review posture, recommendations, standards, and workload-protection architecture without enabling paid plans.