{{- define "machineHealthCheckSpec" -}}
clusterName: {{ include "cluster-api-kamaji-proxmox.cluster-name" .Global }}
selector:
  matchLabels:
    cluster.x-k8s.io/cluster-name: {{ include "cluster-api-kamaji-proxmox.cluster-name" .Global }}
checks:
  nodeStartupTimeoutSeconds: {{ .nodePool.nodeStartupTimeout }}
  unhealthyNodeConditions:
    - type: Ready
      status: Unknown
      timeoutSeconds: {{ .nodePool.unhealthyNodeConditionsTimeout }}
    - type: Ready
      status: "False"
      timeoutSeconds: {{ .nodePool.unhealthyNodeConditionsTimeout }}
{{- end -}}


{{/*
Calculates a SHA256 hash of the machineHealthCheckSpe content.
*/}}

{{- define "machineHealthCheckHash" -}}
{{- $templateContent := include "machineHealthCheckSpec" . -}}
{{- $templateContent | sha256sum | trunc 8 -}}
{{- end -}}