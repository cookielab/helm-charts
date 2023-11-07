{{- define "cookielab.prometheus.annotations" -}}
{{- if .prometheus }}
prometheus.io/scrape: 'true'
prometheus.io/path: {{ .path | quote }}
prometheus.io/port: {{ .port | quote }}
{{- end }}
{{- end -}}
