{{- define "ProxmoxClusterTemplateSpec" -}}
credentialsRef:
  name: {{ .Values.proxmox.secret.name }}
  namespace: {{ .Values.proxmox.secret.namespace | default $.Release.Namespace }}
externalManagedControlPlane: true
controlPlaneEndpoint:
  host: {{ .Values.cluster.controlPlane.network.serviceAddress }}
  port: {{ .Values.cluster.clusterNetwork.apiServerPort }}
dnsServers:
{{- range .Values.cluster.dnsServers }}
- {{ . }}
{{- end }}
allowedNodes:
{{- range .Values.cluster.allowedNodes }}
- {{ . }}
{{- end }}
{{- end -}}


{{/*
Calculates a SHA256 hash of the ProxmoxMachineTemplate content.
*/}}

{{- define "ProxmoxClusterTemplateHash" -}}
{{- $templateContent := include "ProxmoxClusterTemplateSpec" . -}}
{{- $templateContent | sha256sum | trunc 8 -}}
{{- end -}}
