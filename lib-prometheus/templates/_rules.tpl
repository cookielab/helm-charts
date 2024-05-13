{{- define "cookielab.prometheus.alert_rules" -}}
{{- $application := .application -}}
{{- $component := .component -}}
{{- $alertLabels := .alertLabels -}}
{{ range $alertName, $alert := .alertRules -}}
- alert: "{{ $application }}-{{ $component }}:{{ $alertName }}"
  expr: {{ $alert.expression | quote }}
  for: {{ $alert.for | default "1m" | quote }}
  annotations:
    summary: {{ $alert.summary | default (printf "%s: %s (application: %s, component: %s)" $alertName $alert.severity $application $component) | quote }}
    description: {{ $alert.description | default "No description" | quote }}
  labels:
    app_name: {{ $application | quote }}
    app_component: {{ $component | quote }}
    severity: {{ $alert.severity | default "critical" | quote }}
{{ if $alertLabels -}}
{{ $alertLabels | toYaml | indent 4 }}
{{ end -}}
{{ if $alert.labels -}}
{{ $alert.labels | toYaml | indent 4 }}
{{ end -}}
{{ end -}}
{{ end -}}
