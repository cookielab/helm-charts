

# complex

![Version: 1.0.5](https://img.shields.io/badge/Version-1.0.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

For deploying applications, consumers and cronjobs

## Features

The **complex** Helm chart provides a comprehensive solution for deploying containerized applications with:

- **ConfigMap integration**: Environment variables and file mounting from ConfigMaps
- **Secret integration**: Environment variables and file mounting from Secrets 
- **Volume mounts**: Mount ConfigMaps and Secrets as files with custom paths
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
- [`values-consumer.yaml`](testing-values/values-consumer.yaml) - Consumer workloads
- [`values-cronjob.yaml`](testing-values/values-cronjob.yaml) - Scheduled jobs
- [`values-hpa.yaml`](testing-values/values-hpa.yaml) - Auto-scaling configuration

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
