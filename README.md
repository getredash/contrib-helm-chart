# Redash

Redash is an open source tool built for teams to query, visualize and collaborate.

## Introduction

This chart bootstraps a [Redash](https://github.com/getredash/redash) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

This is a contributed project developed by volunteers and not officially supported by Redash.

Current chart version is `2.0.0`

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
$ cat > my-values.yaml \<<- EOM
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
| adhocWorker.env | object | `{"QUEUES":"queries,celery","WORKERS_COUNT":2}` | Redash ad-hoc worker specific global envrionment variables [see docs](https://redash.io/help-onpremise/setup/settings-environment-variables.html) |
| adhocWorker.nodeSelector | object | `{}` | Node labels for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| adhocWorker.podSecurityContext | object | `{}` | Security contexts for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| adhocWorker.replicaCount | int | `1` | Number of ad-hoc worker pods to run |
| adhocWorker.resources | string | `nil` | Ad-hoc worker resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| adhocWorker.tolerations | list | `[]` | Tolerations for ad-hoc worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| env.PYTHONUNBUFFERED | int | `0` |  |
| env.REDASH_LOG_LEVEL | string | `"INFO"` |  |
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
| postgresql | object | `{"enabled":true,"image":{"tag":"9.6.17-debian-10-r3"},"persistence":{"accessMode":"ReadWriteOnce","enabled":true,"size":"10Gi","storageClass":""},"postgresqlDatabase":"redash","postgresqlUsername":"redash","service":{"port":5432,"type":"ClusterIP"}}` | Configuration values for the postgresql dependency. This PostgreSQL instance is used by default for all Redash state storage [ref](https://github.com/kubernetes/charts/blob/master/stable/postgresql/README.md) |
| postgresql.enabled | bool | `true` | Whether to deploy a PostgreSQL server to satisfy the applications database requirements. To use an external PostgreSQL set this to false and configure the externalPostgreSQL parameter. |
| postgresql.image.tag | string | `"9.6.17-debian-10-r3"` | Bitnami supported version close to the one specified in Redash [setup docker-compose.yml](https://github.com/getredash/setup/blob/master/data/docker-compose.yml) |
| postgresql.persistence.accessMode | string | `"ReadWriteOnce"` | Use PostgreSQL volume as ReadOnly or ReadWrite |
| postgresql.persistence.enabled | bool | `true` | Use a PVC to persist PostgreSQL data (when postgresql chart enabled) |
| postgresql.persistence.size | string | `"10Gi"` | PVC Storage Request size for PostgreSQL volume |
| postgresql.postgresqlDatabase | string | `"redash"` | PostgreSQL database name (when postgresql chart enabled) |
| postgresql.postgresqlUsername | string | `"redash"` | PostgreSQL username for redash user (when postgresql chart enabled) |
| redis | object | `{"cluster":{"enabled":false},"databaseNumber":0,"enabled":true,"master":{"port":6379}}` | Configuration values for the redis dependency. This Redis instance is used by default for caching and temporary storage [ref](https://github.com/kubernetes/charts/blob/master/stable/redis/README.md) |
| redis.databaseNumber | int | `0` | Enable Redis clustering (when redis chart enabled) |
| redis.enabled | bool | `true` | Whether to deploy a Redis server to satisfy the applications database requirements. To use an external Redis set this to false and configure the externalRedis parameter. |
| redis.master.port | int | `6379` | Redis master port to use (when redis chart enabled) |
| scheduledWorker | object | `{"affinity":{},"env":{"QUEUES":"scheduled_queries","WORKERS_COUNT":2},"nodeSelector":{},"podSecurityContext":{},"replicaCount":1,"resources":null,"securityContext":{},"tolerations":[]}` | Configuration for Redash scheduled workers |
| scheduledWorker.affinity | object | `{}` | Affinity for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| scheduledWorker.env | object | `{"QUEUES":"scheduled_queries","WORKERS_COUNT":2}` | Redash scheduled worker specific global envrionment variables [see docs](https://redash.io/help-onpremise/setup/settings-environment-variables.html) |
| scheduledWorker.nodeSelector | object | `{}` | Node labels for scheduled worker pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| scheduledWorker.podSecurityContext | object | `{}` | Security contexts for scheduled worker pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| scheduledWorker.replicaCount | int | `1` | Number of scheduled worker pods to run |
| scheduledWorker.resources | string | `nil` | Scheduled worker resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| scheduledWorker.tolerations | list | `[]` | Tolerations for scheduled worker pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
| server.affinity | object | `{}` | Affinity for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) |
| server.env | object | `{"REDASH_WEB_WORKERS":4}` | Redash server specific global envrionment variables [see docs](https://redash.io/help-onpremise/setup/settings-environment-variables.html) |
| server.httpPort | int | `5000` | Server container port (only useful if you are using a customized image) |
| server.nodeSelector | object | `{}` | Node labels for server pod assignment [ref](https://kubernetes.io/docs/user-guide/node-selection/) |
| server.podSecurityContext | object | `{}` | Security contexts for server pod assignment [ref](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| server.replicaCount | int | `1` | Number of server pods to run |
| server.resources | string | `nil` | Server resource requests and limits [ref](http://kubernetes.io/docs/user-guide/compute-resources/) |
| server.securityContext | object | `{}` |  |
| server.tolerations | list | `[]` | Tolerations for server pod assignment [ref](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |
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

### From pre-release to 1.x

- The values.yaml structure has several changes
- The Redash, PostgreSQL and Redis versions have all been updated
- Due to these changes you will likely need to dump the database and reload it into a fresh install
- The chart now has it's own repo: https://getredash.github.io/contrib-helm-chart/

## License

This chart uses the [Apache 2 license](LICENSE).

## Contributing

Contributions [are welcome](CONTRIBUTING.md).
