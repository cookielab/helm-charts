

# prometheus-rules

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

For deploying separated Prometheus Rules for global definitions

## Use Case

This chart is designed for **generic, non-application-specific alerts** that apply across your infrastructure. While application-specific alerts should be defined within your application charts, this chart handles:

- **Infrastructure alerts**: OOM kills, disk space, node issues
- **Namespace-level monitoring**: Resource usage across namespaces 
- **Cross-cutting concerns**: Alerts that span multiple applications
- **Platform team alerts**: Infrastructure and cluster health monitoring

**Example use cases:**
- OOM alerts in any namespace
- Node disk space warnings
- Cluster-wide resource exhaustion
- Generic Kubernetes object monitoring

## Features

The **prometheus-rules** Helm chart provides a flexible solution for managing Prometheus alerting rules with:

- **Global label management**: Consistent labeling across all alert rules
- **Template interpolation**: Dynamic environment and project values in alert expressions
- **Custom labels per alert**: Override global labels for specific alerts
- **Metadata integration**: Project and environment context
- **Kubernetes native**: Creates PrometheusRule CRDs for Prometheus Operator

## What This Chart Creates

The chart creates **PrometheusRule** custom resources that define alert rules for Prometheus. These rules are automatically discovered by the Prometheus Operator and loaded into your Prometheus instance.

### Created Resources

- **PrometheusRule**: Named `{release-name}-global-alerts`, contains all your alert definitions grouped under a single rule group
- **Alert Rules**: Each alert is prefixed with the release name: `{release-name}-{alertName}`

## Configuration Structure

### Required Configuration

- **`alertRules`**: Array of alert rules to create (required)

### Optional Global Configuration

Global settings apply to all alert rules and provide consistent labeling and metadata:

- **`global.alertLabels`**: Labels applied to all alerts (can be overridden per alert)
- **`global.metadata.partOf`**: Project identifier used in template interpolation

**Note**: If `global` section is omitted, default values will be used for template interpolation.

### Alert Rule Configuration

Each alert rule in the `alertRules` array supports:

- **`alertName`**: Name of the alert (required)
- **`expression`**: Prometheus query expression (required)
- **`for`**: Duration condition must be true before firing (required)
- **`description`**: Detailed description of the alert (required)
- **`summary`**: Brief summary of the alert (required)
- **`labels`**: Custom labels for this specific alert (optional)

### Label Priority

Labels are merged in the following order (later overrides earlier):

1. **Global labels** (`global.alertLabels`)
2. **Alert-specific labels** (`alertRules[].labels`)

## Template Interpolation

Alert expressions support template variables that are automatically replaced during deployment:

- **Template variables**: `{ { .Environment } }` and `{ { .Project } }` (without spaces)
- **Environment**: Replaced with `global.alertLabels.environment` (or `"default-env"` if not set) 
- **Project**: Replaced with `global.metadata.partOf` (or `"default-project"` if not set)

**Example:**
```yaml
global:
  alertLabels:
    environment: production
  metadata:
    partOf: web-app

alertRules:
  - alertName: AppDown
    expression: "up{job='{ { .Project } }-{ { .Environment } }'} == 0"
    # During deployment becomes: "up{job='web-app-production'} == 0"
```

**Alert Naming**: All alerts are prefixed with the Helm release name. Example:
- Release name: `monitoring` 
- Alert name: `HighCPUUsage`
- **Actual alert name**: `monitoring-HighCPUUsage`

## Installation

```bash
helm repo add cookielab https://helm.cookielab.dev
helm install my-alerts cookielab/prometheus-rules
```

## Usage Examples

### Minimal Configuration
# Minimal configuration with default global settings
alertRules:
  - alertName: HighCPUUsage
    expression: "rate(container_cpu_usage_seconds_total[5m]) > 0.8"
    for: 5m
    description: "High CPU usage detected"
    summary: "CPU usage is above 80% for the last 5 minutes"

### Basic Configuration with Global Settings 
global:
  alertLabels:
    severity: critical
    environment: prod
  metadata:
    partOf: my-project

alertRules:
  - alertName: HighCPUUsage
    expression: "rate(container_cpu_usage_seconds_total[5m]) > 0.8"
    for: 5m
    description: "High CPU usage detected"
    summary: "CPU usage is above 80% for the last 5 minutes"

### Advanced Configuration with Multiple Alerts
global:
  alertLabels:
    severity: warning
    environment: production
    team: platform
  metadata:
    partOf: monitoring-stack

alertRules:
  - alertName: HighCPUUsage
    expression: "rate(container_cpu_usage_seconds_total[5m]) > 0.8"
    for: 5m
    description: "High CPU usage detected across cluster"
    summary: "CPU usage is above 80% for the last 5 minutes"
    labels:
      priority: high
     
  - alertName: HighMemoryUsage
    expression: "container_memory_working_set_bytes / container_spec_memory_limit_bytes > 0.9"
    for: 10m
    description: "High memory usage detected"
    summary: "Memory usage is above 90% for the last 10 minutes"
    labels:
      priority: medium
     
  - alertName: PodCrashLooping
    expression: "increase(kube_pod_container_status_restarts_total[30m]) > 3"
    for: 5m
    description: "Pod is crash looping"
    summary: "Pod is crash looping and restarting frequently"
    labels:
      severity: critical
      priority: urgent

### Environment-Specific Configuration
global:
  alertLabels:
    severity: warning
    environment: production
    project: web-app
  metadata:
    partOf: web-application

alertRules:
  - alertName: ApplicationDown
    expression: "up{job='web-app-production'} == 0"
    for: 1m
    description: "Application web-app is down in production"
    summary: "Application is not responding to health checks"
    labels:
      severity: critical
     
  - alertName: DatabaseConnectionFailure
    expression: "mysql_up{environment='production'} == 0"
    for: 2m
    description: "Database connection failure in production"
    summary: "Cannot connect to database"

### Generic Infrastructure Alerts
# Generic infrastructure alerts - not tied to specific applications
global:
  alertLabels:
    severity: warning
    team: platform
    environment: production
  metadata:
    partOf: infrastructure

alertRules:
  - alertName: PodOOMKilled
    expression: "increase(kube_pod_container_status_restarts_total{reason='OOMKilled'}[10m]) > 0"
    for: 0m
    description: "Pod was killed due to OOM (Out of Memory)"
    summary: "Pod was OOMKilled in namespace"
    labels:
      severity: critical
     
  - alertName: NamespaceHighMemoryUsage
    expression: "sum(container_memory_working_set_bytes{container!='POD'}) by (namespace) / sum(container_spec_memory_limit_bytes{container!='POD'}) by (namespace) > 0.8"
    for: 5m
    description: "Namespace memory usage is above 80%"
    summary: "Namespace memory usage is high"
   
  - alertName: NodeDiskSpaceRunningOut
    expression: "(1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) > 0.85"
    for: 5m
    description: "Node disk space is running out"
    summary: "Node disk usage is above 85%"
    labels:
      severity: critical

## Complete Examples

The following complete configuration examples are available in the `testing-values/` directory:

- [`values-minimal.yaml`](testing-values/values-minimal.yaml) - Minimal configuration without global section
- [`values-infrastructure.yaml`](testing-values/values-infrastructure.yaml) - Infrastructure alerts (OOM, disk space, etc.)
- [`values-template-interpolation.yaml`](testing-values/values-template-interpolation.yaml) - Template variable usage
- [`values-multi-environment.yaml`](testing-values/values-multi-environment.yaml) - Multi-environment alert setup

## Best Practices

### 1. Consistent Labeling
Use global labels for consistent categorization:
```yaml
global:
  alertLabels:
    severity: warning
    team: platform
    environment: production
```

### 2. Meaningful Alert Names
Use descriptive names that indicate the problem:
```yaml
alertRules:
  - alertName: DatabaseConnectionFailure  # Good
  - alertName: DB_Error                   # Less clear
```

### 3. Appropriate Alert Timing
Set reasonable `for` durations to avoid alert fatigue:
```yaml
alertRules:
  - alertName: HighCPUUsage
    for: 5m    # Wait 5 minutes before firing
```

### 4. Template Usage
Use templates for environment-specific deployments:
```yaml
expression: "up{environment='{ { .Environment } }'} == 0"
# Becomes: "up{environment='production'} == 0"
```

### 5. Release Name Prefix
Remember that alert names will be prefixed with your release name:
```yaml
# With release name "my-monitoring":
alertRules:
  - alertName: DatabaseDown
    # Creates alert: "my-monitoring-DatabaseDown"
```

## Common Alert Patterns

### Resource Usage Alerts
```yaml
alertRules:
  - alertName: HighCPUUsage
    expression: "rate(container_cpu_usage_seconds_total[5m]) > 0.8"
    for: 5m
  
  - alertName: HighMemoryUsage
    expression: "container_memory_working_set_bytes / container_spec_memory_limit_bytes > 0.9"
    for: 10m
```

### Application Health Alerts
```yaml
alertRules:
  - alertName: ApplicationDown
    expression: "up{job='my-app'} == 0"
    for: 1m
   
  - alertName: HighErrorRate
    expression: "rate(http_requests_total{status=~'5..'}[5m]) > 0.1"
    for: 2m
```

### Kubernetes-Specific Alerts
```yaml
alertRules:
  - alertName: PodCrashLooping
    expression: "increase(kube_pod_container_status_restarts_total[30m]) > 3"
    for: 5m
   
  - alertName: PodPending
    expression: "kube_pod_status_phase{phase='Pending'} > 0"
    for: 10m
```

## Requirements

Kubernetes: `>= 1.25.0-0 < 2.0.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alertRules[0].alertName | string | `"HighCPUUsage"` |  |
| alertRules[0].description | string | `"High CPU usage detected"` |  |
| alertRules[0].expression | string | `"avg_over_time(cpu_usage[5m]) > 80"` |  |
| alertRules[0].for | string | `"5m"` |  |
| alertRules[0].labels.priority | string | `"high"` |  |
| alertRules[0].summary | string | `"CPU usage is above 80% for the last 5 minutes"` |  |
| alertRules[1].alertName | string | `"HighMemoryUsage-stage"` |  |
| alertRules[1].description | string | `"High memory usage detected"` |  |
| alertRules[1].expression | string | `"avg_over_time(memory_usage[5m]) > 90"` |  |
| alertRules[1].for | string | `"10m"` |  |
| alertRules[1].labels.environment | string | `"stage"` |  |
| alertRules[1].summary | string | `"Memory usage is above 90% for the last 10 minutes"` |  |
| global.alertLabels.environment | string | `"prod"` |  |
| global.alertLabels.severity | string | `"critical"` |  |
| global.metadata.partOf | string | `"my-project"` |  |
