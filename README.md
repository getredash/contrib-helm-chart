# Redash

Redash is an open source tool built for teams to query, visualize and collaborate.

## Introduction

This chart bootstraps a [Redash](https://github.com/getredash/redash) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

This is a contributed project developed by volunteers and not officially supported by Redash.

Current chart version is `3.0.0-beta1`

* <https://github.com/getredash/redash>

## Prerequisites

- At least 3 GB of RAM available on your cluster
- Kubernetes 1.19+ - chart is tested with latest 3 stable versions
- Helm 3 (Helm 2 depreciated)
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`, add the chart repository:

```bash
$ helm repo add redash https://getredash.github.io/contrib-helm-chart/
```

Create a values file with required secrets (store this securely!):

```bash
$ cat > my-values.yaml <<- EOM
redash:
  cookieSecret: $(openssl rand -base64 32)
  secretKey: $(openssl rand -base64 32)
postgresql:
  postgresqlPassword: $(openssl rand -base64 32)
redis:
  password: $(openssl rand -base64 32)
EOM
```

Install the chart:

```bash
$ helm upgrade --install -f my-values.yaml my-release redash/redash
```

The command deploys Redash on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section and and default [values.yaml](values.yaml) lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | ^8.10.14 |
| https://charts.bitnami.com/bitnami | redis | ^10.8.2 |

## Configuration

The following table lists the configurable parameters of the Redash chart and their default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| adhocWorker.affinity | object | `{}` | Affinity for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| adhocWorker.env | object | `{"QUEUES":"queries","WORKERS_COUNT":2}` | Redash ad-hoc worker specific envrionment variables. |
| adhocWorker.nodeSelector | object | `{}` | Node labels for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| adhocWorker.podAnnotations | object | `{}` | Annotations for adhoc worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| adhocWorker.podLabels | object | `{}` | Labels for adhoc worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| adhocWorker.podSecurityContext | object | `{}` | Security contexts for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| adhocWorker.replicaCount | int | `1` | Number of ad-hoc worker pods to run |
| adhocWorker.resources | string | `nil` | Ad-hoc worker resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| adhocWorker.securityContext | object | `{}` |  |
| adhocWorker.tolerations | list | `[]` | Tolerations for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| adhocWorker.volumeMounts | list | `[]` | VolumeMounts for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| adhocWorker.volumes | list | `[]` | Volumes for ad-hoc pod worker assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| env | object | `{"PYTHONUNBUFFERED":0}` | Redash global envrionment variables - applied to both server and worker containers. |
| externalPostgreSQL | string | `nil` | External PostgreSQL configuration. To use an external PostgreSQL instead of the automatically deployed postgresql chart: set postgresql.enabled to false then uncomment and configure the externalPostgreSQL connection URL (e.g. postgresql://user:pass@host:5432/database) |
| externalPostgreSQLSecret | object | `{}` | Read external PostgreSQL configuration from a secret. This should point at a secret file with a single key which specifyies the connection string. |
| externalRedis | string | `nil` | External Redis configuration. To use an external Redis instead of the automatically deployed redis chart: set redis.enabled to false then uncomment and configure the externalRedis connection URL (e.g. redis://user:pass@host:6379/database). |
| externalRedisSecret | object | `{}` | Read external Redis configuration from a secret. This should point at a secret file with a single key which specifyies the connection string. |
| fullnameOverride | string | `""` |  |
| genericWorker.affinity | object | `{}` | Affinity for generic worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| genericWorker.env | object | `{"QUEUES":"periodic,emails,default","WORKERS_COUNT":1}` | Redash generic worker specific envrionment variables. |
| genericWorker.nodeSelector | object | `{}` | Node labels for generic worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| genericWorker.podAnnotations | object | `{}` | Annotations for generic worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| genericWorker.podLabels | object | `{}` | Labels for generic worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| genericWorker.podSecurityContext | object | `{}` | Security contexts for generic worker pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| genericWorker.replicaCount | int | `1` | Number of generic worker pods to run |
| genericWorker.resources | string | `nil` | Generic worker resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| genericWorker.securityContext | object | `{}` |  |
| genericWorker.tolerations | list | `[]` | Tolerations for generic worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| genericWorker.volumeMounts | list | `[]` | VolumeMounts for generic worker pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| genericWorker.volumes | list | `[]` | Volumes for generic worker pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| hookInstallJob.affinity | object | `{}` | Affinity for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| hookInstallJob.nodeSelector | object | `{}` | Node labels for scheduled worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| hookInstallJob.podAnnotations | object | `{}` | Annotations for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| hookInstallJob.podSecurityContext | object | `{}` | Security contexts for scheduled worker pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| hookInstallJob.resources | string | `nil` | Scheduled worker resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| hookInstallJob.securityContext | object | `{}` |  |
| hookInstallJob.tolerations | list | `[]` | Tolerations for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| hookInstallJob.ttlSecondsAfterFinished | int | `600` | ttl for install job [ref](https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/) |
| hookUpgradeJob.affinity | object | `{}` | Affinity for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| hookUpgradeJob.nodeSelector | object | `{}` | Node labels for scheduled worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| hookUpgradeJob.podAnnotations | object | `{}` | Annotations for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| hookUpgradeJob.podSecurityContext | object | `{}` | Security contexts for scheduled worker pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| hookUpgradeJob.resources | string | `nil` | Scheduled worker resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| hookUpgradeJob.securityContext | object | `{}` |  |
| hookUpgradeJob.tolerations | list | `[]` | Tolerations for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| hookUpgradeJob.ttlSecondsAfterFinished | int | `600` | ttl for install job [ref](https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/) |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"redash/redash"` | Redash image name used for server and worker pods |
| image.tag | string | `"10.0.0.b50363"` | Redash image [tag](https://hub.docker.com/r/redash/redash/tags) |
| imagePullSecrets | list | `[]` | Name(s) of secrets to use if pulling images from a private registry |
| ingress.annotations | object | `{}` | Ingress annotations configuration |
| ingress.enabled | bool | `false` | Enable ingress controller resource |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[]}]` | Ingress resource hostnames and path mappings |
| ingress.ingressClassName | string | `""` | Sets the ingress controller class name to use. |
| ingress.pathType | string | `"Prefix"` | How ingress paths should be treated. |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| nameOverride | string | `""` |  |
| postgresql.enabled | bool | `true` | Whether to deploy a PostgreSQL server to satisfy the applications database requirements. To use an external PostgreSQL set this to false and configure the externalPostgreSQL parameter. |
| postgresql.image.tag | string | `"9.6.17-debian-10-r3"` | Bitnami supported version close to the one specified in Redash [setup docker-compose.yml](https://github.com/getredash/setup/blob/master/data/docker-compose.yml) |
| postgresql.persistence.accessMode | string | `"ReadWriteOnce"` | Use PostgreSQL volume as ReadOnly or ReadWrite |
| postgresql.persistence.enabled | bool | `true` | Use a PVC to persist PostgreSQL data (when postgresql chart enabled) |
| postgresql.persistence.size | string | `"10Gi"` | PVC Storage Request size for PostgreSQL volume |
| postgresql.persistence.storageClass | string | `""` |  |
| postgresql.postgresqlDatabase | string | `"redash"` | PostgreSQL database name (when postgresql chart enabled) |
| postgresql.postgresqlPassword | string | `nil` | REQUIRED: PostgreSQL password for redash user (when postgresql chart enabled) |
| postgresql.postgresqlUsername | string | `"redash"` | PostgreSQL username for redash user (when postgresql chart enabled) |
| postgresql.service.port | int | `5432` |  |
| postgresql.service.type | string | `"ClusterIP"` |  |
| redash.additionalDestinations | string | `""` | `REDASH_ADDITIONAL_DESTINATIONS` value. |
| redash.additionalQueryRunners | string | `""` | `REDASH_ADDITIONAL_QUERY_RUNNERS` value. |
| redash.adhocQueryTimeLimit | string | None | `REDASH_ADHOC_QUERY_TIME_LIMIT` value. Time limit for adhoc queries (in seconds). |
| redash.alertsDefaultMailSubjectTemplate | string | ({state}) {alert_name} | `REDASH_ALERTS_DEFAULT_MAIL_SUBJECT_TEMPLATE` value. |
| redash.allowScriptsInUserInput | string | false | `REDASH_ALLOW_SCRIPTS_IN_USER_INPUT` value. Disable sanitization of text input, allowing full html. |
| redash.authType | string | api_key | `REDASH_AUTH_TYPE` value. |
| redash.bigqueryHttpTimeout | string | 600 | `REDASH_BIGQUERY_HTTP_TIMEOUT` value. |
| redash.celeryBackend | string | CELERY_BROKER | `REDASH_CELERY_BACKEND` value. |
| redash.celeryBroker | string | REDIS_URL | `REDASH_CELERY_BROKER` value. |
| redash.celeryTaskResultExpires | string | 3600 \* 4 | `REDASH_CELERY_TASK_RESULT_EXPIRES` value. How many seconds to keep celery task results in cache (in seconds). |
| redash.cookieSecret | string | `""` | REQUIRED `REDASH_COOKIE_SECRET` value. Stored as a Secret value. |
| redash.corsAccessControlAllowCredentials | string | false | `REDASH_CORS_ACCESS_CONTROL_ALLOW_CREDENTIALS` value. |
| redash.corsAccessControlAllowHeaders | string | Content-Type | `REDASH_CORS_ACCESS_CONTROL_ALLOW_HEADERS` value. |
| redash.corsAccessControlAllowOrigin | string | `""` | `REDASH_CORS_ACCESS_CONTROL_ALLOW_ORIGIN` value. |
| redash.corsAccessControlRequestMethod | string | GET, POST, PUT | `REDASH_CORS_ACCESS_CONTROL_REQUEST_METHOD` value. |
| redash.dashboardRefreshIntervals | string | 60,300,600,1800,3600,43200,86400 | `REDASH_DASHBOARD_REFRESH_INTERVALS` value. |
| redash.dateFormat | string | DD/MM/YY | `REDASH_DATE_FORMAT` value. |
| redash.disabledQueryRunners | string | `""` | `REDASH_DISABLED_QUERY_RUNNERS` value. |
| redash.enabledDestinations | string | ”,”.join(default_destinations) | `REDASH_ENABLED_DESTINATIONS` value. |
| redash.enabledQueryRunners | string | ”,”.join(default_query_runners) | `REDASH_ENABLED_QUERY_RUNNERS` value. |
| redash.enforceHttps | string | false | `REDASH_ENFORCE_HTTPS` value. |
| redash.eventReportingWebhooks | string | `""` | `REDASH_EVENT_REPORTING_WEBHOOKS` value. |
| redash.featureAllowCustomJsVisualizations | string | false | `REDASH_FEATURE_ALLOW_CUSTOM_JS_VISUALIZATIONS` value. |
| redash.featureAutoPublishNamedQueries | string | true | `REDASH_FEATURE_AUTO_PUBLISH_NAMED_QUERIES` value. |
| redash.featureDisableRefreshQueries | string | false | `REDASH_FEATURE_DISABLE_REFRESH_QUERIES` value. Disable scheduled query execution. |
| redash.featureDumbRecents | string | false | `REDASH_FEATURE_DUMB_RECENTS` value. |
| redash.featureExtendedAlertOptions | string | false | `REDASH_FEATURE_EXTENDED_ALERT_OPTIONS` value. Disable/enable custom template for alert. |
| redash.featureShowPermissionsControl | string | false | `REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL` value. |
| redash.featureShowQueryResultsCount | string | true | `REDASH_FEATURE_SHOW_QUERY_RESULTS_COUNT` value. Disable/enable showing count of query results in status. |
| redash.googleClientId | string | `""` | `REDASH_GOOGLE_CLIENT_ID` value. |
| redash.googleClientSecret | string | `""` | `REDASH_GOOGLE_CLIENT_SECRET` value. Stored as a Secret value. |
| redash.host | string | `""` | `REDASH_HOST` value. |
| redash.invitationTokenMaxAge | string | 60 _ 60 _ 24 \* 7 | `REDASH_INVITATION_TOKEN_MAX_AGE` value. |
| redash.jobExpiryTime | string | 3600 \* 12 | `REDASH_JOB_EXPIRY_TIME` value. |
| redash.jwtAuthAlgorithms | string | HS256,RS256,ES256 | `REDASH_JWT_AUTH_ALGORITHMS` value. |
| redash.jwtAuthAudience | string | `""` | `REDASH_JWT_AUTH_AUDIENCE` value. |
| redash.jwtAuthCookieName | string | `""` | `REDASH_JWT_AUTH_COOKIE_NAME` value. |
| redash.jwtAuthHeaderName | string | `""` | `REDASH_JWT_AUTH_HEADER_NAME` value. |
| redash.jwtAuthIssuer | string | `""` | `REDASH_JWT_AUTH_ISSUER` value. |
| redash.jwtAuthPublicCertsUrl | string | `""` | `REDASH_JWT_AUTH_PUBLIC_CERTS_URL` value. |
| redash.jwtLoginEnabled | string | false | `REDASH_JWT_LOGIN_ENABLED` value. |
| redash.ldapBindDn | string | None | `REDASH_LDAP_BIND_DN` value. |
| redash.ldapBindDnPassword | string | `""` | `REDASH_LDAP_BIND_DN_PASSWORD` value. Stored as a Secret value. |
| redash.ldapCustomUsernamePrompt | string | LDAP/AD/SSO username: | `REDASH_LDAP_CUSTOM_USERNAME_PROMPT` value. |
| redash.ldapDisplayNameKey | string | displayName | `REDASH_LDAP_DISPLAY_NAME_KEY` value. |
| redash.ldapEmailKey | string | mail | `REDASH_LDAP_EMAIL_KEY` value. |
| redash.ldapLoginEnabled | string | false | `REDASH_LDAP_LOGIN_ENABLED` value. |
| redash.ldapSearchDn | string | REDASH_SEARCH_DN | `REDASH_LDAP_SEARCH_DN` value. |
| redash.ldapSearchTemplate | string | (cn=%(username)s) | `REDASH_LDAP_SEARCH_TEMPLATE` value. |
| redash.ldapUrl | string | None | `REDASH_LDAP_URL` value. |
| redash.limiterStorage | string | REDIS_URL | `REDASH_LIMITER_STORAGE` value. |
| redash.logLevel | string | INFO | `REDASH_LOG_LEVEL` value. |
| redash.mailAsciiAttachments | string | false | `REDASH_MAIL_ASCII_ATTACHMENTS` value. |
| redash.mailDefaultSender | string | None | `REDASH_MAIL_DEFAULT_SENDER` value. |
| redash.mailMaxEmails | string | None | `REDASH_MAIL_MAX_EMAILS` value. |
| redash.mailPassword | string | None | `REDASH_MAIL_PASSWORD` value. Stored as a Secret value. |
| redash.mailPort | string | 25 | `REDASH_MAIL_PORT` value. |
| redash.mailServer | string | localhost | `REDASH_MAIL_SERVER` value. |
| redash.mailUseSsl | string | false | `REDASH_MAIL_USE_SSL` value. |
| redash.mailUseTls | string | false | `REDASH_MAIL_USE_TLS` value. |
| redash.mailUsername | string | None | `REDASH_MAIL_USERNAME` value. |
| redash.multiOrg | string | false | `REDASH_MULTI_ORG` value. |
| redash.passwordLoginEnabled | string | true | `REDASH_PASSWORD_LOGIN_ENABLED` value. |
| redash.proxiesCount | string | 1 | `REDASH_PROXIES_COUNT` value. |
| redash.queryRefreshIntervals | string | 60, 300, 600, 900, 1800, 3600, 7200, 10800, 14400, 18000, 21600, 25200, 28800, 32400, 36000, 39600, 43200, 86400, 604800, 1209600, 2592000 | `REDASH_QUERY_REFRESH_INTERVALS` value. |
| redash.queryResultsCleanupCount | string | 100 | `REDASH_QUERY_RESULTS_CLEANUP_COUNT` value. |
| redash.queryResultsCleanupEnabled | string | true | `REDASH_QUERY_RESULTS_CLEANUP_ENABLED` value. |
| redash.queryResultsCleanupMaxAge | string | 7 | `REDASH_QUERY_RESULTS_CLEANUP_MAX_AGE` value. |
| redash.remoteUserHeader | string | X-Forwarded-Remote-User | `REDASH_REMOTE_USER_HEADER` value. |
| redash.remoteUserLoginEnabled | string | false | `REDASH_REMOTE_USER_LOGIN_ENABLED` value. |
| redash.samlEntityId | string | `""` | `REDASH_SAML_ENTITY_ID` value. |
| redash.samlMetadataUrl | string | `""` | `REDASH_SAML_METADATA_URL` value. |
| redash.samlNameidFormat | string | `""` | `REDASH_SAML_NAMEID_FORMAT` value. |
| redash.samlSchemeOverride | string | `""` | `REDASH_SAML_SCHEME_OVERRIDE` value. This setting will allow you to override the saml auth url scheme that gets constructed by flask. this is a useful feature if, for example, you're behind a proxy protocol enabled tcp load balancer (aws elb that terminates ssl) and your nginx proxy or similar adds a x-forwarded-proto of http even though your redash url for saml auth is https.. |
| redash.scheduledQueryTimeLimit | string | None | `REDASH_SCHEDULED_QUERY_TIME_LIMIT` value. Time limit for scheduled queries (in seconds). |
| redash.schemaRunTableSizeCalculations | string | false | `REDASH_SCHEMA_RUN_TABLE_SIZE_CALCULATIONS` value. |
| redash.schemasRefreshQueue | string | celery | `REDASH_SCHEMAS_REFRESH_QUEUE` value. The celery queue for refreshing the data source schemas. |
| redash.schemasRefreshSchedule | string | 30 | `REDASH_SCHEMAS_REFRESH_SCHEDULE` value. How often to refresh the data sources schemas (in minutes). |
| redash.secretKey | string | `""` |  |
| redash.sentryDsn | string | `""` | `REDASH_SENTRY_DSN` value. |
| redash.sqlAlchemyEnablePoolPrePing | string | true | `SQLALCHEMY_ENABLE_POOL_PRE_PING` value, controls whether the database connection that's in the pool will be checked by pinging before being used or not. See https://docs.sqlalchemy.org/en/13/core/pooling.html#sqlalchemy.pool.Pool.params.pre_ping |
| redash.staticAssetsPath | string | ”../client/dist/” | `REDASH_STATIC_ASSETS_PATH` value. |
| redash.statsdHost | string | 127.0.0.1 | `REDASH_STATSD_HOST` value. |
| redash.statsdPort | string | 8125 | `REDASH_STATSD_PORT` value. |
| redash.statsdPrefix | string | redash | `REDASH_STATSD_PREFIX` value. |
| redash.statsdUseTags | string | false | `REDASH_STATSD_USE_TAGS` value. Whether to use tags in statsd metrics (influxdb’s format). |
| redash.throttleLoginPattern | string | 50/hour | `REDASH_THROTTLE_LOGIN_PATTERN` value. |
| redash.versionCheck | string | true | `REDASH_VERSION_CHECK` value. |
| redash.webWorkers | string | 4 | `REDASH_WEB_WORKERS` value. How many processes will gunicorn spawn to handle web requests. |
| redis.cluster.enabled | bool | `false` |  |
| redis.databaseNumber | int | `0` | Enable Redis clustering (when redis chart enabled) |
| redis.enabled | bool | `true` | Whether to deploy a Redis server to satisfy the applications database requirements. To use an external Redis set this to false and configure the externalRedis parameter. |
| redis.master.port | int | `6379` | Redis master port to use (when redis chart enabled) |
| scheduledWorker.affinity | object | `{}` | Affinity for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| scheduledWorker.env | object | `{"QUEUES":"scheduled_queries,schemas","WORKERS_COUNT":1}` | Redash scheduled worker specific envrionment variables. |
| scheduledWorker.nodeSelector | object | `{}` | Node labels for scheduled worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| scheduledWorker.podAnnotations | object | `{}` | Annotations for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| scheduledWorker.podLabels | object | `{}` | Labels for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| scheduledWorker.podSecurityContext | object | `{}` | Security contexts for scheduled worker pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| scheduledWorker.replicaCount | int | `1` | Number of scheduled worker pods to run |
| scheduledWorker.resources | string | `nil` | Scheduled worker resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| scheduledWorker.securityContext | object | `{}` |  |
| scheduledWorker.tolerations | list | `[]` | Tolerations for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| scheduledWorker.volumeMounts | list | `[]` | VolumeMounts for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| scheduledWorker.volumes | list | `[]` | Volumes for scheduled pod  worker assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| scheduler.affinity | object | `{}` | Affinity for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| scheduler.env | object | `{}` | Redash scheduler specific envrionment variables. |
| scheduler.nodeSelector | object | `{}` | Node labels for scheduler pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| scheduler.podAnnotations | object | `{}` | Annotations for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| scheduler.podLabels | object | `{}` | Labels for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| scheduler.podSecurityContext | object | `{}` | Security contexts for scheduler pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| scheduler.replicaCount | int | `1` | Number of scheduler pods to run |
| scheduler.resources | string | `nil` | scheduler resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| scheduler.securityContext | object | `{}` |  |
| scheduler.tolerations | list | `[]` | Tolerations for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| scheduler.volumeMounts | list | `[]` | VolumeMounts for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| scheduler.volumes | list | `[]` | Volumes for scheduler pod  assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| server.affinity | object | `{}` | Affinity for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| server.env | object | `{}` | Redash server specific environment variables Don't use this for variables that are in the configuration above, however. |
| server.httpPort | int | `5000` | Server container port (only useful if you are using a customized image) |
| server.nodeSelector | object | `{}` | Node labels for server pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| server.podAnnotations | object | `{}` | Annotations for server pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| server.podLabels | object | `{}` | Labels for server pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| server.podSecurityContext | object | `{}` | Security contexts for server pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| server.replicaCount | int | `1` | Number of server pods to run |
| server.resources | object | `{}` | Server resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| server.securityContext | object | `{}` |  |
| server.tolerations | list | `[]` | Tolerations for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| server.volumeMounts | list | `[]` | VolumeMounts for server pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| server.volumes | list | `[]` | Volumes for server pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| service.annotations | object | `{}` | Annotations to add to the service |
| service.loadBalancerIP | string | `nil` | Specific IP address to use for cloud providers such as Azure Kubernetes Service [ref](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer) |
| service.port | int | `80` | Service external port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `nil` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |

## Upgrading

- See [the changelog](CHANGELOG.md) for major changes in each release
- The project will use the [semver specification](http://semver.org) for chart version numbers (chart versions will not match Redash versions, since we may need to update the chart more than once for the same Redash release)
- Always back up your database before upgrading!
- Schema migrations will be run automatically after each upgrade

To upgrade a release named `my-release`:

```bash
helm repo update
helm upgrade --reuse-values my-release redash/redash
```

Below are notes on manual configuration changes or steps needed for major chart version updates.

### From 2.x to 3.x

- The Redash version is updated from v8 to v10 (v9 never had a stable release)
- The upgrade should be automatic, but please test on a staging environment first!
- There are now additional "genericworker" and "scheduler" deployments, with associated configuration in values.yaml
- 3.x and higher will not run with Redash v8 - if you have overriden the image you will need to update that
- This chart now requires Kubernetes 1.19+
- Helm 2 is now depreciated and support will be removed in a future version

### From 1.x to 2.x

- There are 3 required secrets (see above) that must now be specified in your release
- The server.env is now depreciated (except for non-standard variables such as PYTHON_*) to allow for better management of Redash configuration and secret values - any existing configuration should be migrated to the new values

### From pre-release to 1.x

- The values.yaml structure has several changes
- The Redash, PostgreSQL and Redis versions have all been updated
- Due to these changes you will likely need to dump the database and reload it into a fresh install
- The chart now has it's own repo: https://getredash.github.io/contrib-helm-chart/

## License

This chart uses the [Apache 2 license](LICENSE).

## Contributing

Contributions [are welcome](CONTRIBUTING.md).
