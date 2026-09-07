{{/*
Build Traefik middleware references for the ingress annotation.
Usage: {{ include "traefik.middlewareRefs" (dict "refs" .ingress.traefikMiddlewareRefs "componentName" $componentName "componentMiddlewares" $component.traefikMiddlewares "globalMiddlewares" $.Values.global.traefikMiddlewares "Release" $.Release) }}
Returns comma-separated references in the kubernetescrd provider format
<kubernetes-namespace>-<Middleware resource name>@kubernetescrd, see
https://doc.traefik.io/traefik/providers/kubernetes-crd/#primitives

The resource names must match what traefikMiddleware.yaml renders:
  global middleware     -> <release>-<name>
  component middleware  -> <release>-<component>-<name>
Reference formats:
  global:<name>   global middleware defined in global.traefikMiddlewares
  <name>          component middleware defined in this component's traefikMiddlewares,
                  else a global one of that name, else an existing Middleware resource
                  called <name> in the release namespace
  <name>@<provider> passed through unchanged (auth@file, other@kubernetescrd)
*/}}
{{- define "traefik.middlewareRefs" -}}
{{- $middlewareRefs := list -}}
{{- $namespace := .Release.Namespace -}}
{{- $release := .Release.Name -}}
{{- $componentNames := list -}}
{{- range $middleware := (.componentMiddlewares | default list) -}}
{{- $componentNames = append $componentNames $middleware.name -}}
{{- end -}}
{{- $globalNames := list -}}
{{- range $middleware := (.globalMiddlewares | default list) -}}
{{- $globalNames = append $globalNames $middleware.name -}}
{{- end -}}
{{- range $ref := .refs -}}
{{- if contains "@" $ref -}}
{{- /* Provider-qualified (auth@file, name@kubernetescrd) or external reference: use as-is */ -}}
{{- $middlewareRefs = append $middlewareRefs $ref -}}
{{- else if hasPrefix "global:" $ref -}}
{{- $middlewareRefs = append $middlewareRefs (printf "%s-%s-%s@kubernetescrd" $namespace $release (trimPrefix "global:" $ref)) -}}
{{- else if has $ref $componentNames -}}
{{- $middlewareRefs = append $middlewareRefs (printf "%s-%s-%s-%s@kubernetescrd" $namespace $release $.componentName $ref) -}}
{{- else if has $ref $globalNames -}}
{{- $middlewareRefs = append $middlewareRefs (printf "%s-%s-%s@kubernetescrd" $namespace $release $ref) -}}
{{- else -}}
{{- /* Not rendered by this chart: treat as the name of an existing Middleware in the namespace */ -}}
{{- $middlewareRefs = append $middlewareRefs (printf "%s-%s@kubernetescrd" $namespace $ref) -}}
{{- end -}}
{{- end -}}
{{- join "," $middlewareRefs -}}
{{- end -}}
