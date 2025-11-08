{{/* release name */}}
{{- define "cluster-api-kamaji-proxmox.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* cluster name */}}
{{- define "cluster-api-kamaji-proxmox.cluster-name" -}}
{{- default .Release.Name .Values.cluster.name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Calculates a SHA256 hash of the ProxmoxMachineTemplate content.
*/}}
{{- define "ProxmoxClusterTemplateHash" -}}
{{- $templateContent := include "ProxmoxClusterTemplateSpec" . -}}
{{- $templateContent | sha256sum | trunc 8 -}}
{{- end -}}

