# Redash

Redash is an open source tool built for teams to query, visualize and collaborate.

## Introduction

This chart bootstraps a [Redash](https://github.com/getredash/redash) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

This is a contributed project developed by volunteers and not officially supported by Redash.

Current chart version is `2.0.0-beta.1`

Source code can be found [here](https://redash.io/)

## Prerequisites

- At least 3 GB of RAM available on your cluster
- Kubernetes 1.15+ - chart is tested with latest 3 stable versions
- Helm 2 or 3
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`, add the chart repository:

```bash
$ helm repo add redash https://getredash.github.io/contrib-helm-chart/
```

Create a values file with required secrets (store this securely!):

```bash
$ cat > my-values.yaml <<- EOM
server:
  cookieSecret: $(openssl rand -base64 32)
  secretKey: $(openssl rand -base64 32)
postgresql:
  postgresqlPassword: $(openssl rand -base64 32)
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

## Chart Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://kubernetes-charts.storage.googleapis.com | postgresql | ^8.3.4 |
| https://kubernetes-charts.storage.googleapis.com | redis | ^10.5.3 |

## Configuration

The following table lists the configurable parameters of the Redash chart and their default values.

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| adhocWorker | object | `{"affinity":{},"env":{"QUEUES":"queries,celery","WORKERS_COUNT":2},"nodeSelector":{},"podSecurityContext":{},"replicaCount":1,"resources":null,"securityContext":{},"tolerations":[]}` | Configuration for Redash ad-hoc workers |
| adhocWorker.affinity | object | `{}` | Affinity for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| adhocWorker.env | object | `{"QUEUES":"queries,celery","WORKERS_COUNT":2}` | Redash ad-hoc worker specific envrionment variables. |
| adhocWorker.nodeSelector | object | `{}` | Node labels for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| adhocWorker.podSecurityContext | object | `{}` | Security contexts for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| adhocWorker.replicaCount | int | `1` | Number of ad-hoc worker pods to run |
| adhocWorker.resources | string | `nil` | Ad-hoc worker resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| adhocWorker.tolerations | list | `[]` | Tolerations for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| env | object | `{"PYTHONUNBUFFERED":0}` | Redash global envrionment variables - applied to both server and worker containers. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"redash/redash"` | Redash image name used for server and worker pods |
| image.tag | string | `"8.0.2.b37747"` | Redash image [tag](https://hub.docker.com/r/redash/redash/tags) |
| imagePullSecrets | list | `[]` | Name(s) of secrets to use if pulling images from a private registry |
| ingress.annotations | object | `{}` | Ingress annotations configuration |
| ingress.enabled | bool | `false` | Enable ingress controller resource |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[]}]` | Ingress resource hostnames and path mappings |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| nameOverride | string | `""` |  |
| postgresql | object | `{"enabled":true,"image":{"tag":"9.6.17-debian-10-r3"},"persistence":{"accessMode":"ReadWriteOnce","enabled":true,"size":"10Gi","storageClass":""},"postgresqlDatabase":"redash","postgresqlPassword":null,"postgresqlUsername":"redash","service":{"port":5432,"type":"ClusterIP"}}` | Configuration values for the postgresql dependency. This PostgreSQL instance is used by default for all Redash state storage [ref](https://github.com/kubernetes/charts/blob/master/stable/postgresql/README.md) |
| postgresql.enabled | bool | `true` | Whether to deploy a PostgreSQL server to satisfy the applications database requirements. To use an external PostgreSQL set this to false and configure the externalPostgreSQL parameter. |
| postgresql.image.tag | string | `"9.6.17-debian-10-r3"` | Bitnami supported version close to the one specified in Redash [setup docker-compose.yml](https://github.com/getredash/setup/blob/master/data/docker-compose.yml) |
| postgresql.persistence.accessMode | string | `"ReadWriteOnce"` | Use PostgreSQL volume as ReadOnly or ReadWrite |
| postgresql.persistence.enabled | bool | `true` | Use a PVC to persist PostgreSQL data (when postgresql chart enabled) |
| postgresql.persistence.size | string | `"10Gi"` | PVC Storage Request size for PostgreSQL volume |
| postgresql.postgresqlDatabase | string | `"redash"` | PostgreSQL database name (when postgresql chart enabled) |
| postgresql.postgresqlPassword | string | `nil` | REQUIRED: PostgreSQL password for redash user (when postgresql chart enabled) |
| postgresql.postgresqlUsername | string | `"redash"` | PostgreSQL username for redash user (when postgresql chart enabled) |
| redis | object | `{"cluster":{"enabled":false},"databaseNumber":0,"enabled":true,"master":{"port":6379}}` | Configuration values for the redis dependency. This Redis instance is used by default for caching and temporary storage [ref](https://github.com/kubernetes/charts/blob/master/stable/redis/README.md) |
| redis.databaseNumber | int | `0` | Enable Redis clustering (when redis chart enabled) |
| redis.enabled | bool | `true` | Whether to deploy a Redis server to satisfy the applications database requirements. To use an external Redis set this to false and configure the externalRedis parameter. |
| redis.master.port | int | `6379` | Redis master port to use (when redis chart enabled) |
| scheduledWorker | object | `{"affinity":{},"env":{"QUEUES":"scheduled_queries","WORKERS_COUNT":2},"nodeSelector":{},"podSecurityContext":{},"replicaCount":1,"resources":null,"securityContext":{},"tolerations":[]}` | Configuration for Redash scheduled workers |
| scheduledWorker.affinity | object | `{}` | Affinity for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| scheduledWorker.env | object | `{"QUEUES":"scheduled_queries","WORKERS_COUNT":2}` | Redash scheduled worker specific envrionment variables. |
| scheduledWorker.nodeSelector | object | `{}` | Node labels for scheduled worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| scheduledWorker.podSecurityContext | object | `{}` | Security contexts for scheduled worker pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| scheduledWorker.replicaCount | int | `1` | Number of scheduled worker pods to run |
| scheduledWorker.resources | string | `nil` | Scheduled worker resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| scheduledWorker.tolerations | list | `[]` | Tolerations for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| server.additionalDestinations | string | `nil` | `REDASH_ADDITIONAL_DESTINATIONS` value. Defaults to ``. |
| server.additionalQueryRunners | string | `nil` | `REDASH_ADDITIONAL_QUERY_RUNNERS` value. Defaults to ``. |
| server.adhocQueryTimeLimit | string | `nil` | `REDASH_ADHOC_QUERY_TIME_LIMIT` value. Defaults to `None`. |
| server.affinity | object | `{}` | Affinity for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| server.alertsDefaultMailSubjectTemplate | string | `nil` | `REDASH_ALERTS_DEFAULT_MAIL_SUBJECT_TEMPLATE` value. Defaults to `({state}) {alert_name}`. |
| server.allowScriptsInUserInput | string | `nil` | `REDASH_ALLOW_SCRIPTS_IN_USER_INPUT` value. Defaults to `false`. Disable sanitization of text input, allowing full html. |
| server.authType | string | `nil` | `REDASH_AUTH_TYPE` value. Defaults to `api_key`. |
| server.bigqueryHttpTimeout | string | `nil` | `REDASH_BIGQUERY_HTTP_TIMEOUT` value. Defaults to `600`. |
| server.celeryBackend | string | `nil` | `REDASH_CELERY_BACKEND` value. Defaults to `CELERY_BROKER`. |
| server.celeryBroker | string | `nil` | `REDASH_CELERY_BROKER` value. Defaults to `REDIS_URL`. |
| server.celeryTaskResultExpires | string | `nil` | `REDASH_CELERY_TASK_RESULT_EXPIRES` value. Defaults to `3600 \* 4`. How many seconds to keep celery task results in cache (in seconds). |
| server.cookieSecret | string | `nil` | REQUIRED `REDASH_COOKIE_SECRET` value. Defaults to ``. Stored as a Secret value. |
| server.corsAccessControlAllowCredentials | string | `nil` | `REDASH_CORS_ACCESS_CONTROL_ALLOW_CREDENTIALS` value. Defaults to `false`. |
| server.corsAccessControlAllowHeaders | string | `nil` | `REDASH_CORS_ACCESS_CONTROL_ALLOW_HEADERS` value. Defaults to `Content-Type`. |
| server.corsAccessControlAllowOrigin | string | `nil` | `REDASH_CORS_ACCESS_CONTROL_ALLOW_ORIGIN` value. Defaults to ``. |
| server.corsAccessControlRequestMethod | string | `nil` | `REDASH_CORS_ACCESS_CONTROL_REQUEST_METHOD` value. Defaults to `GET, POST, PUT`. |
| server.dashboardRefreshIntervals | string | `nil` | `REDASH_DASHBOARD_REFRESH_INTERVALS` value. Defaults to `60,300,600,1800,3600,43200,86400`. |
| server.dateFormat | string | `nil` | `REDASH_DATE_FORMAT` value. Defaults to `DD/MM/YY`. |
| server.disabledQueryRunners | string | `nil` | `REDASH_DISABLED_QUERY_RUNNERS` value. Defaults to ``. |
| server.enabledDestinations | string | `nil` | `REDASH_ENABLED_DESTINATIONS` value. Defaults to `”,”.join(default_destinations)`. |
| server.enabledQueryRunners | string | `nil` | `REDASH_ENABLED_QUERY_RUNNERS` value. Defaults to `”,”.join(default_query_runners)`. |
| server.enforceHttps | string | `nil` | `REDASH_ENFORCE_HTTPS` value. Defaults to `false`. |
| server.env | object | `{}` | Redash server specific envrionment variables |
| server.eventReportingWebhooks | string | `nil` | `REDASH_EVENT_REPORTING_WEBHOOKS` value. Defaults to ``. |
| server.featureAllowCustomJsVisualizations | string | `nil` | `REDASH_FEATURE_ALLOW_CUSTOM_JS_VISUALIZATIONS` value. Defaults to `false`. |
| server.featureAutoPublishNamedQueries | string | `nil` | `REDASH_FEATURE_AUTO_PUBLISH_NAMED_QUERIES` value. Defaults to `true`. |
| server.featureDisableRefreshQueries | string | `nil` | `REDASH_FEATURE_DISABLE_REFRESH_QUERIES` value. Defaults to `false`. Disable scheduled query execution. |
| server.featureDumbRecents | string | `nil` | `REDASH_FEATURE_DUMB_RECENTS` value. Defaults to `false`. |
| server.featureShowPermissionsControl | string | `nil` | `REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL` value. Defaults to `false`. |
| server.featureShowQueryResultsCount | string | `nil` | `REDASH_FEATURE_SHOW_QUERY_RESULTS_COUNT` value. Defaults to `true`. Disable/enable showing count of query results in status. |
| server.googleClientId | string | `nil` | `REDASH_GOOGLE_CLIENT_ID` value. Defaults to ``. |
| server.googleClientSecret | string | `nil` | `REDASH_GOOGLE_CLIENT_SECRET` value. Defaults to ``. Stored as a Secret value. |
| server.host | string | `nil` | `REDASH_HOST` value. Defaults to ``. |
| server.httpPort | int | `5000` | Server container port (only useful if you are using a customized image) |
| server.invitationTokenMaxAge | string | `nil` | `REDASH_INVITATION_TOKEN_MAX_AGE` value. Defaults to `60 _ 60 _ 24 \* 7`. |
| server.jobExpiryTime | string | `nil` | `REDASH_JOB_EXPIRY_TIME` value. Defaults to `3600 \* 12`. |
| server.jwtAuthAlgorithms | string | `nil` | `REDASH_JWT_AUTH_ALGORITHMS` value. Defaults to `HS256,RS256,ES256`. |
| server.jwtAuthAudience | string | `nil` | `REDASH_JWT_AUTH_AUDIENCE` value. Defaults to ``. |
| server.jwtAuthCookieName | string | `nil` | `REDASH_JWT_AUTH_COOKIE_NAME` value. Defaults to ``. |
| server.jwtAuthHeaderName | string | `nil` | `REDASH_JWT_AUTH_HEADER_NAME` value. Defaults to ``. |
| server.jwtAuthIssuer | string | `nil` | `REDASH_JWT_AUTH_ISSUER` value. Defaults to ``. |
| server.jwtAuthPublicCertsUrl | string | `nil` | `REDASH_JWT_AUTH_PUBLIC_CERTS_URL` value. Defaults to ``. |
| server.jwtLoginEnabled | string | `nil` | `REDASH_JWT_LOGIN_ENABLED` value. Defaults to `false`. |
| server.ldapBindDn | string | `nil` | `REDASH_LDAP_BIND_DN` value. Defaults to `None`. |
| server.ldapBindDnPassword | string | `nil` | `REDASH_LDAP_BIND_DN_PASSWORD` value. Defaults to ``. Stored as a Secret value. |
| server.ldapCustomUsernamePrompt | string | `nil` | `REDASH_LDAP_CUSTOM_USERNAME_PROMPT` value. Defaults to `LDAP/AD/SSO username:`. |
| server.ldapDisplayNameKey | string | `nil` | `REDASH_LDAP_DISPLAY_NAME_KEY` value. Defaults to `displayName`. |
| server.ldapEmailKey | string | `nil` | `REDASH_LDAP_EMAIL_KEY` value. Defaults to `mail`. |
| server.ldapLoginEnabled | string | `nil` | `REDASH_LDAP_LOGIN_ENABLED` value. Defaults to `false`. |
| server.ldapSearchDn | string | `nil` | `REDASH_LDAP_SEARCH_DN` value. Defaults to `REDASH_SEARCH_DN`. |
| server.ldapSearchTemplate | string | `nil` | `REDASH_LDAP_SEARCH_TEMPLATE` value. Defaults to `(cn=%(username)s)`. |
| server.ldapUrl | string | `nil` | `REDASH_LDAP_URL` value. Defaults to `None`. |
| server.limiterStorage | string | `nil` | `REDASH_LIMITER_STORAGE` value. Defaults to `REDIS_URL`. |
| server.logLevel | string | `nil` | `REDASH_LOG_LEVEL` value. Defaults to `INFO`. |
| server.mailAsciiAttachments | string | `nil` | `REDASH_MAIL_ASCII_ATTACHMENTS` value. Defaults to `false`. |
| server.mailDefaultSender | string | `nil` | `REDASH_MAIL_DEFAULT_SENDER` value. Defaults to `None`. |
| server.mailMaxEmails | string | `nil` | `REDASH_MAIL_MAX_EMAILS` value. Defaults to `None`. |
| server.mailPassword | string | `nil` | `REDASH_MAIL_PASSWORD` value. Defaults to `None`. Stored as a Secret value. |
| server.mailPort | string | `nil` | `REDASH_MAIL_PORT` value. Defaults to `25`. |
| server.mailServer | string | `nil` | `REDASH_MAIL_SERVER` value. Defaults to `localhost`. |
| server.mailUseSsl | string | `nil` | `REDASH_MAIL_USE_SSL` value. Defaults to `false`. |
| server.mailUseTls | string | `nil` | `REDASH_MAIL_USE_TLS` value. Defaults to `false`. |
| server.mailUsername | string | `nil` | `REDASH_MAIL_USERNAME` value. Defaults to `None`. |
| server.multiOrg | string | `nil` | `REDASH_MULTI_ORG` value. Defaults to `false`. |
| server.nodeSelector | object | `{}` | Node labels for server pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| server.passwordLoginEnabled | string | `nil` | `REDASH_PASSWORD_LOGIN_ENABLED` value. Defaults to `true`. |
| server.podSecurityContext | object | `{}` | Security contexts for server pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| server.proxiesCount | string | `nil` | `REDASH_PROXIES_COUNT` value. Defaults to `1`. |
| server.queryRefreshIntervals | string | `nil` | `REDASH_QUERY_REFRESH_INTERVALS` value. Defaults to `60, 300, 600, 900, 1800, 3600, 7200, 10800, 14400, 18000, 21600, 25200, 28800, 32400, 36000, 39600, 43200, 86400, 604800, 1209600, 2592000`. |
| server.queryResultsCleanupCount | string | `nil` | `REDASH_QUERY_RESULTS_CLEANUP_COUNT` value. Defaults to `100`. |
| server.queryResultsCleanupEnabled | string | `nil` | `REDASH_QUERY_RESULTS_CLEANUP_ENABLED` value. Defaults to `true`. |
| server.queryResultsCleanupMaxAge | string | `nil` | `REDASH_QUERY_RESULTS_CLEANUP_MAX_AGE` value. Defaults to `7`. |
| server.remoteUserHeader | string | `nil` | `REDASH_REMOTE_USER_HEADER` value. Defaults to `X-Forwarded-Remote-User`. |
| server.remoteUserLoginEnabled | string | `nil` | `REDASH_REMOTE_USER_LOGIN_ENABLED` value. Defaults to `false`. |
| server.replicaCount | int | `1` | Number of server pods to run |
| server.resources | string | `nil` | Server resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| server.samlEntityId | string | `nil` | `REDASH_SAML_ENTITY_ID` value. Defaults to ``. |
| server.samlMetadataUrl | string | `nil` | `REDASH_SAML_METADATA_URL` value. Defaults to ``. |
| server.samlNameidFormat | string | `nil` | `REDASH_SAML_NAMEID_FORMAT` value. Defaults to ``. |
| server.schemaRunTableSizeCalculations | string | `nil` | `REDASH_SCHEMA_RUN_TABLE_SIZE_CALCULATIONS` value. Defaults to `false`. |
| server.schemasRefreshQueue | string | `nil` | `REDASH_SCHEMAS_REFRESH_QUEUE` value. Defaults to `celery`. The celery queue for refreshing the data source schemas. |
| server.schemasRefreshSchedule | string | `nil` | `REDASH_SCHEMAS_REFRESH_SCHEDULE` value. Defaults to `30`. How often to refresh the data sources schemas (in minutes). |
| server.secretKey | string | `nil` | REQUIRED `REDASH_SECRET_KEY` value. Defaults to ``. Secret key used for data encryption. Stored as a Secret value. |
| server.securityContext | object | `{}` |  |
| server.sentryDsn | string | `nil` | `REDASH_SENTRY_DSN` value. Defaults to ``. |
| server.staticAssetsPath | string | `nil` | `REDASH_STATIC_ASSETS_PATH` value. Defaults to `”../client/dist/”`. |
| server.statsdHost | string | `nil` | `REDASH_STATSD_HOST` value. Defaults to `127.0.0.1`. |
| server.statsdPort | string | `nil` | `REDASH_STATSD_PORT` value. Defaults to `8125`. |
| server.statsdPrefix | string | `nil` | `REDASH_STATSD_PREFIX` value. Defaults to `redash`. |
| server.statsdUseTags | string | `nil` | `REDASH_STATSD_USE_TAGS` value. Defaults to `false`. Whether to use tags in statsd metrics (influxdb’s format). |
| server.throttleLoginPattern | string | `nil` | `REDASH_THROTTLE_LOGIN_PATTERN` value. Defaults to `50/hour`. |
| server.tolerations | list | `[]` | Tolerations for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| server.versionCheck | string | `nil` | `REDASH_VERSION_CHECK` value. Defaults to `true`. |
| server.webWorkers | string | `nil` | `REDASH_WEB_WORKERS` value. Defaults to `4`. How many processes will gunicorn spawn to handle web requests. |
| service.port | int | `80` | Service external port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount | object | `{"annotations":{},"create":true,"name":null}` | Service account and security context configuration |
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
