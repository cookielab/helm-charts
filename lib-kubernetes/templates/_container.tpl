{{- define "cookielab.kubernetes.container.resources" -}}
resources:
  limits:
    cpu: {{ dig "specific" "limits" "cpu" .global.limits.cpu . }}
    memory: {{ dig "specific" "limits" "memory" .global.limits.memory . }}
    ephemeral-storage: {{ dig "specific" "limits" "ephemeralStorage" .global.limits.ephemeralStorage . }}
  requests:
    cpu: {{ dig "specific" "requests" "cpu" .global.requests.cpu . }}
    memory: {{ dig "specific" "requests" "memory" .global.requests.memory . }}
    ephemeral-storage: {{ dig "specific" "requests" "ephemeralStorage" .global.requests.ephemeralStorage . }}
{{- end -}}

{{- define "cookielab.kubernetes.container.probes" -}}
{{- $livenessProbe := dig "specific" "livenessProbe" .global.livenessProbe . -}}
{{- $readinessProbe := dig "specific" "readinessProbe" .global.readinessProbe . -}}
{{- $startupProbe := dig "specific" "startupProbe" .global.startupProbe . -}}
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

{{- define "cookielab.kubernetes.container.envs" -}}
{{- $specific := dig "specific" (dict) . -}}
{{- $globalValues := .global.values -}}
{{- $globalValuesFrom := .global.valuesFrom -}}
{{- $values := merge $specific $globalValues -}}
{{- $valuesFrom := merge $specific $globalValuesFrom -}}
{{- if or $values $valuesFrom -}}
env:
  {{- range $name, $value := $values }}
  - name: {{ $name }}
    value: {{ $value | quote }}
  {{- end -}}
  {{- range $name, $value := $valuesFrom }}
  - name: {{ $name }}
    valueFrom:
      fieldRef:
        fieldPath: {{ $value | quote }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "cookielab.kubernetes.container.envs.from" -}}
{{- $specificSecrets := dig "specific" "secrets" (list) . -}}
{{- $globalSecrets := .global.secrets -}}
{{- $specificConfigMaps := dig "specific" "configMaps" (list) . -}}
{{- $globalConfigMaps := .global.configMaps -}}
{{- $valuesSecrets := concat $specificSecrets $globalSecrets -}}
{{- $valuesConfigMaps := concat $specificConfigMaps $globalConfigMaps -}}
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
