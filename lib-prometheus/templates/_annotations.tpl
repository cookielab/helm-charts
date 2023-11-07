{{- define "cookielab.prometheus.annotations" -}}
prometheus.io/scrape: {{ .scrape | default 'true' | quote }}
prometheus.io/path: {{ .path | quote }}
prometheus.io/port: {{ .port | quote }}
{{- end -}}