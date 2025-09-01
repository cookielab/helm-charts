{{- define "cookielab.kubernetes.pod.topology-spread" -}}
{{- if .metadata -}}
topologySpreadConstraints:
- maxSkew: {{ .metadata.maxSkew | default 1 }}
  topologyKey: {{ .metadata.topologyKey | default "topology.kubernetes.io/zone" }}
  whenUnsatisfiable: {{ .metadata.whenUnsatisfiable | default "DoNotSchedule" }}
  labelSelector:
    matchLabels:
      {{ include "cookielab.kubernetes.labels.selector" .kubeLabels | indent 6 | trim }}
{{- end -}}
{{- end -}}
