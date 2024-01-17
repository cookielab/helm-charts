{{- define "container" -}}
name: {{ .name }}
image: {{ dig "specific" "image" "repository" .global.image.repository . }}:{{ dig "specific" "image" "tag" .global.image.tag . }}
imagePullPolicy: {{ dig "specific" "image" "pullPolicy" .global.image.pullPolicy . }}
{{- if .specific.command }}
command:
{{ toYaml .specific.command | indent 2 }}
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
{{ include "cookielab.kubernetes.container.envs.values" (dict "specific" (dig "specific" "envs" "values" (dict) .) "global" .global.envs.values) }}
{{ include "cookielab.kubernetes.container.envs.from" (dict "specific" (dig "specific" "envs" "from" (dict) .) "global" .global.envs.from) }}
{{ include "cookielab.kubernetes.container.resources" (dict "specific" (dig "specific" "resources" (dict) .) "global" .global.resources) }}
{{ include "cookielab.kubernetes.container.probes" (dict "specific" (dig "specific" "probes" (dict) .) "global" (dict "livenessProbe" (dict) "readinessProbe" (dict) "startupProbe" (dict))) }}
{{- end -}}
