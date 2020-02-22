{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "redash.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "redash.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 43 chars because some Kubernetes name fields are limited to 64 (by the DNS naming spec),
and we use this as a base for component names (which can add up to 20 chars).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "redash.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 43 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 43 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 43 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified adhocWorker name.
*/}}
{{- define "redash.adhocWorker.fullname" -}}
{{- template "redash.fullname" . -}}-adhocworker
{{- end -}}

{{/*
Create a default fully qualified scheduledworker name.
*/}}
{{- define "redash.scheduledWorker.fullname" -}}
{{- template "redash.fullname" . -}}-scheduledworker
{{- end -}}

{{/*
Create a default fully qualified postgresql name.
*/}}
{{- define "redash.postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified redis name.
*/}}
{{- define "redash.redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis-master" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the secret name.
*/}}
{{- define "redash.secretName" -}}
{{- if .Values.server.existingSecret }}
    {{- printf "%s" .Values.server.existingSecret -}}
{{- else -}}
    {{- printf "%s" (include "redash.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Shared environment block used across each component.
*/}}
{{- define "redash.env" -}}
{{- if not .Values.postgresql.enabled }}
- name: REDASH_DATABASE_URL
  value: {{ default "" .Values.externalPostgreSQL | quote }}
{{- else }}
- name: REDASH_DATABASE_USER
  value: "{{ .Values.postgresql.postgresqlUsername }}"
- name: REDASH_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-postgresql
      key: postgresql-password
- name: REDASH_DATABASE_HOSTNAME
  value: {{ include "redash.postgresql.fullname" . }}
- name: REDASH_DATABASE_PORT
  value: "{{ .Values.postgresql.service.port }}"
- name: REDASH_DATABASE_DB
  value: "{{ .Values.postgresql.postgresqlDatabase }}"
{{- end }}
{{- if not .Values.redis.enabled }}
- name: REDASH_REDIS_URL
  value: {{ default "" .Values.externalRedis | quote }}
{{- else }}
- name: REDASH_REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
    {{- if .Values.redis.existingSecret }}
      name: {{ .Values.redis.existingSecret }}
    {{- else }}
      name: {{ .Release.Name }}-redis
    {{- end }}
      key: redis-password
- name: REDASH_REDIS_HOSTNAME
  value: {{ include "redash.redis.fullname" . }}
- name: REDASH_REDIS_PORT
  value: "{{ .Values.redis.master.port }}"
- name: REDASH_REDIS_DB
  value: "{{ .Values.redis.databaseNumber }}"
{{- end }}
{{- range $key, $value := .Values.env }}
- name: "{{ $key }}"
  value: "{{ $value }}"
{{- end }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "redash.labels" -}}
helm.sh/chart: {{ include "redash.chart" . }}
{{ include "redash.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "redash.selectorLabels" -}}
app.kubernetes.io/name: {{ include "redash.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "redash.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "redash.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

# This ensures a random value is provided for postgresqlPassword:
required "A secure random value for .postgresql.postgresqlPassword is required" .Values.postgresql.postgresqlPassword