{{/*
Expand the name of the chart.
*/}}
{{- define "codecov.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "codecov.fullname" -}}
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
{{- define "codecov.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "codecov.labels" -}}
helm.sh/chart: {{ include "codecov.chart" . }}
{{ include "codecov.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "codecov.selectorLabels" -}}
app.kubernetes.io/name: {{ include "codecov.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "codecov.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "codecov.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
codecov dependency settings
*/}}
{{- define "codecov.commonEnvs" -}}
- name: setup__codecov_url
  value: "{{ .Values.codecov_scheme }}://{{ .Values.codecov_host }}"
{{- if .Values.redis.embedded }}
- name: services__redis_url
  value: redis://:{{ .Values.redis.auth.password }}@{{ include "codecov.fullname" . }}-redis-master:6379/0
{{- end }}
{{- if .Values.postgresql.embedded }}
- name: services__database_url
  value: postgres://postgres:{{ .Values.postgresql.auth.postgresPassword }}@{{ include "codecov.fullname" . }}-postgresql:5432/{{  .Values.postgresql.auth.database }}
{{- end }}
{{- if .Values.timescaledb.enabled }}
- name: services__timeseries_database_url
  value: postgres://postgres:{{ .Values.timescaledb.secrets.credentials.PATRONI_SUPERUSER_PASSWORD }}@{{ .Values.timescaledb.fullnameOverride }}:5432/postgres?sslmode=require
{{- end }}
{{- if .Values.minio.embedded }}
- name: services__minio__host
  value: {{ include "codecov.fullname" . }}-minio
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
