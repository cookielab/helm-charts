{{- define "pod.spec" -}}
restartPolicy: {{ default "Always" .restartPolicy }}
terminationGracePeriodSeconds: {{ default 120 .terminationGracePeriodSeconds }}
{{- with .imagePullSecrets | default .global.imagePullSecrets -}}
{{- if . }}
imagePullSecrets:
{{- range . }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}
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
{{- if .tolerations }}
tolerations:
  {{- range .tolerations }}
  - key: "{{ .key }}"
    operator: "{{ .operator }}"
    value: "{{ .value }}"
    effect: "{{ .effect }}"
  {{- end }}
{{- end }}
{{- if or .serviceAccountName $.global.serviceAccountName }}
serviceAccountName: {{ default $.global.serviceAccountName .serviceAccountName }}
{{- end }}
# securityContext:
#   runAsNonRoot: true
{{ include "cookielab.kubernetes.pod.topology-spread" (dict "kubeLabels" .kubeLabels "metadata" .metadata) }}
{{- if .nodeSelector }}
nodeSelector:
{{ toYaml .nodeSelector | indent 2 }}
{{- end }}
enableServiceLinks: {{ default "False" .enableServiceLinks }}
{{- end -}}
