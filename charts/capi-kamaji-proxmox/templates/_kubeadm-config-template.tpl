{{- define "kubeadmConfigTemplateSpec" -}}
joinConfiguration:
  nodeRegistration:
    criSocket: /var/run/containerd/containerd.sock
    kubeletExtraArgs:
      {{- if eq .nodePool.cloudInitFormat "ignition" }}
      - name: provider-id
        value: proxmox://{{`'${COREOS_CUSTOM_INSTANCE_ID}'`}}
      {{- else }}
      - name: provider-id
        value: proxmox://{{`'{{ ds.meta_data.instance_id }}'`}}
      {{- end }}
      {{- if and .nodePool (hasKey .nodePool "labels") }}
      - name: node-labels
       value: {{ .nodePool.labels }}
      {{- end }}
      {{- if and .nodePool (hasKey .nodePool "taints") }}
      - name: register-with-taints
        value: {{ .nodePool.taints }}
      {{- end }}
{{- if .nodePool.additionalCloudInitFiles }}
files:
- path: "/etc/cloud/cloud.cfg.d/99-custom.cfg"
  content: {{ .nodePool.additionalCloudInitFiles | quote }}
  owner: "root:root"
  permissions: "0644"
{{- end }}
{{- if .nodePool.preKubeadmCommands }}
preKubeadmCommands:
{{- range .nodePool.preKubeadmCommands }}
  - {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}
{{- if .nodePool.postKubeadmCommand }}
postKubeadmCommands:
{{- range .nodePool.postKubeadmCommands }}
  - {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}
{{- if .nodePool.users }}
users:
{{- range .nodePool.users }}
- name: {{ .name }}
  shell: {{ .shell }}
  lockPassword: {{ .lockPassword }}
  sshAuthorizedKeys: {{ .sshAuthorizedKeys }}
  sudo: {{ .sudo }}
{{- with .passwd }}
  passwd: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
format: {{ .nodePool.cloudInitFormat | default "cloud-config" }}
{{- if eq .nodePool.cloudInitFormat "ignition" }}
ignition:
  containerLinuxConfig:
    additionalConfig: |-
{{- if .nodePool.ignitionConfig -}}
      {{ .nodePool.ignitionConfig | nindent 6 |}}
{{- end }}   
{{- end }}
{{- end -}}

{{/*
Calculates a SHA256 hash of the kubeadmConfigTemplate content.
*/}}

{{- define "kubeadmConfigTemplateHash" -}}
{{- $templateContent := include "kubeadmConfigTemplateSpec" . -}}
{{- $templateContent | sha256sum | trunc 8 -}}
{{- end -}}