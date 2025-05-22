{{/*
Expand the name of the chart.
*/}}
{{- define "clb-controller-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "clb-controller-manager.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "clb-controller-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels with custom labels support
*/}}
{{- define "clb-controller-manager.labels" -}}
helm.sh/chart: {{ include "clb-controller-manager.chart" . }}
{{ include "clb-controller-manager.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "clb-controller-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clb-controller-manager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the secret to use
*/}}
{{- define "clb-controller-manager.secretName" -}}
{{- if .Values.secret.existingSecret -}}
    {{- .Values.secret.existingSecret -}}
{{- else -}}
    {{- .Values.secret.existingSecret -}}
    {{- include "clb-controller-manager.fullname" . -}}
{{- end -}}
{{- end }}

{{- define "clb-controller-manager.cloudConfig" -}}
{
  "region": {{ .Values.secret.region | quote }},
  "vpc_id": {{ .Values.secret.vpc_id | quote }},
  "secret_id": {{ .Values.secret.secret_id | quote }},
  "secret_key": {{ .Values.secret.secret_key | quote }}
}
{{- end -}}

{{/*
Environment variables for CLB configuration
*/}}
{{- define "clb-controller-manager.envVars" -}}
- name: CLB_PREFIX
  value: {{ .Values.env.clbPrefix | quote }}
- name: CLB_TAG
  value: {{ .Values.env.clbTag | quote }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "clb-controller-manager.serviceAccountName" -}}
{{- default "cloud-controller-manager" .Values.serviceAccount.name }}
{{- end }}

{{/*
Create the name of the cluster role to use
*/}}
{{- define "clb-controller-manager.clusterRoleName" -}}
{{- default "system:cloud-controller-manager" .Values.clusterRole.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the cluster role binding to use
*/}}
{{- define "clb-controller-manager.clusterRoleBindingName" -}}
{{- default "system:cloud-controller-manager" .Values.clusterRoleBinding.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}