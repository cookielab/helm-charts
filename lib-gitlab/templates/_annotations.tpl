{{- define "cookielab.gitlab.annotations" -}}
app.gitlab.com/app: {{ .app | quote }}
app.gitlab.com/env: {{ .env | quote }}
{{- end -}}
