{{- define "cookielab.prometheus.rules" -}}
{{ range $alertName, $alert := .alertRules -}}
- alert: {{ .application }}:{{ .component }}:{{ $alertName }}
  expr: {{ $alert.expression | quote }}
  for: {{ $alert.for | default "1m" | quote }}
  labels:
    severity: {{ $alert.severity | default "critical" | quote }}
{{ .alertLabels | toYaml | indent 4 }}
{{ $alert.labels | toYaml | indent 4 }}
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
