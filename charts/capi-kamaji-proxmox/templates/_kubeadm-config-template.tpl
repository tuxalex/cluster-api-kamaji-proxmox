{{- define "kubeadmConfigTemplateSpec" -}}
joinConfiguration:
  nodeRegistration:
    name: {{`'{{ local_hostname }}'`}}
    criSocket: /var/run/containerd/containerd.sock
    kubeletExtraArgs:
      - name: provider-id
        value: proxmox://{{`'{{ ds.meta_data.instance_id }}'`}}
      {{- if and .nodePool (hasKey .nodePool "labels") }}
      - name: node-labels
       value: {{ .nodePool.labels }}
      {{- end }}
      {{- if and .nodePool (hasKey .nodePool "taints") }}
      - name: register-with-taints
        value: {{ .nodePool.taints}}
      {{- end }}
{{- if .nodePool.additionalCloudInitFiles }}
files:
- path: "/etc/cloud/cloud.cfg.d/99-custom.cfg"
  content: {{ .nodePool.additionalCloudInitFiles | quote }}
  owner: "root:root"
  permissions: "0644"
{{- end }}
{{- if .nodePool.users }}
users:
{{- range .nodePool.users }}
  - {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}
{{- range .nodePool.preKubeadmCommands }}
  - {{- toYaml . | nindent 4 }}
{{- end }}
{{- range .nodePool.postKubeadmCommands }}
  - {{- toYaml . | nindent 4 }}
{{- end }}
{{- if .nodePool.cloudInitFormat }}
format: {{ .nodePool.cloudInitFormat | default "cloud-config" }}
{{- end }}
{{- if eq .nodePool.cloudInitFormat "ignition" }}
ignition:
  containerLinuxConfig:
    additionalConfig: |-
      {{ .nodePool.ignitionConfig | quote | nindent 6 |}}
{{- end }}

{{/*
Calculates a SHA256 hash of the kubeadmConfigTemplate content.
*/}}

{{- define "kubeadmConfigTemplateHash" -}}
{{- $templateContent := include "kubeadmConfigTemplateSpec" . -}}
{{- $templateContent | sha256sum | trunc 8 -}}
{{- end -}}