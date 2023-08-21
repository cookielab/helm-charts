{{- define "cookielab.kubernetes.pod.topology-spread" -}}
topologySpreadConstraints:
- maxSkew: {{ .maxSkew | default 1 }}
  topologyKey: topology.kubernetes.io/zone
  whenUnsatisfiable: DoNotSchedule
  labelSelector:
    matchLabels:
      {{- if .component -}}
      app.kubernetes.io/component: {{ .component | quote }}
      {{- end -}}
      {{- if .instance -}}
      app.kubernetes.io/instance: {{ .instance | quote }}
      {{- end -}}
      {{- if .name -}}
      app.kubernetes.io/name: {{ .name | quote }}
      {{- end -}}
      {{- if .partOf -}}
      app.kubernetes.io/part-of: {{ .version | quote }}
      {{- end -}}
{{- end -}}