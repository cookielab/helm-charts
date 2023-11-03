{{- define "pod.spec" -}}
restartPolicy: {{ default "Always" .restartPolicy }}
terminationGracePeriodSeconds: {{ default 120 .terminationGracePeriodSeconds }}
{{- if .initContainers }}
initContainers:
  {{- range $containerName, $container := .initContainers }}
  - {{ include "container" (dict "specific" $container "name" $containerName "global" $.global.container ) | indent 4 | trim }}
  {{- end }}
{{- end }}
containers:
  {{- range $containerName, $container := .containers }}
  - {{ include "container" (dict "specific" $container "name" $containerName "global" $.global.container ) | indent 4 | trim }}
    {{ include "cookielab.kubernetes.container.lifecycle" . | indent 4 | trim }}
  {{- end }}
{{- if .serviceAccountName }}
serviceAccountName: {{ .serviceAccountName }}
{{- end }}
# securityContext:
#   runAsNonRoot: true
{{ include "cookielab.kubernetes.pod.topology-spread" (dict "metadata" .metadata) }}
{{- if .nodeSelector }}
nodeSelector:
{{ toYaml .nodeSelector | indent 2 }}
{{- end }}
{{- end -}}
