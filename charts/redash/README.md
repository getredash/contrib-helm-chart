# Redash

Redash is an open source tool built for teams to query, visualize and collaborate.

## Introduction

This chart bootstraps a [Redash](https://github.com/getredash/redash) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

This is a contributed project developed by volunteers and not officially supported by Redash.

Current chart version is `5.0.0`

* <https://github.com/getredash/redash>

## Prerequisites

- At least 3 GB of RAM available on your cluster
- Kubernetes 1.31+ - chart is tested with latest 6 stable versions (1.31-1.36)
- Helm 3.14+ (for `helm upgrade --reset-then-reuse-values`; Helm 2 is not supported)
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
  auth:
    password: $(openssl rand -base64 32)
redis:
  auth:
    password: $(openssl rand -base64 32)
EOM
```

Install the chart:

```bash
$ helm upgrade --install -f my-values.yaml my-release redash/redash
```

The command deploys Redash on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section and default [values.yaml](values.yaml) lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Knative Serving

Set `server.knative.enabled=true` to render the Redash web server as a Knative Service instead of a Kubernetes Deployment. Workers, scheduler, migrations, PostgreSQL, and Redis still render as standard Kubernetes resources.

When Knative mode is enabled, the chart-managed `ingress` and `service` resources are skipped and Knative handles routing instead. Configure autoscaling through `server.knative.annotations`, including `autoscaling.knative.dev/*` keys such as `min-scale` and `max-scale`, and set revision fields such as `containerConcurrency` or `timeoutSeconds` through `server.knative.spec`.

Knative mode requires Knative Serving to be available on the target cluster. Some server pod settings use Knative feature-gated PodSpec fields, such as `server.initContainers`, `server.nodeSelector`, `server.affinity`, `server.tolerations`, `server.priorityClassName`, `server.podSecurityContext`, `server.topologySpreadConstraints`, and some `server.volumes` values. Enable the corresponding Knative `config-features` flags before setting those values; otherwise Knative admission rejects the Service and `helm install/upgrade` fails.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Redash chart and their default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterDomain | string | `"cluster.local"` | Kubernetes cluster domain, used to build in-cluster hostnames |
| commonLabels | object | `{}` |  |
| env | object | `{"PYTHONUNBUFFERED":0,"REDASH_PRODUCTION":"true"}` | Redash global environment variables - applied to both server and worker containers. |
| externalPostgreSQL | string | `nil` | External PostgreSQL configuration. To use an external PostgreSQL instead of the bundled PostgreSQL server: set postgresql.enabled to false then uncomment and configure the externalPostgreSQL connection URL (e.g. postgresql://user:pass@host:5432/database) |
| externalPostgreSQLSecret | object | `{}` | Read external PostgreSQL configuration from a secret. This should point at a secret file with a single key which specifies the connection string. |
| externalRedis | string | `nil` | External Redis configuration. To use an external Redis instead of the bundled Redis server: set redis.enabled to false then uncomment and configure the externalRedis connection URL (e.g. redis://user:pass@host:6379/database). |
| externalRedisSecret | object | `{}` | Read external Redis configuration from a secret. This should point at a secret file with a single key which specifies the connection string. |
| extraObjects | list | `[]` | Additional kubernetes manifests to deploy alongside the chart. Useful to include external secrets for dependencies. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `"docker.io"` |  |
| image.repo | string | `"redash/redash"` | Redash image name used for server and worker pods |
| image.tag | string | `nil` | Redash image [tag](https://hub.docker.com/r/redash/redash/tags) |
| imagePullSecrets | list | `[]` | Name(s) of secrets to use if pulling images from a private registry |
| ingress.annotations | object | `{}` | Ingress annotations configuration |
| ingress.enabled | bool | `false` | Enable ingress controller resource |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[]}]` | Ingress resource hostnames and path mappings |
| ingress.ingressClassName | string | `""` | Sets the ingress controller class name to use. |
| ingress.pathType | string | `"Prefix"` | How ingress paths should be treated. |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| initContainers | list | `[]` | Redash global init containers |
| migrations.affinity | object | `{}` | Affinity for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| migrations.initContainers | list | `[]` | migrations init container configuration |
| migrations.nodeSelector | object | `{}` | Node labels for scheduled worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| migrations.podAnnotations | object | `{}` | Annotations for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| migrations.podLabels | object | `{}` | Labels for migration pod [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| migrations.podSecurityContext | object | `{}` | Security contexts for scheduled worker pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| migrations.priorityClassName | string | `nil` |  |
| migrations.resources | string | `nil` | Scheduled worker resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| migrations.securityContext | object | `{}` |  |
| migrations.tolerations | list | `[]` | Tolerations for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| migrations.topologySpreadConstraints | list | `[]` | Topology spread constraints for migrations pod assignment [ref](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) |
| migrations.ttlSecondsAfterFinished | int | `600` | ttl for install job [ref](https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/) |
| migrations.volumeMounts | list | `[]` | volume mounts for migrations pods |
| migrations.volumes | list | `[]` | volumes that will be mounted to migrations pods only |
| nameOverride | string | `""` |  |
| postgresql.affinity | object | `{}` | Affinity for PostgreSQL pod assignment |
| postgresql.auth.database | string | `"redash"` | PostgreSQL database name (when postgresql is enabled) |
| postgresql.auth.existingSecret | string | `""` | Name of an existing secret holding the PostgreSQL password. Takes precedence over postgresql.auth.password, and is read by both PostgreSQL and Redash. |
| postgresql.auth.password | string | `nil` | REQUIRED: PostgreSQL password for redash user (when postgresql is enabled). PostgreSQL only applies it when it initialises an empty data directory; to change it later, run `ALTER USER <username> PASSWORD '<new>'` in the database first, then update this value. |
| postgresql.auth.secretKeys.userPasswordKey | string | `"password"` | Key inside postgresql.auth.existingSecret holding the redash user password |
| postgresql.auth.username | string | `"redash"` | PostgreSQL username for redash user (when postgresql is enabled). The official image makes this user the database superuser. |
| postgresql.enabled | bool | `true` | Whether to deploy a PostgreSQL server to satisfy the applications database requirements. To use an external PostgreSQL set this to false and configure the externalPostgreSQL parameter. |
| postgresql.image.pullPolicy | string | `"IfNotPresent"` | PostgreSQL image pull policy |
| postgresql.image.registry | string | `"docker.io"` |  |
| postgresql.image.repo | string | `"library/postgres"` | PostgreSQL image name [ref](https://hub.docker.com/_/postgres) |
| postgresql.image.tag | string | `"18.6"` | PostgreSQL image tag. Keep the major version unless you migrate the data yourself. |
| postgresql.nodeSelector | object | `{}` | Node labels for PostgreSQL pod assignment |
| postgresql.persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes of the created PersistentVolumeClaim |
| postgresql.persistence.enabled | bool | `true` | Store PostgreSQL data on a PersistentVolumeClaim. When false, data lives in an emptyDir and is lost with the pod. |
| postgresql.persistence.existingClaim | string | `""` | Use an existing PersistentVolumeClaim instead of creating one |
| postgresql.persistence.size | string | `"8Gi"` | Size of the created PersistentVolumeClaim |
| postgresql.persistence.storageClass | string | `nil` | Storage class of the created PersistentVolumeClaim. Unset uses the cluster default; "-" sets an empty storageClassName. |
| postgresql.podAnnotations | object | `{}` | Annotations for the PostgreSQL pod |
| postgresql.podLabels | object | `{}` | Labels for the PostgreSQL pod |
| postgresql.podSecurityContext | object | `{"fsGroup":999,"runAsGroup":999,"runAsNonRoot":true,"runAsUser":999,"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for the PostgreSQL pod. 999 is the postgres user of the official image. |
| postgresql.priorityClassName | string | `nil` | Priority class name for the PostgreSQL pod |
| postgresql.resources | object | `{}` | PostgreSQL resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| postgresql.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}` | Security context for the PostgreSQL container |
| postgresql.service.port | int | `5432` | PostgreSQL service port |
| postgresql.tolerations | list | `[]` | Tolerations for PostgreSQL pod assignment |
| redash.additionalDestinations | string | `""` | `REDASH_ADDITIONAL_DESTINATIONS` value. Comma-separated list of non-default alert destinations to be enabled. |
| redash.additionalQueryRunners | string | `""` | `REDASH_ADDITIONAL_QUERY_RUNNERS` value. Comma-separated list of non-default query runners to be enabled. |
| redash.adhocQueryTimeLimit | string | None | `REDASH_ADHOC_QUERY_TIME_LIMIT` value. Time limit for adhoc queries (in seconds). |
| redash.alertsDefaultMailSubjectTemplate | string | ({state}) {alert_name} | `REDASH_ALERTS_DEFAULT_MAIL_SUBJECT_TEMPLATE` value. Subject used for email alert notifications. `{state}` and `{alert_name}` are the only available variables.. |
| redash.allowScriptsInUserInput | string | false | `REDASH_ALLOW_SCRIPTS_IN_USER_INPUT` value. Disable sanitization of text input, allowing full html. |
| redash.authType | string | api_key | `REDASH_AUTH_TYPE` value. May be either `api_key` or `hmac`. implemented [here](https://github.com/getredash/redash/pull/385). |
| redash.bigqueryHttpTimeout | string | 600 | `REDASH_BIGQUERY_HTTP_TIMEOUT` value. Http timeout for the bigquery query runner. |
| redash.blockedDomains | string | "qq.com" | `REDASH_BLOCKED_DOMAINS` value. Comma separated of email domains that cannot create user accounts. |
| redash.cookieSecret | string | `"test"` | REQUIRED `REDASH_COOKIE_SECRET` value. Required. used for various cryptographic features of the web server. read more about how redash uses secret keys [here]({% link _kb/open-source/admin-guide/secrets.md %}). Stored as a Secret value. |
| redash.corsAccessControlAllowCredentials | string | false | `REDASH_CORS_ACCESS_CONTROL_ALLOW_CREDENTIALS` value. |
| redash.corsAccessControlAllowHeaders | string | Content-Type | `REDASH_CORS_ACCESS_CONTROL_ALLOW_HEADERS` value. |
| redash.corsAccessControlAllowOrigin | string | `""` | `REDASH_CORS_ACCESS_CONTROL_ALLOW_ORIGIN` value. |
| redash.corsAccessControlRequestMethod | string | GET, POST, PUT | `REDASH_CORS_ACCESS_CONTROL_REQUEST_METHOD` value. |
| redash.dashboardRefreshIntervals | string | 60,300,600,1800,3600,43200,86400 | `REDASH_DASHBOARD_REFRESH_INTERVALS` value. Comma-separated list of integer seconds that will be allowed for dashboard refresh. |
| redash.dateFormat | string | DD/MM/YY | `REDASH_DATE_FORMAT` value. Moment.js format to be used throughout the web application. |
| redash.disablePublicUrls | string | "false" | `REDASH_DISABLE_PUBLIC_URLS` value. Whether to disable access to public urls. |
| redash.disabledQueryRunners | string | `""` | `REDASH_DISABLED_QUERY_RUNNERS` value. Comma-separated list of query runners that will not appear in redash. |
| redash.enabledDestinations | string | ”,”.join(default_destinations) | `REDASH_ENABLED_DESTINATIONS` value. Comma-separated list of alert destinations to be enabled (e.g. `redash.destinations.email,redash.destinations.slack` ). |
| redash.enabledQueryRunners | string | ”,”.join(default_query_runners) | `REDASH_ENABLED_QUERY_RUNNERS` value. Comma-separated list of query runners to be enabled (e.g. `redash.query_runner.pg,redash.query_runner.mysql`). |
| redash.enforceHttps | string | false | `REDASH_ENFORCE_HTTPS` value. This is passed to [flask-talisman](https://github.com/googlecloudplatform/flask-talisman). |
| redash.eventReportingWebhooks | string | `""` | `REDASH_EVENT_REPORTING_WEBHOOKS` value. Comma-separated list of webhook urls that to which events will be forwarded. |
| redash.featureAllowCustomJsVisualizations | string | false | `REDASH_FEATURE_ALLOW_CUSTOM_JS_VISUALIZATIONS` value. Enable the custom visualization option. this appears as a sub-type of "chart" visualizations in the ui.. |
| redash.featureAutoPublishNamedQueries | string | true | `REDASH_FEATURE_AUTO_PUBLISH_NAMED_QUERIES` value. Automatically publish a new query after its name is changed from "new query". |
| redash.featureDisableRefreshQueries | string | false | `REDASH_FEATURE_DISABLE_REFRESH_QUERIES` value. Disable scheduled query execution. |
| redash.featureShowPermissionsControl | string | false | `REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL` value. Enable experimental multiple owners support. |
| redash.featureShowQueryResultsCount | string | true | `REDASH_FEATURE_SHOW_QUERY_RESULTS_COUNT` value. Disable/enable showing count of query results in status. |
| redash.googleClientId | string | `""` | `REDASH_GOOGLE_CLIENT_ID` value. The client id to use for google login, be sure to set a client secret as well. |
| redash.googleClientSecret | string | `""` | `REDASH_GOOGLE_CLIENT_SECRET` value. The client secret to use for google login, be sure to set a client id as well. Stored as a Secret value. |
| redash.host | string | `""` | `REDASH_HOST` value. The url host used in emails sent to users (invites, alerts, notifications) etc.. |
| redash.invitationTokenMaxAge | string | 60 _ 60 _ 24 \* 7 | `REDASH_INVITATION_TOKEN_MAX_AGE` value. An integer number of seconds after which an invitation link will expire. |
| redash.jobExpiryTime | string | 3600 \* 12 | `REDASH_JOB_EXPIRY_TIME` value. Ttl in seconds for jobs placed in queue. if a job is not picked up by a worker within this ttl it will expire.. |
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
| redash.limiterStorage | string | REDIS_URL | `REDASH_LIMITER_STORAGE` value. Mapped directly to flask-limiter's [storage_uri](https://flask-limiter.readthedocs.io/en/stable/configuration.html?highlight=limiter_storage#ratelimit_storage_uri).. |
| redash.logLevel | string | INFO | `REDASH_LOG_LEVEL` value. Logging messages which are less severe than level will be ignored. read more about python logging [here](https://docs.python.org/3/library/logging.html). |
| redash.mailAsciiAttachments | string | false | `REDASH_MAIL_ASCII_ATTACHMENTS` value. |
| redash.mailDefaultSender | string | None | `REDASH_MAIL_DEFAULT_SENDER` value. |
| redash.mailMaxEmails | string | None | `REDASH_MAIL_MAX_EMAILS` value. |
| redash.mailPassword | string | None | `REDASH_MAIL_PASSWORD` value. Stored as a Secret value. |
| redash.mailPort | string | 25 | `REDASH_MAIL_PORT` value. |
| redash.mailServer | string | localhost | `REDASH_MAIL_SERVER` value. |
| redash.mailUseSsl | string | false | `REDASH_MAIL_USE_SSL` value. |
| redash.mailUseTls | string | false | `REDASH_MAIL_USE_TLS` value. |
| redash.mailUsername | string | None | `REDASH_MAIL_USERNAME` value. |
| redash.multiOrg | string | false | `REDASH_MULTI_ORG` value. Whether to enable multi-org mode. **note**: multi-org mode is not documented or supported at this time. |
| redash.passwordLoginEnabled | string | true | `REDASH_PASSWORD_LOGIN_ENABLED` value. Toggle to allow password login. often disabled if google login, saml, ldap, or remote_user_login are enabled.. |
| redash.proxiesCount | string | 1 | `REDASH_PROXIES_COUNT` value. Passed to werkzeug's [proxyfix](https://werkzeug.palletsprojects.com/en/2.1.x/middleware/proxy_fix/) to make sure we get the right referral address even behind proxies like nginx.. |
| redash.queryRefreshIntervals | string | 60, 300, 600, 900, 1800, 3600, 7200, 10800, 14400, 18000, 21600, 25200, 28800, 32400, 36000, 39600, 43200, 86400, 604800, 1209600, 2592000 | `REDASH_QUERY_REFRESH_INTERVALS` value. Comma-separated list of integer seconds that will be allowed for scheduled query refresh. |
| redash.queryResultsCleanupCount | string | 100 | `REDASH_QUERY_RESULTS_CLEANUP_COUNT` value. The number of results to cleanup during each call to `cleanup_query_results`. |
| redash.queryResultsCleanupEnabled | string | true | `REDASH_QUERY_RESULTS_CLEANUP_ENABLED` value. Whether the job to cleanup unused query results should run automatically. |
| redash.queryResultsCleanupMaxAge | string | 7 | `REDASH_QUERY_RESULTS_CLEANUP_MAX_AGE` value. Integer number of days, past which a query result may be cleaned up if it is not referenced by another query.. |
| redash.remoteUserHeader | string | X-Forwarded-Remote-User | `REDASH_REMOTE_USER_HEADER` value. Name of header to use if `redash_remote_user_login_enabled` is true. |
| redash.remoteUserLoginEnabled | string | false | `REDASH_REMOTE_USER_LOGIN_ENABLED` value. Enables the use of an externally-provided and trusted remote user via an http header. the "user" must be an email address. [more details](https://github.com/getredash/redash/blob/e6ebef1e5ab866ce1e706eaee6260edaffdc2bd7/redash/settings/__init__.py#l185-l207). |
| redash.samlEntityId | string | `""` | `REDASH_SAML_ENTITY_ID` value. |
| redash.samlMetadataUrl | string | `""` | `REDASH_SAML_METADATA_URL` value. |
| redash.samlNameidFormat | string | `""` | `REDASH_SAML_NAMEID_FORMAT` value. |
| redash.samlSchemeOverride | string | `""` | `REDASH_SAML_SCHEME_OVERRIDE` value. This setting will allow you to override the saml auth url scheme that gets constructed by flask. this is a useful feature if, for example, you're behind a proxy protocol enabled tcp load balancer (aws elb that terminates ssl) and your nginx proxy or similar adds a x-forwarded-proto of http even though your redash url for saml auth is https.. |
| redash.scheduledQueryTimeLimit | string | None | `REDASH_SCHEDULED_QUERY_TIME_LIMIT` value. Time limit for scheduled queries (in seconds). |
| redash.schemaRunTableSizeCalculations | string | false | `REDASH_SCHEMA_RUN_TABLE_SIZE_CALCULATIONS` value. Enable showing the size of each table in the schema browser.. |
| redash.schemasRefreshSchedule | string | 30 | `REDASH_SCHEMAS_REFRESH_SCHEDULE` value. How often to refresh the data source schemas (in minutes). |
| redash.secretKey | string | `"test"` | REQUIRED `REDASH_SECRET_KEY` value. Secret key used for data encryption. Stored as a Secret value. |
| redash.selfManagedSecrets | bool | `false` | disables all chart managed secrets providing an ability to set them using redash.envSecretName. Useful, while using together with external secrets |
| redash.sentryDsn | string | `""` | `REDASH_SENTRY_DSN` value. |
| redash.sqlAlchemyEnablePoolPrePing | string | true | `SQLALCHEMY_ENABLE_POOL_PRE_PING` value, controls whether the database connection that's in the pool will be checked by pinging before being used or not. See https://docs.sqlalchemy.org/en/13/core/pooling.html#sqlalchemy.pool.Pool.params.pre_ping |
| redash.staticAssetsPath | string | ”../client/dist/” | `REDASH_STATIC_ASSETS_PATH` value. Directory that contains all front-end assets. relative to the ./redash directory. |
| redash.statsdHost | string | 127.0.0.1 | `REDASH_STATSD_HOST` value. Host for statsd daemon. |
| redash.statsdPort | string | 8125 | `REDASH_STATSD_PORT` value. Port for statsd daemon. |
| redash.statsdPrefix | string | redash | `REDASH_STATSD_PREFIX` value. Prefix for metrics sent to statsd daemon. |
| redash.statsdUseTags | string | false | `REDASH_STATSD_USE_TAGS` value. Whether to use tags in statsd metrics (influxdb’s format). |
| redash.throttleLoginPattern | string | 50/hour | `REDASH_THROTTLE_LOGIN_PATTERN` value. The [flask-limiter](https://flask-limiter.readthedocs.io/en/stable/) string pattern used to rate limit requests to the /login route.. |
| redash.versionCheck | string | true | `REDASH_VERSION_CHECK` value. Toggle whether to periodically check if a newer version of redash is available.. |
| redash.webWorkers | string | 4 | `REDASH_WEB_WORKERS` value. How many processes will gunicorn spawn to handle web requests. |
| redis.affinity | object | `{}` | Affinity for Redis pod assignment |
| redis.auth.existingSecret | string | `""` | Name of an existing secret holding the Redis password. Takes precedence over redis.auth.password. |
| redis.auth.existingSecretPasswordKey | string | `"redis-password"` | Key inside redis.auth.existingSecret holding the Redis password |
| redis.auth.password | string | `""` | Redis password. When empty, the chart generates one and keeps it across upgrades. Set it explicitly when rendering with `helm template` (e.g. Argo CD, Flux), which cannot look up the existing one. |
| redis.database | int | `0` | Redis database number used by Redash |
| redis.enabled | bool | `true` | Whether to deploy a Redis server to satisfy the applications database requirements. To use an external Redis set this to false and configure the externalRedis parameter. |
| redis.image.pullPolicy | string | `"IfNotPresent"` | Redis image pull policy |
| redis.image.registry | string | `"docker.io"` |  |
| redis.image.repo | string | `"library/redis"` | Redis image name [ref](https://hub.docker.com/_/redis) |
| redis.image.tag | string | `"7.4.11-alpine"` | Redis image tag |
| redis.nodeSelector | object | `{}` | Node labels for Redis pod assignment |
| redis.persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes of the created PersistentVolumeClaim |
| redis.persistence.enabled | bool | `false` | Store Redis data on a PersistentVolumeClaim. Redash only keeps job queues and caches in Redis, so the default emptyDir is usually enough. |
| redis.persistence.existingClaim | string | `""` | Use an existing PersistentVolumeClaim instead of creating one |
| redis.persistence.size | string | `"8Gi"` | Size of the created PersistentVolumeClaim |
| redis.persistence.storageClass | string | `nil` | Storage class of the created PersistentVolumeClaim. Unset uses the cluster default; "-" sets an empty storageClassName. |
| redis.podAnnotations | object | `{}` | Annotations for the Redis pod |
| redis.podLabels | object | `{}` | Labels for the Redis pod |
| redis.podSecurityContext | object | `{"fsGroup":1000,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":999,"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for the Redis pod. 999/1000 are the redis user and group of the official image. |
| redis.priorityClassName | string | `nil` | Priority class name for the Redis pod |
| redis.resources | object | `{}` | Redis resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| redis.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}` | Security context for the Redis container |
| redis.service.port | int | `6379` | Redis service port |
| redis.tolerations | list | `[]` | Tolerations for Redis pod assignment |
| scheduler.affinity | object | `{}` | Affinity for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| scheduler.env | object | `{}` | Redash scheduler specific environment variables. |
| scheduler.initContainers | list | `[]` | Redash scheduler init containers configuration. |
| scheduler.livenessProbe | object | `{"exec":{"command":["/bin/sh","-c","/app/bin/docker-entrypoint workers_healthcheck"]},"initialDelaySeconds":60,"periodSeconds":100,"timeoutSeconds":10}` | Liveness probe for scheduler to ensure workers are running fine |
| scheduler.nodeSelector | object | `{}` | Node labels for scheduler pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| scheduler.podAnnotations | object | `{}` | Annotations for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| scheduler.podLabels | object | `{}` | Labels for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| scheduler.podSecurityContext | object | `{}` | Security contexts for scheduler pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| scheduler.priorityClassName | string | `nil` |  |
| scheduler.replicaCount | int | `1` | Number of scheduler pods to run |
| scheduler.resources | string | `nil` | scheduler resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| scheduler.securityContext | object | `{}` |  |
| scheduler.terminationGracePeriodSeconds | int | `nil` | Seconds Kubernetes waits after SIGTERM before killing the scheduler pod. Unset uses the Kubernetes default of 30 |
| scheduler.tolerations | list | `[]` | Tolerations for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| scheduler.topologySpreadConstraints | list | `[]` | Topology spread constraints for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) |
| scheduler.volumeMounts | list | `[]` | VolumeMounts for scheduler pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| scheduler.volumes | list | `[]` | Volumes for scheduler pod  assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| server.affinity | object | `{}` | Affinity for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| server.env | object | `{}` | Redash server specific environment variables Don't use this for variables that are in the configuration above, however. |
| server.httpPort | int | `5000` | Server container port (only useful if you are using a customized image) |
| server.initContainers | list | `[]` | Server init containers configuration |
| server.knative.annotations | object | `{}` | Annotations for the Knative revision template, including `autoscaling.knative.dev/*` settings |
| server.knative.enabled | bool | `false` | Render the server as a Knative Service instead of a Deployment |
| server.knative.spec | object | `{}` | Additional fields for the Knative revision spec (e.g. `containerConcurrency`, `timeoutSeconds`) |
| server.livenessProbe | object | `{"failureThreshold":10,"initialDelaySeconds":90,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Server liveness probe configuration |
| server.nodeSelector | object | `{}` | Node labels for server pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| server.podAnnotations | object | `{}` | Annotations for server pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| server.podLabels | object | `{}` | Labels for server pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| server.podSecurityContext | object | `{}` | Security contexts for server pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| server.priorityClassName | string | `nil` |  |
| server.readinessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Server readiness probe configuration  |
| server.replicaCount | int | `1` | Number of server pods to run. Set to `null` to omit `spec.replicas`, so an external HorizontalPodAutoscaler or KEDA ScaledObject can own the replica count |
| server.resources | object | `{}` | Server resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| server.securityContext | object | `{}` |  |
| server.terminationGracePeriodSeconds | int | `nil` | Seconds Kubernetes waits after SIGTERM before killing server pods. Unset uses the Kubernetes default of 30. Ignored when `server.knative.enabled` is true: Knative does not allow this field and derives the grace period from the revision's `timeoutSeconds` (`server.knative.spec.timeoutSeconds`) |
| server.tolerations | list | `[]` | Tolerations for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| server.topologySpreadConstraints | list | `[]` | Topology spread constraints for server pod assignment [ref](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) |
| server.volumeMounts | list | `[]` | VolumeMounts for server pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| server.volumes | list | `[]` | Volumes for server pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| service.annotations | object | `{}` | Annotations to add to the service |
| service.externalTrafficPolicy | string | `""` | external traffic policy for Load Balancer |
| service.loadBalancerIP | string | `nil` | Specific IP address to use for cloud providers such as Azure Kubernetes Service [ref](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer) |
| service.port | int | `80` | Service external port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `nil` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| volumeMounts | list | `[]` | Redash global volume mounts configuration - applied to all containers |
| volumes | list | `[]` | Redash global volumes configuration - applied to all containers |
| worker.affinity | object | `{}` | Default affinity for worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| worker.initContainers | list | `[]` | Worker default init containers configuration |
| worker.livenessProbe | object | `{"exec":{"command":["/bin/sh","-c","/app/bin/docker-entrypoint workers_healthcheck"]},"initialDelaySeconds":60,"periodSeconds":100,"timeoutSeconds":10}` | Default worker's liveness probe to ensure workers are running fine |
| worker.nodeSelector | object | `{}` | Default node labels for worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| worker.podAnnotations | object | `{}` | Default annotations for worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) |
| worker.podLabels | object | `{}` | Default labels for worker pod assignment [ref](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| worker.podSecurityContext | object | `{}` | Default worker's security context pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| worker.priorityClassName | string | `nil` |  |
| worker.replicaCount | int | `1` | Default number of worker pods to run. Set to `null` (here or under `workers.<name>`) to omit `spec.replicas`, so an external HorizontalPodAutoscaler or KEDA ScaledObject can own the replica count |
| worker.resources | string | `nil` | Worker default resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| worker.securityContext | object | `{}` |  |
| worker.terminationGracePeriodSeconds | int | `nil` | Default seconds Kubernetes waits after SIGTERM before killing worker pods. Unset uses the Kubernetes default of 30. Raise it when workers should finish in-flight jobs before exiting |
| worker.tolerations | list | `[]` | Default tolerations for worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| worker.topologySpreadConstraints | list | `[]` | Default topology spread constraints for worker pod assignment [ref](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) |
| worker.volumeMounts | list | `[]` | Default VolumeMounts for worker pod assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| worker.volumes | list | `[]` | Default volumes for pod worker assignment [ref](https://kubernetes.io/docs/concepts/storage/volumes/) |
| workers.adhoc.env | object | `{"QUEUES":"queries","WORKERS_COUNT":2}` | Redash ad-hoc worker specific environment variables. |
| workers.generic.env | object | `{"QUEUES":"periodic,emails,default","WORKERS_COUNT":1}` | Redash generic worker specific environment variables. |
| workers.scheduled.env | object | `{"QUEUES":"scheduled_queries,schemas","WORKERS_COUNT":1}` | Redash scheduled worker specific environment variables. |

## Upgrading

- See [the changelog](CHANGELOG.md) for major changes in each release
- The project will use the [semver specification](http://semver.org) for chart version numbers (chart versions will not match Redash versions, since we may need to update the chart more than once for the same Redash release)
- Always back up your database before upgrading!
- Schema migrations will be run automatically after each upgrade (from 5.0.0; earlier chart versions only created the schema on a fresh install)

To upgrade a release named `my-release`:

```bash
helm repo update
helm upgrade --reset-then-reuse-values my-release redash/redash
```

Below are notes on manual configuration changes or steps needed for major chart version updates.

### From 4.x to 5.0

5.0.0 replaces the Bitnami PostgreSQL and Redis subcharts with chart-owned StatefulSets on the official `postgres` and `redis` images, and upgrades Redash from v25.8.0 to v26.9.0. The new PostgreSQL starts with an empty data directory, so a release that uses the bundled PostgreSQL (`postgresql.enabled: true`, the default) has to dump its data before upgrading and restore it afterwards. Both sides run PostgreSQL 18, so a plain-SQL `pg_dump` restores as-is.

Releases that use an external PostgreSQL (`postgresql.enabled: false`) only need the values changes in step 1. Redis holds no data that needs moving.

Plan a maintenance window: Redash is stopped from step 2 until step 6. Replace `<release>` and `<namespace>` below. `<fullname>` is `<release>-redash`, or just `<release>` when the release name already contains `redash` (it also follows `nameOverride`/`fullnameOverride`).

**1. Update your values file**

- Make sure it sets `postgresql.auth.password`, which 5.0.0 requires. If you relied on the Bitnami chart generating it, copy the current one: `kubectl get secret <release>-postgresql -n <namespace> -o jsonpath='{.data.password}' | base64 -d`. Pick it carefully: the official image only applies the password when it creates the database, so changing it later needs an `ALTER USER` first (see `postgresql.auth.password`).
- Rename `postgresql.primary.service.ports.postgresql` → `postgresql.service.port`, `redis.master.service.ports.redis` → `redis.service.port`, and `redis.existingSecret` → `redis.auth.existingSecret`.
- Remove other Bitnami subchart settings (`postgresql.primary.*`, `redis.master.*`, `redis.replica.*`, `redis.architecture`, and any `postgresql.image`/`redis.image` overrides such as `bitnamilegacy/*`). Set the equivalent `postgresql.*`/`redis.*` values from [values.yaml](values.yaml) instead, e.g. `postgresql.persistence.size`.
- If you use custom JavaScript charts, set `REDASH_FEATURE_ALLOW_CUSTOM_JS_VISUALIZATIONS: "true"` in `env` — Redash v26.9.0 disables them by default. Read the rest of its [upgrade notes](https://github.com/getredash/redash/blob/master/CHANGELOG.md#2690) too.

**2. Stop Redash, keeping the databases running**

```bash
kubectl scale deploy -n <namespace> -l app.kubernetes.io/instance=<release> --replicas=0
```

With `server.knative.enabled`, this only stops the workers and scheduler: the Knative web server keeps running. That does not affect the dump, but keep users away from Redash until step 6 (for example by removing its route), because between steps 4 and 5 it serves an empty database.

**3. Dump the database from the Bitnami PostgreSQL**

Set `PG_USER`/`PG_DB` to your `postgresql.auth.username`/`postgresql.auth.database`; steps 3 and 5 use them.

```bash
PG_USER=redash
PG_DB=redash
PG_PASS=$(kubectl get secret <release>-postgresql -n <namespace> -o jsonpath='{.data.password}' | base64 -d)
kubectl exec -n <namespace> <release>-postgresql-0 -- \
  env PGPASSWORD="$PG_PASS" pg_dump -U "$PG_USER" -d "$PG_DB" --no-owner --no-acl > redash.sql
```

Check that `redash.sql` is not empty before continuing. If `query_results` is very large, it is only a cache and can be left out with `--exclude-table-data=query_results`, but then the `queries_latest_query_data_id_fkey` constraint fails on restore — handle it as in the [4.0.0 notes](https://github.com/getredash/contrib-helm-chart/blob/master/CHANGELOG.md#400).

**4. Upgrade the chart**

Pass your values file explicitly, or use `--reset-then-reuse-values`. Plain `--reuse-values` does not pick up the new chart defaults and fails to render.

```bash
helm upgrade <release> redash/redash --version 5.0.0 -n <namespace> -f my-values.yaml --wait
```

Helm removes the Bitnami StatefulSets and starts `<fullname>-postgres` with a fresh database. The old PersistentVolumeClaims (`data-<release>-postgresql-0`, `redis-data-<release>-redis-master-0`) are kept.

**5. Stop Redash again and restore the dump into the new PostgreSQL**

```bash
kubectl scale deploy -n <namespace> -l app.kubernetes.io/instance=<release> --replicas=0
kubectl exec -n <namespace> <fullname>-postgres-0 -- \
  psql -U "$PG_USER" -d postgres -c "DROP DATABASE \"$PG_DB\" WITH (FORCE)" -c "CREATE DATABASE \"$PG_DB\""
kubectl exec -i -n <namespace> <fullname>-postgres-0 -- \
  psql -U "$PG_USER" -d "$PG_DB" -v ON_ERROR_STOP=1 -q < redash.sql > /dev/null
```

**6. Start Redash**

Run the same upgrade again. It restores the replica counts, and the migrations job applies any pending Redash schema migrations to the restored database. If an HPA or KEDA owns the Deployment replicas (`server.replicaCount`, `worker.replicaCount` or `workers.<name>.replicaCount` set to `null`), the chart does not set replicas, so this step does not bring them back. Pause KEDA before step 2 (`autoscaling.keda.sh/paused: "true"` on each ScaledObject) so it does not scale Redash up mid-migration, then after this step scale the Deployments to at least 1 (`kubectl scale deploy ... --replicas=1`, since an HPA does not scale up from 0) and remove the pause annotation.

```bash
helm upgrade <release> redash/redash --version 5.0.0 -n <namespace> -f my-values.yaml --wait
```

**7. Clean up**

- If a Redash data source points at the bundled database by its old hostname (`<release>-postgresql`), change it to `<fullname>-postgres`.
- Once Redash works, delete the old volumes: `kubectl delete pvc -n <namespace> data-<release>-postgresql-0 redis-data-<release>-redis-master-0`

### From 3.0 to 3.1

- Upgraded Redis and PostgreSQL dependency charts, which have new parameters names. Please follow [README.md](./README.md) and official [Redis](https://github.com/bitnami/charts/tree/main/bitnami/redis) and [PostgreSQL](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) charts guides.
- Merged workers configuration to simplify their setup:
  - `adhocWorker` => `workers.adhoc`
  - `genericWorker` => `workers.generic`
  - `scheduledWorker` => `workers.scheduled`
  - default config for all workers is at `worker` section
- replaced `hookInstallJob` and `hookUpgradeJob` with `migrations`
- Moved custom entrypoint scripts to [Redash repo](https://github.com/getredash/redash/pull/6674)

### From 3.1 to 3.2

**CRITICAL: PostgreSQL Major Version Upgrade (15→18)**

This upgrade includes a PostgreSQL major version upgrade from 15 to 18. **PostgreSQL major versions are NOT data-directory compatible** - PostgreSQL 18 cannot read PostgreSQL 15 data directly.

**Two upgrade options:**

#### Option 1: Automatic Migration (Recommended)

Enable automatic migration hooks:

1. **Create a PVC for migration storage** (required):
   ```bash
   kubectl create -f - <<EOF
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: <release-name>-postgres-migration
   spec:
     accessModes: [ReadWriteOnce]
     resources:
       requests:
         storage: 10Gi
   EOF
   ```

2. **Enable migration hooks** in your values:
   ```yaml
   postgresqlMigration:
     enabled: true
     storage:
       pvcName: <release-name>-postgres-migration
   ```

3. **Upgrade**:
   ```bash
   helm upgrade --reuse-values <release-name> redash/redash
   ```

**What happens automatically:**
- Pre-upgrade hook: Dumps PostgreSQL 15 data to the migration PVC
- Pre-upgrade hook: Scales down PostgreSQL 15 StatefulSet
- Pre-upgrade hook: Deletes the old PostgreSQL 15 PVC (data is safely backed up)
- Helm upgrade: Starts PostgreSQL 18 with a fresh data directory
- Post-upgrade hook: Restores data from dump files to PostgreSQL 18

**Important Notes:**
- The service account needs RBAC permissions (automatically created when `postgresqlMigration.enabled: true`)
- Ensure the migration PVC has sufficient storage (at least 2x your database size)
- The old PostgreSQL 15 PVC will be **deleted** - all data must be in the dump files
- Test in a staging environment first!

#### Option 2: Manual Migration

If you prefer manual control:

1. **Dump the database**:
   ```bash
   kubectl exec -it <release-name>-postgresql-0 -- pg_dump -U redash -d redash -F c -f /tmp/redash-backup.dump
   kubectl cp <release-name>-postgresql-0:/tmp/redash-backup.dump ./redash-backup.dump
   ```

2. **Delete the PostgreSQL StatefulSet and PVC**:
   ```bash
   kubectl scale statefulset <release-name>-postgresql --replicas=0
   kubectl delete pvc <release-name>-postgresql-data-0  # or appropriate PVC name
   ```

3. **Upgrade the chart** (PostgreSQL 18 will start fresh):
   ```bash
   helm upgrade --reuse-values <release-name> redash/redash
   ```

4. **Wait for PostgreSQL 18 to be ready**, then restore:
   ```bash
   kubectl cp ./redash-backup.dump <release-name>-postgresql-0:/tmp/redash-backup.dump
   kubectl exec -it <release-name>-postgresql-0 -- pg_restore -U redash -d redash -v --no-owner --no-privileges /tmp/redash-backup.dump
   ```

**Other changes:**
- Redash upgraded from v24.04.0-dev to v25.8.0 (latest stable)
- Redis dependency upgraded from ^19.1.0 to ^24.1.0
- Kubernetes compatibility: 1.31+ (removed support for 1.26-1.30)

### From 2.x to 3.x

- The Redash version is updated from v8 to v10 (v9 never had a stable release)
- The upgrade should be automatic, but please test on a staging environment first!
- There are now additional "genericworker" and "scheduler" deployments, with associated configuration in values.yaml
- 3.x and higher will not run with Redash v8 - if you have overridden the image you will need to update that
- This chart now requires Kubernetes 1.19+
- Helm 2 is now deprecated and support will be removed in a future version

### From 1.x to 2.x

- There are 3 required secrets (see above) that must now be specified in your release
- The server.env is now deprecated (except for non-standard variables such as PYTHON_*) to allow for better management of Redash configuration and secret values - any existing configuration should be migrated to the new values

### From pre-release to 1.x

- The values.yaml structure has several changes
- The Redash, PostgreSQL and Redis versions have all been updated
- Due to these changes you will likely need to dump the database and reload it into a fresh install
- The chart now has its own repo: https://getredash.github.io/contrib-helm-chart/

## License

This chart uses the [Apache 2 license](LICENSE).

## Contributing

Contributions [are welcome](CONTRIBUTING.md).
