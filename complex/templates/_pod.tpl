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
{{- $mergedNodeSelector := merge (default dict .nodeSelector) (default dict .global.nodeSelector) }}
{{- if $mergedNodeSelector }}
nodeSelector:
{{ toYaml $mergedNodeSelector | indent 2 }}
{{- end }}
enableServiceLinks: {{ default "False" .enableServiceLinks }}
{{- $globalVolumeMounts := .global.container.volumeMounts }}
{{- $localVolumeMounts := .volumeMounts }}
{{- $configMaps := $globalVolumeMounts.configMaps }}
{{- $secrets := $globalVolumeMounts.secrets }}
{{- if $localVolumeMounts }}
{{- $vmKeys := keys $localVolumeMounts }}
{{- if eq (len $vmKeys) 0 }}
{{- $configMaps = (list) }}
{{- $secrets = (list) }}
{{- else }}
{{- if hasKey $localVolumeMounts "configMaps" }}
{{- $configMaps = $localVolumeMounts.configMaps }}
{{- end }}
{{- if hasKey $localVolumeMounts "secrets" }}
{{- $secrets = $localVolumeMounts.secrets }}
{{- end }}
{{- end }}
{{- end }}
{{- if or $configMaps $secrets .volumes }}
volumes:
{{- with $configMaps }}
{{- range . }}
  - name: {{ .name }}
    configMap:
      name: {{ .configMapName }}
{{- end }}
{{- end }}
{{- with $secrets }}
{{- range . }}
  - name: {{ .name }}
    secret:
      secretName: {{ .secretName }}
{{- end }}
{{- end }}
{{- if .volumes }}
{{ toYaml .volumes | indent 2 }}
{{- end }}
{{- end }}
{{- end -}}
