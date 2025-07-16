{{- define "cookielab.prometheus.alert_rules" -}}
{{- $application := .application -}}
{{- $component := .component -}}
{{- $namespace := .namespace -}}
{{- $alertLabels := .alertLabels -}}
{{ range $alertName, $alert := .alertRules -}}
- alert: {{ $alertName | title | replace " " "" | quote }}
  expr: {{ $alert.expression | quote }}
  for: {{ $alert.for | default "1m" | quote }}
  annotations:
    summary: {{ $alert.summary | default (printf "%s | %s-%s | %s\n\n{{$value}}" $namespace $application $component ($alertName | title | replace " " "")) | quote }}
    description: {{ $alert.description | default "No description" | quote }}
  labels:
{{ merge (dict "k8s_app_name" $application "k8s_app_component" $component "k8s_namespace_name" $namespace "severity" ($alert.severity | default "critical")) ($alert.labels) $alertLabels | toYaml | indent 4 }}
{{ end -}}
{{ end -}}
