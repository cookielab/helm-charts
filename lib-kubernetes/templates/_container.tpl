{{- define "cookielab.kubernetes.container.resources" -}}
resources:
  limits:
    cpu: {{ dig "container" "resources" "limits" "cpu" .Values.global.container.resources.limits.cpu . }}
    memory: {{ dig "container" "resources" "limits" "memory" .Values.global.container.resources.limits.memory . }}
    ephemeral-storage: {{ dig "container" "resources" "limits" "ephemeral-storage" .Values.global.container.resources.limits.ephemeralStorage . }}
  requests:
    cpu: {{ dig "container" "resources" "requests" "cpu" .Values.global.container.resources.requests.cpu . }}
    memory: {{ dig "container" "resources" "requests" "memory" .Values.global.container.resources.requests.memory . }}
    ephemeral-storage: {{ dig "container" "resources" "requests" "ephemeral-storage" .Values.global.container.resources.requests.ephemeralStorage . }}
{{- end -}}

{{- define "cookielab.kubernetes.container.probes" -}}
{{- $livenessProbe := dig "container" "livenessProbe" .Values.global.container.livenessProbe . -}}
{{- $readinessProbe := dig "container" "readinessProbe" .Values.global.container.readinessProbe . -}}
{{- $startupProbe := dig "container" "startupProbe" .Values.global.container.startupProbe . -}}
{{- if $livenessProbe }}
livenessProbe:
{{ toYaml $livenessProbe | indent 2 }}
{{- end -}}
{{- if $readinessProbe }}
readinessProbe:
{{ toYaml $readinessProbe | indent 2 }}
{{- end -}}
{{- if $startupProbe }}
startupProbe:
{{ toYaml $startupProbe | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "cookielab.kubernetes.container.lifecycle" -}}
lifecycle:
  preStop:
    exec:
      command: ["/bin/sh", "-c", "sleep 40"]
{{- end -}}

{{- define "cookielab.kubernetes.container.envs.values" -}}
{{- $container := dig "container" "envs" "values" (dict) . -}}
{{- $global := .Values.global.container.envs.values -}}
{{- $values := merge $container $global -}}
env:
  {{- range $name, $value := $values }}
  - name: {{ $name }}
    value: {{ $value | quote }}
  {{- end -}}
{{- end -}}

{{- define "cookielab.kubernetes.container.envs.from" -}}
{{- $containerSecrets := dig "container" "envs" "secrets" (list) . -}}
{{- $globalSecrets := .Values.global.container.envs.secrets -}}
{{- $containerConfigMaps := dig "container" "envs" "configMaps" (list) . -}}
{{- $globalConfigMaps := .Values.global.container.envs.configMaps -}}
{{- $valuesSecrets := concat $containerSecrets $globalSecrets -}}
{{- $valuesConfigMaps := concat $containerConfigMaps $globalConfigMaps -}}
{{- if or $valuesSecrets $valuesConfigMaps -}}
envFrom:
  {{- range $valuesSecrets }}
  - secretRef:
      name: {{ . }}
  {{- end -}}
  {{- range $valuesConfigMaps }}
  - configMapRef:
      name: {{ . }}
  {{- end -}}
{{- end -}}
{{- end -}}
