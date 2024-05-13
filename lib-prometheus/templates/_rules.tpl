{{- define "cookielab.prometheus.alert_rules" -}}
{{- $application := .application -}}
{{- $component := .component -}}
{{- $alertLabels := .alertLabels -}}
{{ range $alertName, $alert := .alertRules -}}
- alert: {{ $alertName | title | replace " " "" | quote }}
  expr: {{ $alert.expression | quote }}
  for: {{ $alert.for | default "1m" | quote }}
  annotations:
    summary: {{ $alert.summary | default (printf "{{$labels.k8s_app_name}}-{{$labels.k8s_app_component}}: %s {{$labels.severity}}\n\nValue: {{$value}}" ($alertName | title | replace " " "")) | quote }}
    description: {{ $alert.description | default "No description" | quote }}
  labels:
    k8s_app_component: {{ $component | quote }}
    k8s_app_name: {{ $application | quote }}
    severity: {{ $alert.severity | default "critical" | quote }}
{{ if $alertLabels -}}
{{ $alertLabels | toYaml | indent 4 }}
{{ end -}}
{{ if $alert.labels -}}
{{ $alert.labels | toYaml | indent 4 }}
{{ end -}}
{{ end -}}
{{ end -}}
