{{/*
Expand the name of the chart.
*/}}
{{- define "service-prober.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "service-prober.fullname" -}}
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
{{- define "service-prober.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "service-prober.labels" -}}
helm.sh/chart: {{ include "service-prober.chart" . }}
{{ include "service-prober.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "service-prober.selectorLabels" -}}
app.kubernetes.io/name: {{ include "service-prober.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "service-prober.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "service-prober.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
实际使用的 blackbox exporter url
*/}}
{{- define "service-prober.blackBoxUrl" -}}
{{- if .Values.existingBlackboxUrl }}
{{- .Values.existingBlackboxUrl -}}
{{- else -}}
{{- $bbEnabled := index .Values "prometheus-blackbox-exporter" "enabled" -}}
{{- $bbContext := index .Subcharts "prometheus-blackbox-exporter" }}
{{- if $bbEnabled -}}
{{- printf "%s.%s:9115" (include "prometheus-blackbox-exporter.fullname" $bbContext) .Release.Namespace -}}
{{- else -}}
{{- fail "service-prober.blackBoxUrl: existingBlackboxUrl is empty and prometheus-blackbox-exporter.enabled=false" -}}
{{- end -}}
{{- end }}
{{- end }}