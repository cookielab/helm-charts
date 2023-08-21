{{- define "cookielab.kubernetes.labels" -}}
{{- if .component -}}
app.kubernetes.io/component: {{ .component | quote }}
{{- end -}}
{{- if .instance -}}
app.kubernetes.io/instance: {{ .instance | quote }}
{{- end -}}
{{- if .name -}}
app.kubernetes.io/name: {{ .name | quote }}
{{- end -}}
{{- if .partOf -}}
app.kubernetes.io/part-of: {{ .version | quote }}
{{- end -}}
{{- if .version -}}
app.kubernetes.io/version: {{ .version | quote }}
{{- end -}}
{{- end -}}