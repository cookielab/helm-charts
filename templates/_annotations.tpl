{{- define "cookielab.kubernetes.annotations" -}}
{{- if .defaultContainer }}
kubectl.kubernetes.io/default-container: {{ .defaultContainer | quote }}
{{- end }}
{{- end -}}
