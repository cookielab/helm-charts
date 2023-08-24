{{- define "cookielab.kubernetes.pod.topology-spread" -}}
{{- if .metadata -}}
topologySpreadConstraints:
- maxSkew: {{ .maxSkew | default 1 }}
  topologyKey: topology.kubernetes.io/zone
  whenUnsatisfiable: DoNotSchedule
  labelSelector:
    matchLabels:
      {{ include "cookielab.kubernetes.labels.selector" .metadata | indent 6 | trim }}
{{- end -}}
{{- end -}}
