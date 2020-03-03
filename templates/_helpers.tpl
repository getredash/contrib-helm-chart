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
{{- if .Values.redash.existingSecret }}
    {{- printf "%s" .Values.redash.existingSecret -}}
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
## Start primary Redash configuration
{{- if or .Values.redash.secretKey .Values.redash.existingSecret }}
- name: REDASH_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "redash.secretName" . }}
      key: secretKey
{{- end }}
{{- if or .Values.redash.proxiesCount .Values.redash.existingSecret }}
- name: REDASH_PROXIES_COUNT
  value: {{ default  .Values.redash.proxiesCount | quote }}
{{- end }}
{{- if or .Values.redash.statsdHost .Values.redash.existingSecret }}
- name: REDASH_STATSD_HOST
  value: {{ default  .Values.redash.statsdHost | quote }}
{{- end }}
{{- if or .Values.redash.statsdPort .Values.redash.existingSecret }}
- name: REDASH_STATSD_PORT
  value: {{ default  .Values.redash.statsdPort | quote }}
{{- end }}
{{- if or .Values.redash.statsdPrefix .Values.redash.existingSecret }}
- name: REDASH_STATSD_PREFIX
  value: {{ default  .Values.redash.statsdPrefix | quote }}
{{- end }}
{{- if or .Values.redash.statsdUseTags .Values.redash.existingSecret }}
- name: REDASH_STATSD_USE_TAGS
  value: {{ default  .Values.redash.statsdUseTags | quote }}
{{- end }}
{{- if or .Values.redash.celeryBroker .Values.redash.existingSecret }}
- name: REDASH_CELERY_BROKER
  value: {{ default  .Values.redash.celeryBroker | quote }}
{{- end }}
{{- if or .Values.redash.celeryBackend .Values.redash.existingSecret }}
- name: REDASH_CELERY_BACKEND
  value: {{ default  .Values.redash.celeryBackend | quote }}
{{- end }}
{{- if or .Values.redash.celeryTaskResultExpires .Values.redash.existingSecret }}
- name: REDASH_CELERY_TASK_RESULT_EXPIRES
  value: {{ default  .Values.redash.celeryTaskResultExpires | quote }}
{{- end }}
{{- if or .Values.redash.queryResultsCleanupEnabled .Values.redash.existingSecret }}
- name: REDASH_QUERY_RESULTS_CLEANUP_ENABLED
  value: {{ default  .Values.redash.queryResultsCleanupEnabled | quote }}
{{- end }}
{{- if or .Values.redash.queryResultsCleanupCount .Values.redash.existingSecret }}
- name: REDASH_QUERY_RESULTS_CLEANUP_COUNT
  value: {{ default  .Values.redash.queryResultsCleanupCount | quote }}
{{- end }}
{{- if or .Values.redash.queryResultsCleanupMaxAge .Values.redash.existingSecret }}
- name: REDASH_QUERY_RESULTS_CLEANUP_MAX_AGE
  value: {{ default  .Values.redash.queryResultsCleanupMaxAge | quote }}
{{- end }}
{{- if or .Values.redash.schemasRefreshQueue .Values.redash.existingSecret }}
- name: REDASH_SCHEMAS_REFRESH_QUEUE
  value: {{ default  .Values.redash.schemasRefreshQueue | quote }}
{{- end }}
{{- if or .Values.redash.schemasRefreshSchedule .Values.redash.existingSecret }}
- name: REDASH_SCHEMAS_REFRESH_SCHEDULE
  value: {{ default  .Values.redash.schemasRefreshSchedule | quote }}
{{- end }}
{{- if or .Values.redash.authType .Values.redash.existingSecret }}
- name: REDASH_AUTH_TYPE
  value: {{ default  .Values.redash.authType | quote }}
{{- end }}
{{- if or .Values.redash.enforceHttps .Values.redash.existingSecret }}
- name: REDASH_ENFORCE_HTTPS
  value: {{ default  .Values.redash.enforceHttps | quote }}
{{- end }}
{{- if or .Values.redash.invitationTokenMaxAge .Values.redash.existingSecret }}
- name: REDASH_INVITATION_TOKEN_MAX_AGE
  value: {{ default  .Values.redash.invitationTokenMaxAge | quote }}
{{- end }}
{{- if or .Values.redash.multiOrg .Values.redash.existingSecret }}
- name: REDASH_MULTI_ORG
  value: {{ default  .Values.redash.multiOrg | quote }}
{{- end }}
{{- if or .Values.redash.googleClientId .Values.redash.existingSecret }}
- name: REDASH_GOOGLE_CLIENT_ID
  value: {{ default  .Values.redash.googleClientId | quote }}
{{- end }}
{{- if or .Values.redash.googleClientSecret .Values.redash.existingSecret }}
- name: REDASH_GOOGLE_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "redash.secretName" . }}
      key: googleClientSecret
{{- end }}
{{- if or .Values.redash.remoteUserLoginEnabled .Values.redash.existingSecret }}
- name: REDASH_REMOTE_USER_LOGIN_ENABLED
  value: {{ default  .Values.redash.remoteUserLoginEnabled | quote }}
{{- end }}
{{- if or .Values.redash.remoteUserHeader .Values.redash.existingSecret }}
- name: REDASH_REMOTE_USER_HEADER
  value: {{ default  .Values.redash.remoteUserHeader | quote }}
{{- end }}
{{- if or .Values.redash.ldapLoginEnabled .Values.redash.existingSecret }}
- name: REDASH_LDAP_LOGIN_ENABLED
  value: {{ default  .Values.redash.ldapLoginEnabled | quote }}
{{- end }}
{{- if or .Values.redash.ldapUrl .Values.redash.existingSecret }}
- name: REDASH_LDAP_URL
  value: {{ default  .Values.redash.ldapUrl | quote }}
{{- end }}
{{- if or .Values.redash.ldapBindDn .Values.redash.existingSecret }}
- name: REDASH_LDAP_BIND_DN
  value: {{ default  .Values.redash.ldapBindDn | quote }}
{{- end }}
{{- if or .Values.redash.ldapBindDnPassword .Values.redash.existingSecret }}
- name: REDASH_LDAP_BIND_DN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "redash.secretName" . }}
      key: ldapBindDnPassword
{{- end }}
{{- if or .Values.redash.ldapDisplayNameKey .Values.redash.existingSecret }}
- name: REDASH_LDAP_DISPLAY_NAME_KEY
  value: {{ default  .Values.redash.ldapDisplayNameKey | quote }}
{{- end }}
{{- if or .Values.redash.ldapEmailKey .Values.redash.existingSecret }}
- name: REDASH_LDAP_EMAIL_KEY
  value: {{ default  .Values.redash.ldapEmailKey | quote }}
{{- end }}
{{- if or .Values.redash.ldapCustomUsernamePrompt .Values.redash.existingSecret }}
- name: REDASH_LDAP_CUSTOM_USERNAME_PROMPT
  value: {{ default  .Values.redash.ldapCustomUsernamePrompt | quote }}
{{- end }}
{{- if or .Values.redash.ldapSearchTemplate .Values.redash.existingSecret }}
- name: REDASH_LDAP_SEARCH_TEMPLATE
  value: {{ default  .Values.redash.ldapSearchTemplate | quote }}
{{- end }}
{{- if or .Values.redash.ldapSearchDn .Values.redash.existingSecret }}
- name: REDASH_LDAP_SEARCH_DN
  value: {{ default  .Values.redash.ldapSearchDn | quote }}
{{- end }}
{{- if or .Values.redash.staticAssetsPath .Values.redash.existingSecret }}
- name: REDASH_STATIC_ASSETS_PATH
  value: {{ default  .Values.redash.staticAssetsPath | quote }}
{{- end }}
{{- if or .Values.redash.jobExpiryTime .Values.redash.existingSecret }}
- name: REDASH_JOB_EXPIRY_TIME
  value: {{ default  .Values.redash.jobExpiryTime | quote }}
{{- end }}
{{- if or .Values.redash.cookieSecret .Values.redash.existingSecret }}
- name: REDASH_COOKIE_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "redash.secretName" . }}
      key: cookieSecret
{{- end }}
{{- if or .Values.redash.logLevel .Values.redash.existingSecret }}
- name: REDASH_LOG_LEVEL
  value: {{ default  .Values.redash.logLevel | quote }}
{{- end }}
{{- if or .Values.redash.mailServer .Values.redash.existingSecret }}
- name: REDASH_MAIL_SERVER
  value: {{ default  .Values.redash.mailServer | quote }}
{{- end }}
{{- if or .Values.redash.mailPort .Values.redash.existingSecret }}
- name: REDASH_MAIL_PORT
  value: {{ default  .Values.redash.mailPort | quote }}
{{- end }}
{{- if or .Values.redash.mailUseTls .Values.redash.existingSecret }}
- name: REDASH_MAIL_USE_TLS
  value: {{ default  .Values.redash.mailUseTls | quote }}
{{- end }}
{{- if or .Values.redash.mailUseSsl .Values.redash.existingSecret }}
- name: REDASH_MAIL_USE_SSL
  value: {{ default  .Values.redash.mailUseSsl | quote }}
{{- end }}
{{- if or .Values.redash.mailUsername .Values.redash.existingSecret }}
- name: REDASH_MAIL_USERNAME
  value: {{ default  .Values.redash.mailUsername | quote }}
{{- end }}
{{- if or .Values.redash.mailPassword .Values.redash.existingSecret }}
- name: REDASH_MAIL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "redash.secretName" . }}
      key: mailPassword
{{- end }}
{{- if or .Values.redash.mailDefaultSender .Values.redash.existingSecret }}
- name: REDASH_MAIL_DEFAULT_SENDER
  value: {{ default  .Values.redash.mailDefaultSender | quote }}
{{- end }}
{{- if or .Values.redash.mailMaxEmails .Values.redash.existingSecret }}
- name: REDASH_MAIL_MAX_EMAILS
  value: {{ default  .Values.redash.mailMaxEmails | quote }}
{{- end }}
{{- if or .Values.redash.mailAsciiAttachments .Values.redash.existingSecret }}
- name: REDASH_MAIL_ASCII_ATTACHMENTS
  value: {{ default  .Values.redash.mailAsciiAttachments | quote }}
{{- end }}
{{- if or .Values.redash.host .Values.redash.existingSecret }}
- name: REDASH_HOST
  value: {{ default  .Values.redash.host | quote }}
{{- end }}
{{- if or .Values.redash.alertsDefaultMailSubjectTemplate .Values.redash.existingSecret }}
- name: REDASH_ALERTS_DEFAULT_MAIL_SUBJECT_TEMPLATE
  value: {{ default  .Values.redash.alertsDefaultMailSubjectTemplate | quote }}
{{- end }}
{{- if or .Values.redash.throttleLoginPattern .Values.redash.existingSecret }}
- name: REDASH_THROTTLE_LOGIN_PATTERN
  value: {{ default  .Values.redash.throttleLoginPattern | quote }}
{{- end }}
{{- if or .Values.redash.limiterStorage .Values.redash.existingSecret }}
- name: REDASH_LIMITER_STORAGE
  value: {{ default  .Values.redash.limiterStorage | quote }}
{{- end }}
{{- if or .Values.redash.corsAccessControlAllowOrigin .Values.redash.existingSecret }}
- name: REDASH_CORS_ACCESS_CONTROL_ALLOW_ORIGIN
  value: {{ default  .Values.redash.corsAccessControlAllowOrigin | quote }}
{{- end }}
{{- if or .Values.redash.corsAccessControlAllowCredentials .Values.redash.existingSecret }}
- name: REDASH_CORS_ACCESS_CONTROL_ALLOW_CREDENTIALS
  value: {{ default  .Values.redash.corsAccessControlAllowCredentials | quote }}
{{- end }}
{{- if or .Values.redash.corsAccessControlRequestMethod .Values.redash.existingSecret }}
- name: REDASH_CORS_ACCESS_CONTROL_REQUEST_METHOD
  value: {{ default  .Values.redash.corsAccessControlRequestMethod | quote }}
{{- end }}
{{- if or .Values.redash.corsAccessControlAllowHeaders .Values.redash.existingSecret }}
- name: REDASH_CORS_ACCESS_CONTROL_ALLOW_HEADERS
  value: {{ default  .Values.redash.corsAccessControlAllowHeaders | quote }}
{{- end }}
{{- if or .Values.redash.enabledQueryRunners .Values.redash.existingSecret }}
- name: REDASH_ENABLED_QUERY_RUNNERS
  value: {{ default  .Values.redash.enabledQueryRunners | quote }}
{{- end }}
{{- if or .Values.redash.additionalQueryRunners .Values.redash.existingSecret }}
- name: REDASH_ADDITIONAL_QUERY_RUNNERS
  value: {{ default  .Values.redash.additionalQueryRunners | quote }}
{{- end }}
{{- if or .Values.redash.disabledQueryRunners .Values.redash.existingSecret }}
- name: REDASH_DISABLED_QUERY_RUNNERS
  value: {{ default  .Values.redash.disabledQueryRunners | quote }}
{{- end }}
{{- if or .Values.redash.adhocQueryTimeLimit .Values.redash.existingSecret }}
- name: REDASH_ADHOC_QUERY_TIME_LIMIT
  value: {{ default  .Values.redash.adhocQueryTimeLimit | quote }}
{{- end }}
{{- if or .Values.redash.enabledDestinations .Values.redash.existingSecret }}
- name: REDASH_ENABLED_DESTINATIONS
  value: {{ default  .Values.redash.enabledDestinations | quote }}
{{- end }}
{{- if or .Values.redash.additionalDestinations .Values.redash.existingSecret }}
- name: REDASH_ADDITIONAL_DESTINATIONS
  value: {{ default  .Values.redash.additionalDestinations | quote }}
{{- end }}
{{- if or .Values.redash.eventReportingWebhooks .Values.redash.existingSecret }}
- name: REDASH_EVENT_REPORTING_WEBHOOKS
  value: {{ default  .Values.redash.eventReportingWebhooks | quote }}
{{- end }}
{{- if or .Values.redash.sentryDsn .Values.redash.existingSecret }}
- name: REDASH_SENTRY_DSN
  value: {{ default  .Values.redash.sentryDsn | quote }}
{{- end }}
{{- if or .Values.redash.allowScriptsInUserInput .Values.redash.existingSecret }}
- name: REDASH_ALLOW_SCRIPTS_IN_USER_INPUT
  value: {{ default  .Values.redash.allowScriptsInUserInput | quote }}
{{- end }}
{{- if or .Values.redash.dashboardRefreshIntervals .Values.redash.existingSecret }}
- name: REDASH_DASHBOARD_REFRESH_INTERVALS
  value: {{ default  .Values.redash.dashboardRefreshIntervals | quote }}
{{- end }}
{{- if or .Values.redash.queryRefreshIntervals .Values.redash.existingSecret }}
- name: REDASH_QUERY_REFRESH_INTERVALS
  value: {{ default  .Values.redash.queryRefreshIntervals | quote }}
{{- end }}
{{- if or .Values.redash.passwordLoginEnabled .Values.redash.existingSecret }}
- name: REDASH_PASSWORD_LOGIN_ENABLED
  value: {{ default  .Values.redash.passwordLoginEnabled | quote }}
{{- end }}
{{- if or .Values.redash.samlMetadataUrl .Values.redash.existingSecret }}
- name: REDASH_SAML_METADATA_URL
  value: {{ default  .Values.redash.samlMetadataUrl | quote }}
{{- end }}
{{- if or .Values.redash.samlEntityId .Values.redash.existingSecret }}
- name: REDASH_SAML_ENTITY_ID
  value: {{ default  .Values.redash.samlEntityId | quote }}
{{- end }}
{{- if or .Values.redash.samlNameidFormat .Values.redash.existingSecret }}
- name: REDASH_SAML_NAMEID_FORMAT
  value: {{ default  .Values.redash.samlNameidFormat | quote }}
{{- end }}
{{- if or .Values.redash.dateFormat .Values.redash.existingSecret }}
- name: REDASH_DATE_FORMAT
  value: {{ default  .Values.redash.dateFormat | quote }}
{{- end }}
{{- if or .Values.redash.jwtLoginEnabled .Values.redash.existingSecret }}
- name: REDASH_JWT_LOGIN_ENABLED
  value: {{ default  .Values.redash.jwtLoginEnabled | quote }}
{{- end }}
{{- if or .Values.redash.jwtAuthIssuer .Values.redash.existingSecret }}
- name: REDASH_JWT_AUTH_ISSUER
  value: {{ default  .Values.redash.jwtAuthIssuer | quote }}
{{- end }}
{{- if or .Values.redash.jwtAuthPublicCertsUrl .Values.redash.existingSecret }}
- name: REDASH_JWT_AUTH_PUBLIC_CERTS_URL
  value: {{ default  .Values.redash.jwtAuthPublicCertsUrl | quote }}
{{- end }}
{{- if or .Values.redash.jwtAuthAudience .Values.redash.existingSecret }}
- name: REDASH_JWT_AUTH_AUDIENCE
  value: {{ default  .Values.redash.jwtAuthAudience | quote }}
{{- end }}
{{- if or .Values.redash.jwtAuthAlgorithms .Values.redash.existingSecret }}
- name: REDASH_JWT_AUTH_ALGORITHMS
  value: {{ default  .Values.redash.jwtAuthAlgorithms | quote }}
{{- end }}
{{- if or .Values.redash.jwtAuthCookieName .Values.redash.existingSecret }}
- name: REDASH_JWT_AUTH_COOKIE_NAME
  value: {{ default  .Values.redash.jwtAuthCookieName | quote }}
{{- end }}
{{- if or .Values.redash.jwtAuthHeaderName .Values.redash.existingSecret }}
- name: REDASH_JWT_AUTH_HEADER_NAME
  value: {{ default  .Values.redash.jwtAuthHeaderName | quote }}
{{- end }}
{{- if or .Values.redash.featureShowQueryResultsCount .Values.redash.existingSecret }}
- name: REDASH_FEATURE_SHOW_QUERY_RESULTS_COUNT
  value: {{ default  .Values.redash.featureShowQueryResultsCount | quote }}
{{- end }}
{{- if or .Values.redash.versionCheck .Values.redash.existingSecret }}
- name: REDASH_VERSION_CHECK
  value: {{ default  .Values.redash.versionCheck | quote }}
{{- end }}
{{- if or .Values.redash.featureDisableRefreshQueries .Values.redash.existingSecret }}
- name: REDASH_FEATURE_DISABLE_REFRESH_QUERIES
  value: {{ default  .Values.redash.featureDisableRefreshQueries | quote }}
{{- end }}
{{- if or .Values.redash.featureShowPermissionsControl .Values.redash.existingSecret }}
- name: REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL
  value: {{ default  .Values.redash.featureShowPermissionsControl | quote }}
{{- end }}
{{- if or .Values.redash.featureAllowCustomJsVisualizations .Values.redash.existingSecret }}
- name: REDASH_FEATURE_ALLOW_CUSTOM_JS_VISUALIZATIONS
  value: {{ default  .Values.redash.featureAllowCustomJsVisualizations | quote }}
{{- end }}
{{- if or .Values.redash.featureDumbRecents .Values.redash.existingSecret }}
- name: REDASH_FEATURE_DUMB_RECENTS
  value: {{ default  .Values.redash.featureDumbRecents | quote }}
{{- end }}
{{- if or .Values.redash.featureAutoPublishNamedQueries .Values.redash.existingSecret }}
- name: REDASH_FEATURE_AUTO_PUBLISH_NAMED_QUERIES
  value: {{ default  .Values.redash.featureAutoPublishNamedQueries | quote }}
{{- end }}
{{- if or .Values.redash.bigqueryHttpTimeout .Values.redash.existingSecret }}
- name: REDASH_BIGQUERY_HTTP_TIMEOUT
  value: {{ default  .Values.redash.bigqueryHttpTimeout | quote }}
{{- end }}
{{- if or .Values.redash.schemaRunTableSizeCalculations .Values.redash.existingSecret }}
- name: REDASH_SCHEMA_RUN_TABLE_SIZE_CALCULATIONS
  value: {{ default  .Values.redash.schemaRunTableSizeCalculations | quote }}
{{- end }}
{{- if or .Values.redash.webWorkers .Values.redash.existingSecret }}
- name: REDASH_WEB_WORKERS
  value: {{ default  .Values.redash.webWorkers | quote }}
{{- end }}
## End primary Redash configuration
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