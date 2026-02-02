

# complex

![Version: 1.5.2](https://img.shields.io/badge/Version-1.5.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

For deploying applications, consumers and cronjobs

## Features

The **complex** Helm chart provides a comprehensive solution for deploying containerized applications with:

- **ConfigMap integration**: Environment variables and file mounting from ConfigMaps
- **Secret integration**: Environment variables and file mounting from Secrets 
- **Volume mounts**: Mount ConfigMaps and Secrets as files with custom paths
- **Persistent storage**: Create new PVCs or reference existing ones for shared storage (EFS)
- **Consumer workloads**: Support for consumer-type deployments
- **CronJob support**: Scheduled job execution
- **Enterprise features**: Immutable ConfigMaps, custom labels/annotations
- **GitLab integration**: Built-in GitLab CI/CD support via lib-gitlab dependency
- **Kubernetes best practices**: Following cloud-native patterns via lib-kubernetes
- **Prometheus monitoring**: Integrated metrics and alerting via lib-prometheus

## Component Types

The chart supports multiple component types for different workload patterns:

### 1. HTTP Components (`type: http`)
Web services and APIs with HTTP endpoints.

**Creates**: Deployment, Service, optionally Ingress, HPA, Target Groups

### 2. HTTP Internal Components (`type: http-internal`)
Internal web services and APIs that are not exposed externally.

**Creates**: Deployment, Service, optionally HPA (does not create Ingress or Target Groups)

### 3. Consumer Components (`type: consumer`)
Background workers that process messages from queues.

**Creates**: Deployment, optionally KEDA ScaledObject for auto-scaling

### 4. CronJob Components (`type: cronjob`)
Scheduled tasks that run periodically.

**Creates**: CronJob

### 5. Pre-Job Components (`type: pre-job`)
One-time jobs that run before the main application (e.g., migrations).

**Creates**: Job

### 6. Ingress Components (`type: ingress`)
Standalone ingress resources that route to external services without creating deployments.

**Creates**: Ingress only (no Deployment or Service)

**Use Cases**:
- API documentation aggregators
- Reverse proxy configurations
- Routing to services managed by other charts
- Multiple ingress resources with different authentication

**Key Features**:
- Route to external services using `externalService` field in paths
- Create multiple independent ingress resources (one per component)
- Full support for AWS ALB and NGINX ingress controllers
- Custom annotations for authentication (OIDC, etc.)
- Support for multiple hosts and TLS configurations

**Example**:
```yaml
components:
  api-docs-aggregator:
    type: ingress
    ingress:
      className: alb
      annotations:
        alb.ingress.kubernetes.io/scheme: internet-facing
        alb.ingress.kubernetes.io/healthcheck-path: "/-/health"
      hosts:
        - host: docs.example.com
          paths:
            - path: /docs/service1
              pathType: Prefix
              externalService: service1-svc
              port: 80
            - path: /docs/service2
              pathType: Prefix
              externalService: service2-svc
              port: 8080
```

See `testing-values/values-ingress-only.yaml` for complete examples including:
- Multiple ingress resources with different authentication
- OIDC/SSO integration
- Multi-domain routing
- Path-based routing patterns

## Traefik Middlewares

The chart supports defining Traefik Middleware resources at both global and component levels.

> **Note**: To use this feature, the Traefik Custom Resource Definitions (CRDs) must be installed in the cluster.
> See [Traefik CRD Documentation](https://doc.traefik.io/traefik/reference/install-configuration/providers/kubernetes/kubernetes-crd/) for details.
> See [Traefik Middleware Documentation](https://doc.traefik.io/traefik/reference/routing-configuration/kubernetes/crd/http/middleware/) for details.

### Defining Middlewares

**Global Middlewares** (`global.traefikMiddlewares`) are created once and can be referenced by any component:

```yaml
global:
  traefikMiddlewares:
    - name: security-headers
      spec:
        headers:
          stsSeconds: 31536000
          stsIncludeSubdomains: true
```

**Component Middlewares** (`components.<name>.traefikMiddlewares`) are created for that specific component:

```yaml
components:
  api:
    traefikMiddlewares:
      - name: strip-prefix
        spec:
          stripPrefix:
            prefixes:
              - /api
```

### Referencing Middlewares in Ingress

Use `ingress.traefikMiddlewareRefs` to apply middlewares to an ingress (sets `traefik.ingress.kubernetes.io/router.middlewares` annotation):

```yaml
components:
  api:
    ingress:
      className: traefik
      hosts:
        - host: api.example.com
          paths:
            - path: /
              pathType: Prefix
              servicePort: 8080
      traefikMiddlewareRefs:
        - global:security-headers    # Reference global middleware
        - strip-prefix               # Reference component middleware
        - auth@file                  # External middleware reference
    traefikMiddlewares:
      - name: strip-prefix
        spec:
          stripPrefix:
            prefixes:
              - /api
```

**Reference formats:**
- `global:<name>` - Global middleware (e.g., `global:security-headers`)
- `<name>` - Component middleware (e.g., `strip-prefix`)
- `<name>@<provider>` - External reference (e.g., `auth@file`, `other-middleware@kubernetescrd`)

## Init Containers

The chart supports defining init containers that run before the main container starts. Init containers are useful for:

- Running setup scripts or database migrations
- Waiting for dependent services to be ready
- Downloading configuration files or secrets
- Setting up volumes with proper permissions

### Defining Init Containers

Init containers are defined at the component level using `initContainers`:

```yaml
components:
  api:
    type: http
    ports:
      - port: 3000
    initContainers:
      wait-for-db:
        image:
          repository: busybox
          tag: "1.36"
        command:
          - sh
          - -c
          - |
            until nc -z postgres-service 5432; do
              echo "Waiting for database..."
              sleep 2
            done
        resources:
          requests:
            cpu: "50m"
            memory: "64M"
          limits:
            cpu: "100m"
            memory: "128M"
```

### Init Container Properties

Each init container supports the same properties as regular containers:

| Property | Description | Required |
|----------|-------------|----------|
| `image.repository` | Container image repository | Yes |
| `image.tag` | Container image tag | Yes |
| `image.pullPolicy` | Image pull policy (IfNotPresent, Always, Never) | No |
| `command` | Override container entrypoint | No |
| `args` | Arguments to the entrypoint | No |
| `envs.values` | Environment variables as key-value pairs | No |
| `envs.from.configMaps` | Load env vars from ConfigMaps | No |
| `envs.from.secrets` | Load env vars from Secrets | No |
| `resources` | CPU/memory requests and limits | No |
| `volumeMounts` | Mount ConfigMaps or Secrets as files | No |


## Configuration Structure

### Global vs Component-Specific Configuration

The chart uses a **two-level configuration system**:

1. **Global**: Default settings applied to all components
2. **Component-specific**: Overrides for individual components

**Component-specific settings always override global settings.**

### Environment Variables Priority

Environment variables are merged in the following order (later overrides earlier):

1. **Global values** (`global.container.envs.values`)
2. **Component-specific values** (`components.<n>.envs.values`)
3. **Global envFrom** (`global.container.envs.from.configMaps/secrets`)
4. **Component-specific envFrom** (`components.<n>.envs.from.configMaps/secrets`)

#### Priority Examples

**Example 1 - Component overrides Global:**
```yaml
global:
  container:
    envs:
      values:
        DATABASE_URL: "postgresql://global-db:5432/app"
        LOG_LEVEL: "info"

components:
  api:
    envs:
      values:
        DATABASE_URL: "postgresql://api-db:5432/api"  # Component value takes precedence
        API_KEY: "api-specific-key"
```

**Result for `api` component:**
- `DATABASE_URL=postgresql://api-db:5432/api` ← Component-specific value
- `LOG_LEVEL=info` ← Inherited from global configuration
- `API_KEY=api-specific-key` ← Component-specific value

**Example 2 - envFrom vs hardcoded values:**
```yaml
# ConfigMap contains: API_KEY=from-configmap
global:
  container:
    envs:
      values:
        API_KEY: "hardcoded-value"  # Applied first
      from:
        configMaps:
          - app-config              # Overrides hardcoded values

components:
  api:
    envs:
      values:
        API_KEY: "component-hardcoded"  # Has highest priority
```

**Result for `api` component:**
- `API_KEY=component-hardcoded` ← Component-specific value has highest priority

**Priority order (highest to lowest):**
1. **Component hardcoded values** (`components.<n>.envs.values`)
2. **Component envFrom** (`components.<n>.envs.from.*`)
3. **Global envFrom** (`global.container.envs.from.*`)
4. **Global hardcoded values** (`global.container.envs.values`)

### Volume Mounts Priority

Volume mounts support **granular overrides** where components can override just `configMaps` or just `secrets`:

**Component-specific volumeMounts always override global volumeMounts at the configMaps/secrets level.**

#### Volume Mounts Examples

**Example 1 - Inherit all global volume mounts:**
```yaml
global:
  container:
    volumeMounts:
      configMaps:
        - name: app-config
          configMapName: app-config
          mountPath: /app/config
      secrets:
        - name: app-secret
          secretName: app-secret
          mountPath: /app/secrets

components:
  api:
    # No volumeMounts defined - inherits all global volumeMounts
```

**Example 2 - Override only configMaps, inherit secrets:**
```yaml
components:
  web:
    volumeMounts:
      configMaps:
        - name: web-config
          configMapName: web-specific-config
          mountPath: /app/web-config
      # secrets not defined - inherits global secrets
```

**Example 3 - Override only secrets, inherit configMaps:**
```yaml
components:
  worker:
    volumeMounts:
      secrets:
        - name: worker-secret
          secretName: worker-specific-secret
          mountPath: /app/worker-secrets
      # configMaps not defined - inherits global configMaps
```

**Example 4 - Explicitly exclude all global volumes:**
```yaml
components:
  maintenance:
    volumeMounts:
      configMaps: []  # Empty array = no configMap volumes
      secrets: []     # Empty array = no secret volumes
```

## Persistent Volume Claims

The chart supports creating PersistentVolumeClaims (PVCs) for components that need persistent storage. You can either create a new PVC or reference an existing one to share storage across multiple pods.

### Creating a New PVC

When `persistentVolumeClaim` is configured without `useExistingClaim`, the chart creates a new PVC for the component:

```yaml
components:
  api:
    type: http
    persistentVolumeClaim:
      size: 10Gi
      accessModes:
        - ReadWriteOnce
      storageClassName: standard
      # Optional: Add custom annotations (e.g., for EFS access points)
      annotations:
        efs.csi.aws.com/access-point-id: "fsap-0123456789abcdef0"
      # Optional: Add custom labels
      labels:
        storage-tier: "premium"
    volumeMounts:
      others:
        - name: data
          mountPath: /app/data
          readOnly: false
```

**PVC Properties:**

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | string | `"1Gi"` | Storage size (e.g., "1Gi", "10Gi") |
| `accessModes` | array | `["ReadWriteOnce"]` | Access modes: `ReadWriteOnce`, `ReadOnlyMany`, `ReadWriteMany`, `ReadWriteOncePod` |
| `storageClassName` | string | - | Storage class name for the PVC |
| `annotations` | object | `{}` | Custom annotations (useful for storage-specific configurations) |
| `labels` | object | `{}` | Custom labels |
| `selector` | object | - | Label selector for binding to specific PVs |
| `volumeName` | string | - | Name of the PersistentVolume to bind to |

### Using an Existing PVC

To share storage across multiple pods or reference a PVC created outside the chart, use `useExistingClaim`:

```yaml
components:
  api:
    type: http
    persistentVolumeClaim:
      useExistingClaim: true
      existingClaimName: "shared-storage-pvc"
    volumeMounts:
      others:
        - name: data
          mountPath: /app/data
          readOnly: false

  worker:
    type: consumer
    persistentVolumeClaim:
      useExistingClaim: true
      existingClaimName: "shared-storage-pvc"  # Same PVC as api component
    volumeMounts:
      others:
        - name: data
          mountPath: /data
          readOnly: false
```

**Benefits of Using Existing PVCs:**

- **Shared storage**: Multiple pods can mount the same PVC (requires `ReadWriteMany` access mode)
- **Pre-existing storage**: Reference PVCs created manually or by other charts
- **Storage reuse**: Avoid creating duplicate PVCs for the same storage

**Important Notes:**

- When `useExistingClaim: true`, the chart does **not** create a PVC - it only references the existing one
- The existing PVC must already exist in the same namespace
- Ensure the PVC's access mode supports your use case (e.g., `ReadWriteMany` for multi-pod access)

### Complete Example

```yaml
components:
  # Component that creates a new PVC
  web:
    type: http
    persistentVolumeClaim:
      size: 5Gi
      accessModes:
        - ReadWriteMany  # Allows multiple pods to mount
      storageClassName: efs-sc
      annotations:
        efs.csi.aws.com/access-point-id: "fsap-0123456789abcdef0"
    volumeMounts:
      others:
        - name: data
          mountPath: /usr/share/nginx/html

  # Component that uses the existing PVC created above
  api:
    type: http
    persistentVolumeClaim:
      useExistingClaim: true
      existingClaimName: "my-release-web"  # References the PVC created by web component
    volumeMounts:
      others:
        - name: data
          mountPath: /app/data
```

See `testing-values/values-pvc.yaml` and `testing-values/values-pvc-efs-shared.yaml` for more examples.

## Installation

```bash
helm repo add cookielab https://helm.cookielab.dev
helm install my-app cookielab/complex
```

## Usage Examples

### Basic Deployment
```yaml
global:
  container:
    image:
      repository: myapp
      tag: "latest"
```

### With ConfigMap Environment Variables
```yaml
global:
  configMaps:
    app-config:
      data:
        DATABASE_URL: "postgresql://localhost:5432/myapp"
        APP_NAME: "my-application"
  container:
    envs:
      from:
        configMaps:
          - app-config
```

### With Secret Environment Variables
```yaml
global:
  secrets:
    app-secrets:
      data:
        DATABASE_PASSWORD: "supersecretpassword"
        API_KEY: "secret-api-key"
        JWT_SECRET: "jwt-signing-secret"
  container:
    envs:
      from:
        secrets:
          - app-secrets
components:
  api:
    type: http
    ports:
      - port: 3000
```

### With Volume Mounts
```yaml
global:
  configMaps:
    nginx-config:
      data:
        nginx.conf: |
          server {
            listen 80;
            server_name myapp.local;
            location / {
              return 200 'Hello World!';
            }
          }
  container:
    volumeMounts:
      configMaps:
        - name: config-volume
          configMapName: nginx-config
          mountPath: /etc/nginx/conf.d
          subPath: nginx.conf
          readOnly: true
      secrets:
        - name: tls-certs
          secretName: app-tls
          mountPath: /etc/ssl/certs
          readOnly: true
```

## Complete Examples

The following complete configuration examples are available in the `testing-values/` directory:

- [`values-minimal.yaml`](testing-values/values-minimal.yaml) - Basic HTTP service
- [`values-configmap.yaml`](testing-values/values-configmap.yaml) - ConfigMap integration
- [`values-volume-mounts.yaml`](testing-values/values-volume-mounts.yaml) - Volume mount examples
- [`values-pvc.yaml`](testing-values/values-pvc.yaml) - PersistentVolumeClaim examples
- [`values-pvc-efs-shared.yaml`](testing-values/values-pvc-efs-shared.yaml) - Shared storage with existing PVCs
- [`values-consumer.yaml`](testing-values/values-consumer.yaml) - Consumer workloads
- [`values-cronjob.yaml`](testing-values/values-cronjob.yaml) - Scheduled jobs
- [`values-hpa.yaml`](testing-values/values-hpa.yaml) - Auto-scaling configuration
- [`values-ingress-only.yaml`](testing-values/values-ingress-only.yaml) - Standalone ingress configurations

## Requirements

Kubernetes: `>= 1.25.0-0 < 2.0.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../lib-gitlab | lib-gitlab | 0.1.0 |
| file://../lib-kubernetes | lib-kubernetes | 0.5.0 |
| file://../lib-prometheus | lib-prometheus | 0.1.7 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.container.envs.from.configMaps | list | `[]` |  |
| global.container.envs.from.secrets | list | `[]` |  |
| global.container.envs.values | object | `{}` |  |
| global.container.image.pullPolicy | string | `"IfNotPresent"` |  |
| global.container.resources.limits.cpu | string | `"200m"` |  |
| global.container.resources.limits.ephemeralStorage | string | `"1Gi"` |  |
| global.container.resources.limits.memory | string | `"256M"` |  |
| global.container.resources.requests.cpu | string | `"200m"` |  |
| global.container.resources.requests.ephemeralStorage | string | `"1Gi"` |  |
| global.container.resources.requests.memory | string | `"256M"` |  |
| global.metadata | object | `{}` |  |
| global.nodeSelector | object | `{}` |  |
| global.rollingUpdate.maxSurge | string | `"100%"` |  |
| global.rollingUpdate.maxUnavailable | string | `"0%"` |  |
| global.service.type | string | `"ClusterIP"` |  |
