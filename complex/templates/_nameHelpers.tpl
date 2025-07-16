{{- define "component.name" -}}
{{ .Release.Name }}-{{ .name }}
{{- end -}}
