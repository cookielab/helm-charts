{{- define "cookielab.prometheus.annotations" -}}
{{- if .scrape }}
prometheus.io/scrape: {{ .scrape | quote }}
prometheus.io/path: {{ .path | quote }}
prometheus.io/port: {{ .port | quote }}
{{- end }}
{{- end -}}
