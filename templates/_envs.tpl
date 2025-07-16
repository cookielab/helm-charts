{{- define "cookielab.datadog.envs" -}}
- name: DD_ENV
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/env']
- name: DD_SERVICE
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/service']
- name: DD_VERSION
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/version']
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
- name: DD_ENTITY_ID
  valueFrom:
    fieldRef:
      fieldPath: metadata.uid
- name: DD_TRACE_HTTP_CLIENT_SPLIT_BY_DOMAIN
  value: '1'
- name: DD_TAGS
  value: "application:{{ .Release.Name }}"
{{- end -}}
