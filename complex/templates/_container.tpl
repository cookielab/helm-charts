{{- define "container" -}}
name: {{ .name }}
image: {{ dig "specific" "image" "repository" .global.image.repository . }}:{{ dig "specific" "image" "tag" .global.image.tag . }}
imagePullPolicy: {{ dig "specific" "image" "pullPolicy" .global.image.pullPolicy . }}
{{- if .specific.command }}
command:
{{ toYaml .specific.command | indent 2 }}
{{- end }}
{{- if .specific.args }}
args:
{{ toYaml .specific.args | indent 2 }}
{{- end }}
{{- if .specific.ports }}
ports:
{{- range $port := .specific.ports }}
  - containerPort: {{ $port.port }}
{{- if $port.name }}
    name: {{ $port.name }}
{{- end }}
{{- end }}
{{- end }}
{{- if .specific.securityContext }}
securityContext:
{{ toYaml .specific.securityContext | indent 2 }}
{{- end }}
{{ include "cookielab.kubernetes.container.envs.values" (dict "specific" (dig "specific" "envs" (dict) .) "globalValues" .global.envs.values "globalValuesFrom" .global.envs.valuesFrom) }}
{{ include "cookielab.kubernetes.container.envs.from" (dict "specific" (dig "specific" "envs" "from" (dict) .) "global" .global.envs.from) }}
{{- if or .specific.volumeMounts .global.volumeMounts }}
volumeMounts:
{{- if .global.volumeMounts.configMaps }}
{{- range .global.volumeMounts.configMaps }}
  - name: {{ .name }}
    mountPath: {{ .mountPath }}
    readOnly: {{ .readOnly | default true }}
    {{- if .subPath }}
    subPath: {{ .subPath }}
    {{- end }}
{{- end }}
{{- end }}
{{- if .global.volumeMounts.secrets }}
{{- range .global.volumeMounts.secrets }}
  - name: {{ .name }}
    mountPath: {{ .mountPath }}
    readOnly: {{ .readOnly | default true }}
    {{- if .subPath }}
    subPath: {{ .subPath }}
    {{- end }}
{{- end }}
{{- end }}
{{- if .specific.volumeMounts }}
{{- if .specific.volumeMounts.configMaps }}
{{- range .specific.volumeMounts.configMaps }}
  - name: {{ .name }}
    mountPath: {{ .mountPath }}
    readOnly: {{ .readOnly | default true }}
    {{- if .subPath }}
    subPath: {{ .subPath }}
    {{- end }}
{{- end }}
{{- end }}
{{- if .specific.volumeMounts.secrets }}
{{- range .specific.volumeMounts.secrets }}
  - name: {{ .name }}
    mountPath: {{ .mountPath }}
    readOnly: {{ .readOnly | default true }}
    {{- if .subPath }}
    subPath: {{ .subPath }}
    {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{ include "cookielab.kubernetes.container.resources" (dict "specific" (dig "specific" "resources" (dict) .) "global" .global.resources) }}
{{ include "cookielab.kubernetes.container.probes" (dict "specific" (dig "specific" "probes" (dict) .) "global" (dict "livenessProbe" (dict) "readinessProbe" (dict) "startupProbe" (dict))) }}
{{- end -}}
