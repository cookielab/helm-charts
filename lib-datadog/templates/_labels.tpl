{{- define "cookielab.datadog.labels" -}}
tags.datadoghq.com/env: {{ .env | quote }}
tags.datadoghq.com/service: {{ .service | quote }}
tags.datadoghq.com/version: {{ .version | replace "/" "-" | quote }}
{{- end -}}