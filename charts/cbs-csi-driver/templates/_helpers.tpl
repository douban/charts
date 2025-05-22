{{/*
Expand the name of the chart.
*/}}
{{- define "cbs-csi-driver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cbs-csi-driver.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cbs-csi-driver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "cbs-csi-driver.labels" -}}
helm.sh/chart: {{ include "cbs-csi-driver.chart" . }}
{{ include "cbs-csi-driver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "cbs-csi-driver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cbs-csi-driver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the secret to use
*/}}
{{- define "cbs-csi-driver.secretName" -}}
{{- if .Values.secret.existingSecret -}}
    {{- .Values.secret.existingSecret -}}
{{- else -}}
    {{- include "cbs-csi-driver.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "cbs-csi-controller.serviceAccountName" -}}
{{- default "cbs-csi-controller-sa" .Values.serviceAccount.controller.nameOverride }}
{{- end }}

{{/*
Create the name of the controller cluster role to use
*/}}
{{- define "cbs-csi-controller.clusterRoleName" -}}
{{- default "cbs-csi-controller-role" .Values.serviceAccount.controller.nameOverride }}
{{- end }}

{{/*
Create the name of the controller cluster role binding to use
*/}}
{{- define "cbs-csi-controller.clusterRoleBindingName" -}}
{{- default "cbs-csi-controller-binding" .Values.clusterRoleBinding.controller.nameOverride }}
{{- end }}

{{/*
Create the name of the node service account to use
*/}}
{{- define "cbs-csi-node.serviceAccountName" -}}
{{- default "cbs-csi-node-sa" .Values.serviceAccount.node.nameOverride }}
{{- end }}

{{/*
Create the name of the node cluster role to use
*/}}
{{- define "cbs-csi-node.clusterRoleName" -}}
{{- default "cbs-csi-node-role" .Values.serviceAccount.node.nameOverride }}
{{- end }}

{{/*
Create the name of the node cluster role binding to use
*/}}
{{- define "cbs-csi-node.clusterRoleBindingName" -}}
{{- default "cbs-csi-node-binding" .Values.clusterRoleBinding.node.nameOverride }}
{{- end }}
