{{- define "cookielab.prometheus.alert_rules" -}}
{{- $application := .application -}}
{{- $component := .component -}}
{{- $alertLabels := .alertLabels -}}
{{ range $alertName, $alert := .alertRules -}}
- alert: "{{ $application }}-{{ $component }}:{{ $alertName }}"
  expr: {{ $alert.expression | quote }}
  for: {{ $alert.for | default "1m" | quote }}
  annotations:
    summary: {{ $alert.summary | default (printf "{{$labels.k8s_app_name}}-{{$labels.k8s_app_component}}: %s failed ({{$labels.severity}})" $alertName $alert.severity) | quote }}
    description: {{ $alert.description | default "No description" | quote }}
  labels:
    k8s_app_name: {{ $application | quote }}
    k8s_app_component: {{ $component | quote }}
    severity: {{ $alert.severity | default "critical" | quote }}
{{ if $alertLabels -}}
{{ $alertLabels | toYaml | indent 4 }}
{{ end -}}
{{ if $alert.labels -}}
{{ $alert.labels | toYaml | indent 4 }}
{{ end -}}
{{ end -}}
{{ end -}}
