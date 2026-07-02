{{/*
Build Traefik middleware references for ingress annotation.
Usage: {{ include "traefik.middlewareRefs" (dict "refs" .ingress.traefikMiddlewareRefs "componentName" $componentName "Release" $.Release) }}
Returns comma-separated middleware references in format: <namespace>-<name>@kubernetescrd

For kubernetescrd provider, the format must be: <kubernetes-namespace>-<middleware-name>@kubernetescrd
See: https://doc.traefik.io/traefik/providers/kubernetes-crd/#primitives
*/}}
{{- define "traefik.middlewareRefs" -}}
{{- $middlewareRefs := list -}}
{{- $namespace := $.Release.Namespace -}}
{{- range $ref := .refs -}}
{{- if hasPrefix "@" $ref -}}
{{- /* External reference starting with @ (e.g., @file) - use as-is */ -}}
{{- $middlewareRefs = append $middlewareRefs $ref -}}
{{- else if contains "@" $ref -}}
{{- /* Already has namespace/provider - use as-is */ -}}
{{- $middlewareRefs = append $middlewareRefs $ref -}}
{{- else -}}
{{- /* Reference to component middleware: <namespace>-<name>@kubernetescrd */ -}}
{{- $middlewareRefs = append $middlewareRefs (printf "%s-%s@kubernetescrd" $namespace $ref) -}}
{{- end -}}
{{- end -}}
{{- join "," $middlewareRefs -}}
{{- end -}}
