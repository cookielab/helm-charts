{{- define "cookielab.prometheus.alert_rules" -}}
{{- $application := .application -}}
{{- $component := .component -}}
{{- $alertLabels := .alertLabels -}}
{{ range $alertName, $alert := .alertRules -}}
- alert: "{{ $application }}:{{ $component }}:{{ $alertName }}"
  expr: {{ $alert.expression | quote }}
  for: {{ $alert.for | default "1m" | quote }}
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
{{ if (or $alert.message $alert.description) -}}
  annotations:
{{ if $alert.message -}}
    message: {{ $alert.message | quote }}
{{ end -}}
{{ if $alert.description -}}
    description: {{ $alert.description | quote }}
{{ end -}}
{{ end -}}
{{ end -}}
{{ end -}}
