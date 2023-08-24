{{- define "cookielab.kubernetes.labels" -}}
{{- if .instance }}
app.kubernetes.io/instance: {{ .instance | quote }}
{{- end }}
{{- if .partOf }}
app.kubernetes.io/part-of: {{ .partOf | quote }}
{{- end }}
{{- if .version }}
app.kubernetes.io/version: {{ .version | quote }}
{{- end }}
{{- end -}}

{{- define "cookielab.kubernetes.labels.selector" -}}
{{- if .component }}
app.kubernetes.io/component: {{ .component | quote }}
{{- end }}
{{- if .name }}
app.kubernetes.io/name: {{ .name | quote }}
{{- end }}
{{- end -}}
