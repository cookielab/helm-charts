{{- define "cookielab.prometheus.annotations" -}}
{{- if .path }}
prometheus.io/scrape: 'true'
prometheus.io/path: {{ .path | quote }}
prometheus.io/port: {{ .port | quote }}
{{- end }}
{{- end -}}
