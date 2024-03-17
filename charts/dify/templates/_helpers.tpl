{{/*
Expand the name of the chart.
*/}}
{{- define "dify.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dify.fullname" -}}
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
{{- define "dify.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dify.labels" -}}
helm.sh/chart: {{ include "dify.chart" . }}
{{ include "dify.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dify.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dify.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dify.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dify.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
dify dependency settings
*/}}
{{- define "dify.commonEnvs" -}}
- name: setup__dify_url
  value: "{{ .Values.dify_scheme }}://{{ .Values.dify_host }}"
{{- if .Values.redis.embedded }}
- name: services__redis_url
  value: redis://:{{ .Values.redis.auth.password }}@{{ include "dify.fullname" . }}-redis-master:6379/0
{{- end }}
{{- if .Values.postgresql.embedded }}
- name: services__database_url
  value: postgres://postgres:{{ .Values.postgresql.auth.postgresPassword }}@{{ include "dify.fullname" . }}-postgresql:5432/{{  .Values.postgresql.auth.database }}
{{- end }}
{{- if .Values.timescaledb.enabled }}
- name: services__timeseries_database_url
  value: postgres://postgres:{{ .Values.timescaledb.secrets.credentials.PATRONI_SUPERUSER_PASSWORD }}@{{ .Values.timescaledb.fullnameOverride }}:5432/postgres?sslmode=require
{{- end }}
{{- if .Values.minio.embedded }}
- name: services__minio__host
  value: {{ include "dify.fullname" . }}-minio
- name: services__minio__port
  value: {{ .Values.minio.service.ports.api | quote }}
- name: services__minio__access_key_id
  value: {{ .Values.minio.auth.rootUser }}
- name: services__minio__secret_access_key
  value: {{ .Values.minio.auth.rootPassword }}
{{- else }}
- name: services__minio__host
  value: {{ .Values.minio.externalHost | quote }}
- name: services__minio__port
  value: {{ .Values.minio.externalPort | quote }}
{{- end }}
{{- end }}
