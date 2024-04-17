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
{{- with .Values.fullnameOverride -}}
{{- . | trunc 43 | trimSuffix "-" -}}
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
Create a default fully qualified worker name.
*/}}
{{- define "redash.worker.fullname" -}}
{{- template "redash.fullname" . -}}-{{ .workerName }}worker
{{- end -}}

{{/*
Create a default fully qualified scheduler name.
*/}}
{{- define "redash.scheduler.fullname" -}}
{{- template "redash.fullname" . -}}-scheduler
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
{{- if not .Values.postgresql.enabled -}}
{{- if not .Values.redash.selfManagedSecrets -}}
- name: REDASH_DATABASE_URL
  {{- with .Values.externalPostgreSQLSecret }}
  valueFrom:
    secretKeyRef: {{ toYaml . | nindent 6 }}
  {{- else }}
  value: {{ default "" .Values.externalPostgreSQL | quote }}
  {{- end }}
{{- end }}
{{- else -}}
- name: REDASH_DATABASE_USER
  value: {{ .Values.postgresql.auth.username | quote }}
- name: REDASH_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-postgresql
      key: password
- name: REDASH_DATABASE_HOSTNAME
  value: {{ include "redash.postgresql.fullname" . }}
- name: REDASH_DATABASE_PORT
  value: {{ .Values.postgresql.primary.service.ports.postgresql | quote }}
- name: REDASH_DATABASE_NAME
  value: {{ .Values.postgresql.auth.database | quote }}
{{- end -}}
{{- if not .Values.redis.enabled }}
{{- if not .Values.redash.selfManagedSecrets -}}
- name: REDASH_REDIS_URL
  {{- with .Values.externalRedisSecret }}
  valueFrom:
    secretKeyRef: {{ toYaml . | nindent 6 }}
  {{- else }}
  value: {{ default "" .Values.externalRedis | quote }}
  {{- end }}
{{- end }}
{{- else }}
- name: REDASH_REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
    {{- with .Values.redis.existingSecret }}
      name: {{ . }}
    {{- else }}
      name: {{ .Release.Name }}-redis
    {{- end }}
      key: redis-password
- name: REDASH_REDIS_HOSTNAME
  value: {{ include "redash.redis.fullname" . }}
- name: REDASH_REDIS_PORT
  value: {{ .Values.redis.master.service.ports.redis | quote }}
- name: REDASH_REDIS_NAME
  value: {{ .Values.redis.database | quote }}
{{ end -}}
{{ range $key, $value := .Values.env -}}
- name: {{ $key }}
  value: {{ $value | quote }}
{{ end -}}
## Start primary Redash configuration
{{- if not .Values.redash.selfManagedSecrets }}
{{- if or .Values.redash.secretKey .Values.redash.existingSecret }}
- name: REDASH_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "redash.secretName" . }}
      key: secretKey
{{- end }}
{{- end }}
{{- with .Values.redash.samlSchemeOverride }}
- name: REDASH_SAML_SCHEME_OVERRIDE
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.disablePublicUrls }}
- name: REDASH_DISABLE_PUBLIC_URLS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.blockedDomains }}
- name: REDASH_BLOCKED_DOMAINS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.proxiesCount }}
- name: REDASH_PROXIES_COUNT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.statsdEnabled }}
- name: REDASH_STATSD_ENABLED
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.statsdHost }}
- name: REDASH_STATSD_HOST
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.statsdPort }}
- name: REDASH_STATSD_PORT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.statsdPrefix }}
- name: REDASH_STATSD_PREFIX
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.statsdUseTags }}
- name: REDASH_STATSD_USE_TAGS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.queryResultsCleanupEnabled }}
- name: REDASH_QUERY_RESULTS_CLEANUP_ENABLED
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.queryResultsCleanupCount }}
- name: REDASH_QUERY_RESULTS_CLEANUP_COUNT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.queryResultsCleanupMaxAge }}
- name: REDASH_QUERY_RESULTS_CLEANUP_MAX_AGE
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.schemasRefreshSchedule }}
- name: REDASH_SCHEMAS_REFRESH_SCHEDULE
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.authType }}
- name: REDASH_AUTH_TYPE
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.enforceHttps }}
- name: REDASH_ENFORCE_HTTPS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.invitationTokenMaxAge }}
- name: REDASH_INVITATION_TOKEN_MAX_AGE
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.multiOrg }}
- name: REDASH_MULTI_ORG
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.googleClientId }}
- name: REDASH_GOOGLE_CLIENT_ID
  value: {{ quote . }}
{{- end }}
{{- if not .Values.redash.selfManagedSecrets }}
{{- if or .Values.redash.googleClientSecret .Values.redash.existingSecret }}
- name: REDASH_GOOGLE_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "redash.secretName" . }}
      key: googleClientSecret
{{- end }}
{{- end }}
{{- with .Values.redash.remoteUserLoginEnabled }}
- name: REDASH_REMOTE_USER_LOGIN_ENABLED
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.remoteUserHeader }}
- name: REDASH_REMOTE_USER_HEADER
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.ldapLoginEnabled }}
- name: REDASH_LDAP_LOGIN_ENABLED
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.ldapUrl }}
- name: REDASH_LDAP_URL
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.ldapBindDn }}
- name: REDASH_LDAP_BIND_DN
  value: {{ quote . }}
{{- end }}
{{- if not .Values.redash.selfManagedSecrets }}
{{- if or .Values.redash.ldapBindDnPassword .Values.redash.existingSecret }}
- name: REDASH_LDAP_BIND_DN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "redash.secretName" . }}
      key: ldapBindDnPassword
{{- end }}
{{- end }}
{{- with .Values.redash.ldapDisplayNameKey }}
- name: REDASH_LDAP_DISPLAY_NAME_KEY
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.ldapEmailKey }}
- name: REDASH_LDAP_EMAIL_KEY
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.ldapCustomUsernamePrompt }}
- name: REDASH_LDAP_CUSTOM_USERNAME_PROMPT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.ldapSearchTemplate }}
- name: REDASH_LDAP_SEARCH_TEMPLATE
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.ldapSearchDn }}
- name: REDASH_LDAP_SEARCH_DN
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.staticAssetsPath }}
- name: REDASH_STATIC_ASSETS_PATH
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.jobExpiryTime }}
- name: REDASH_JOB_EXPIRY_TIME
  value: {{ quote . }}
{{- end }}
{{- if not .Values.redash.selfManagedSecrets }}
{{- if or .Values.redash.cookieSecret .Values.redash.existingSecret }}
- name: REDASH_COOKIE_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "redash.secretName" . }}
      key: cookieSecret
{{- end }}
{{- end }}
{{- with .Values.redash.logLevel }}
- name: REDASH_LOG_LEVEL
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.mailServer }}
- name: REDASH_MAIL_SERVER
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.mailPort }}
- name: REDASH_MAIL_PORT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.mailUseTls }}
- name: REDASH_MAIL_USE_TLS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.mailUseSsl }}
- name: REDASH_MAIL_USE_SSL
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.mailUsername }}
- name: REDASH_MAIL_USERNAME
  value: {{ quote . }}
{{- end }}
{{- if not .Values.redash.selfManagedSecrets }}
{{- if or .Values.redash.mailPassword .Values.redash.existingSecret }}
- name: REDASH_MAIL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "redash.secretName" . }}
      key: mailPassword
{{- end }}
{{- end }}
{{- with .Values.redash.mailDefaultSender }}
- name: REDASH_MAIL_DEFAULT_SENDER
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.mailMaxEmails }}
- name: REDASH_MAIL_MAX_EMAILS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.mailAsciiAttachments }}
- name: REDASH_MAIL_ASCII_ATTACHMENTS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.host }}
- name: REDASH_HOST
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.alertsDefaultMailSubjectTemplate }}
- name: REDASH_ALERTS_DEFAULT_MAIL_SUBJECT_TEMPLATE
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.throttleLoginPattern }}
- name: REDASH_THROTTLE_LOGIN_PATTERN
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.limiterStorage }}
- name: REDASH_LIMITER_STORAGE
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.corsAccessControlAllowOrigin }}
- name: REDASH_CORS_ACCESS_CONTROL_ALLOW_ORIGIN
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.corsAccessControlAllowCredentials }}
- name: REDASH_CORS_ACCESS_CONTROL_ALLOW_CREDENTIALS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.corsAccessControlRequestMethod }}
- name: REDASH_CORS_ACCESS_CONTROL_REQUEST_METHOD
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.corsAccessControlAllowHeaders }}
- name: REDASH_CORS_ACCESS_CONTROL_ALLOW_HEADERS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.enabledQueryRunners }}
- name: REDASH_ENABLED_QUERY_RUNNERS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.additionalQueryRunners }}
- name: REDASH_ADDITIONAL_QUERY_RUNNERS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.disabledQueryRunners }}
- name: REDASH_DISABLED_QUERY_RUNNERS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.scheduledQueryTimeLimit }}
- name: REDASH_SCHEDULED_QUERY_TIME_LIMIT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.adhocQueryTimeLimit }}
- name: REDASH_ADHOC_QUERY_TIME_LIMIT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.enabledDestinations }}
- name: REDASH_ENABLED_DESTINATIONS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.additionalDestinations }}
- name: REDASH_ADDITIONAL_DESTINATIONS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.eventReportingWebhooks }}
- name: REDASH_EVENT_REPORTING_WEBHOOKS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.sentryDsn }}
- name: REDASH_SENTRY_DSN
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.allowScriptsInUserInput }}
- name: REDASH_ALLOW_SCRIPTS_IN_USER_INPUT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.dashboardRefreshIntervals }}
- name: REDASH_DASHBOARD_REFRESH_INTERVALS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.queryRefreshIntervals }}
- name: REDASH_QUERY_REFRESH_INTERVALS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.passwordLoginEnabled }}
- name: REDASH_PASSWORD_LOGIN_ENABLED
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.samlMetadataUrl }}
- name: REDASH_SAML_METADATA_URL
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.samlEntityId }}
- name: REDASH_SAML_ENTITY_ID
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.samlNameidFormat }}
- name: REDASH_SAML_NAMEID_FORMAT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.dateFormat }}
- name: REDASH_DATE_FORMAT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.jwtLoginEnabled }}
- name: REDASH_JWT_LOGIN_ENABLED
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.jwtAuthIssuer }}
- name: REDASH_JWT_AUTH_ISSUER
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.jwtAuthPublicCertsUrl }}
- name: REDASH_JWT_AUTH_PUBLIC_CERTS_URL
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.jwtAuthAudience }}
- name: REDASH_JWT_AUTH_AUDIENCE
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.jwtAuthAlgorithms }}
- name: REDASH_JWT_AUTH_ALGORITHMS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.jwtAuthCookieName }}
- name: REDASH_JWT_AUTH_COOKIE_NAME
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.jwtAuthHeaderName }}
- name: REDASH_JWT_AUTH_HEADER_NAME
  value: {{ .quote }}
{{- end }}
{{- with .Values.redash.featureShowQueryResultsCount }}
- name: REDASH_FEATURE_SHOW_QUERY_RESULTS_COUNT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.versionCheck }}
- name: REDASH_VERSION_CHECK
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.featureDisableRefreshQueries }}
- name: REDASH_FEATURE_DISABLE_REFRESH_QUERIES
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.featureShowPermissionsControl }}
- name: REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.featureAllowCustomJsVisualizations }}
- name: REDASH_FEATURE_ALLOW_CUSTOM_JS_VISUALIZATIONS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.featureAutoPublishNamedQueries }}
- name: REDASH_FEATURE_AUTO_PUBLISH_NAMED_QUERIES
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.bigqueryHttpTimeout }}
- name: REDASH_BIGQUERY_HTTP_TIMEOUT
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.schemaRunTableSizeCalculations }}
- name: REDASH_SCHEMA_RUN_TABLE_SIZE_CALCULATIONS
  value: {{ quote . }}
{{- end }}
{{- with .Values.redash.webWorkers }}
- name: REDASH_WEB_WORKERS
  value: {{ quote . }}
{{- end }}
## End primary Redash configuration
{{- end -}}

{{/*
Environment variables initialized from secret used across each component.
*/}}
{{- define "redash.envFrom" -}}
{{- with .Values.envSecretName -}}
- secretRef:
    name: {{ . }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "redash.labels" -}}
helm.sh/chart: {{ include "redash.chart" . }}
{{ include "redash.selectorLabels" . }}
{{- with .workerName }}
app.kubernetes.io/component: {{ . }}worker
{{- end }}
{{- if or .Chart.AppVersion .Values.image.tag }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
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

# This ensures a random value is provided for postgresql.auth.password:
required "A secure random value for .postgresql.auth.password is required" .Values.postgresql.auth.password
