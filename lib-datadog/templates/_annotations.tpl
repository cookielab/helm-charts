{{- define "cookielab.datadog.annotations" -}}
{{- $vals := . }}
ad.datadoghq.com/tags: '{ "service":"{{ .service }}", "env":"{{ .env }}", "version":"{{ .version }}", "application":"{{- if .application -}}{{ .application }}{{- else -}}{{ .service }}{{- end -}}"{{- if .type -}}, "type": "{{ .type }}"{{- end -}}{{- if .stack -}}, "stack": "{{ .stack }}"{{- end -}} }'
{{ range .containers -}}
ad.datadoghq.com/{{ . }}.logs: '[{"source":"{{ $vals.source }}", "service":"{{ $vals.service }}", "auto_multi_line_detection": true}]'
{{- end }}
{{- end -}}