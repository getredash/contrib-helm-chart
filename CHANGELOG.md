# Changelog

## 4.0.0

**BREAKING CHANGE — PostgreSQL major version upgrade requires manual migration.**

### What changed

- **Remove automatic PostgreSQL migration hooks** (`postgresqlMigration.enabled`): the pre-upgrade dump job and post-upgrade restore job have been removed entirely. These hooks proved too fragile in production due to OOM kills on large `query_results` tables, FK constraint violations during restore, and the requirement for superuser privileges for `--disable-triggers`. PostgreSQL major version migration must now be performed manually before running `helm upgrade`.
- **Remove `rbac-postgres-migration` templates**: the Role and RoleBinding created for the migration hooks are no longer needed and have been removed.
- **Remove `postgresqlMigration` values block**: the `postgresqlMigration.enabled` and `postgresqlMigration.storage.pvcName` values no longer exist. Remove them from your `values.yaml` or Helm `--set` flags before upgrading.

### Deprecation notice

Chart versions **3.1.x** and **3.2.x** are deprecated. Do not use them for new upgrades — the automatic migration hooks in those versions are unreliable. Upgrade directly to 4.0.0 and follow the manual migration steps below.

### Manual PostgreSQL migration (required when upgrading from chart ≤ 3.0.x)

If you are running chart 3.0.x (PostgreSQL 15) and upgrading to 4.0.0 (PostgreSQL 18), you **must** migrate your data manually. The steps below use a plain-SQL dump (`.sql`) rather than custom format — this gives you full control to strip problematic content before restoring.

> Replace `<release>`, `<namespace>`, `<pg-user>`, `<pg-database>` with your actual values throughout.

---

**Step 1 — Collect credentials**

```bash
# PostgreSQL superuser password (needed to drop/create DB and restore as postgres)
PG_ADMIN_PASS=$(kubectl get secret <release>-postgresql -n <namespace> \
  -o jsonpath='{.data.postgres-password}' | base64 -d)

# Redash app user password
PG_REDASH_PASS=$(kubectl get secret <release>-postgresql -n <namespace> \
  -o jsonpath='{.data.password}' | base64 -d)

# Redis password
REDIS_PASS=$(kubectl get secret <release>-redis -n <namespace> \
  -o jsonpath='{.data.redis-password}' | base64 -d)
```

---

**Step 2 — Dump from old PostgreSQL (PG 15, plain SQL format)**

```bash
# Dump the full schema + data as plain SQL, excluding query_results data.
# query_results is a pure query cache — it's large, causes OOM on restore, and is regenerated automatically.
kubectl exec -n <namespace> <release>-postgresql-0 -- \
  env PGPASSWORD="$PG_REDASH_PASS" pg_dump \
    -U <pg-user> -d <pg-database> \
    --no-owner --no-acl \
    --exclude-table-data=query_results \
    -f /tmp/redash-dump.sql

kubectl cp <namespace>/<release>-postgresql-0:/tmp/redash-dump.sql ./redash-dump.sql
```

---

**Step 3 — Prepare the dump file (run locally, once)**

```bash
# PG 12+ removed SET default_with_oids — comment it out
sed -i '' 's/^SET default_with_oids = false;/-- SET default_with_oids = false;/' redash-dump.sql

# Comment out the FK constraint that references query_results.
# Since query_results data is excluded, this constraint will fail on restore.
# We add it back manually after NULLing the dangling references (Step 8).
grep -n 'queries_latest_query_data_id_fkey' redash-dump.sql
# Note the line number(s), then comment them out:
sed -i '' '/queries_latest_query_data_id_fkey/s/^/-- /' redash-dump.sql
```

---

**Step 4 — Scale down Redash app (keep PostgreSQL and Redis running)**

```bash
kubectl scale deploy -n <namespace> --replicas=0 --all

# Wait until only the database pods remain
kubectl get pods -n <namespace> -w
```

---

**Step 5 — Drop and recreate the database**

Connect as `postgres` to the `postgres` database (not `redash`) to avoid "database is being accessed by other users" errors.

```bash
kubectl exec -n <namespace> <release>-postgresql-0 -- \
  env PGPASSWORD="$PG_ADMIN_PASS" psql -U postgres -d postgres \
    -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='<pg-database>' AND pid <> pg_backend_pid();" \
    -c "DROP DATABASE <pg-database>;" \
    -c "CREATE DATABASE <pg-database> OWNER <pg-user>;"
```

---

**Step 6 — Copy dump into pod and restore**

```bash
kubectl cp redash-dump.sql <namespace>/<release>-postgresql-0:/tmp/dump.sql

kubectl exec -n <namespace> <release>-postgresql-0 -- \
  env PGPASSWORD="$PG_REDASH_PASS" psql -U <pg-user> -d <pg-database> -f /tmp/dump.sql
```

> `ERROR: must be owner of extension plpgsql` is harmless — safe to ignore.

---

**Step 7 — Upgrade the chart**

```bash
helm upgrade <release> <repo>/redash --version 4.0.0 \
  --namespace <namespace> \
  -f values.yaml \
  --wait --timeout 15m
```

Scale back down immediately after upgrade so migrations can run cleanly:

```bash
kubectl scale deploy -n <namespace> --replicas=0 --all
```

---

**Step 8 — Fix dangling FK references**

`queries.latest_query_data_id` points to `query_results` rows that were not restored. NULL them out so the FK constraint can be added.

```bash
kubectl exec -n <namespace> <release>-postgresql-0 -- \
  env PGPASSWORD="$PG_REDASH_PASS" psql -U <pg-user> -d <pg-database> \
    -c "UPDATE queries SET latest_query_data_id = NULL
        WHERE latest_query_data_id IS NOT NULL
          AND latest_query_data_id NOT IN (SELECT id FROM query_results);"

kubectl exec -n <namespace> <release>-postgresql-0 -- \
  env PGPASSWORD="$PG_REDASH_PASS" psql -U <pg-user> -d <pg-database> \
    -c "ALTER TABLE ONLY public.queries
          ADD CONSTRAINT queries_latest_query_data_id_fkey
          FOREIGN KEY (latest_query_data_id) REFERENCES public.query_results(id);" || true
```

---

**Step 9 — Run Redash schema migrations**

The new Redash version may have schema changes that Alembic needs to apply. Pass the connection URLs explicitly to avoid environment variable lookup issues.

```bash
kubectl exec -n <namespace> <release>-postgresql-0 -- \
  env PGPASSWORD="$PG_REDASH_PASS" psql -U <pg-user> -d <pg-database> \
    -c "SELECT version FROM alembic_version;"
# Should show current migration head after upgrade

# Find a running server pod and run migrations
kubectl exec -n <namespace> <redash-server-pod> -- \
  env REDASH_REDIS_URL="redis://:<redis-pass>@<release>-redis-master:6379/0" \
      REDASH_DATABASE_URL="postgresql://<pg-user>:<pg-pass>@<release>-postgresql:5432/<pg-database>" \
  /app/manage.py db upgrade
```

---

**Step 10 — Scale up and verify**

```bash
kubectl scale deploy -n <namespace> --replicas=1 --all
kubectl get pods -n <namespace> -w

# Verify data survived
kubectl exec -n <namespace> <release>-postgresql-0 -- \
  env PGPASSWORD="$PG_REDASH_PASS" psql -U <pg-user> -d <pg-database> \
    -c "SELECT count(*) FROM queries;"

# Check server logs
kubectl logs -n <namespace> deploy/<release>-redash-server --tail=50
```

`query_results` rows will be repopulated automatically as users re-run their queries.

---

**Known gotchas**

| Issue | Fix |
|---|---|
| `SET default_with_oids` error | Comment it out in the dump (removed in PG 12+) |
| OOM kill during `COPY query_results` | Use `--exclude-table-data=query_results` — it's just cache |
| FK violation on `queries_latest_query_data_id_fkey` | Comment out in dump; re-add after NULLing dangling refs (Step 8) |
| `cannot drop currently open database` | Connect to `postgres` DB as `postgres` superuser, not to `redash` |
| `database being accessed by other users` | Scale down all Redash deploys first (Step 4) |
| `manage.py` can't find Redis/Postgres | Pass `REDASH_REDIS_URL` and `REDASH_DATABASE_URL` explicitly (Step 9) |
| `cryptography.fernet.InvalidToken` on data sources | `REDASH_SECRET_KEY` must match the key used by the old Redash to encrypt credentials — ensure it is set correctly in your Helm values |

## 3.2.0

- Upgrade Redash from v24.04.0-dev to v25.8.0 (latest stable)
- Update default image repository from `redash/preview` to `redash/redash` for stable releases
- Upgrade PostgreSQL dependency from ^15.2.0 to ^18.2.0 (latest: 18.2.4)
- Upgrade Redis dependency from ^19.1.0 to ^24.1.0 (latest: 24.1.3)
- **NEW**: Added optional automatic PostgreSQL migration hooks for major version upgrades (15→18)
  - Enable with `postgresqlMigration.enabled: true` and configure a PVC for storage
  - See [README](charts/redash/README.md#upgrading) for details
- See upgrade notes in [README](charts/redash/README.md#upgrading)

**CRITICAL Upgrade Notes:**
- **Always backup your PostgreSQL database before upgrading**
- **Redash schema migrations** will run automatically via Helm hooks (handles Redash app schema changes)
- **PostgreSQL version upgrade (15→18)**:
  - **Option 1**: Enable automatic migration hooks (requires PVC) - see README
  - **Option 2**: Manual migration using `pg_dump`/`pg_restore` - see README
- PostgreSQL 15 → 18 is a major version jump requiring data migration
- Redis 19 → 24 upgrade should be automatic, but test thoroughly
- Test in staging environment first, especially if upgrading from v24.x
- Review Bitnami PostgreSQL and Redis chart changelogs for breaking changes

## 3.0.1 (unreleased)

- Change scheduler deployment strategy type to Recreate. (#121)

## 3.0.0

- Initial release supporting Redash v10.x
- See upgrade notes in [README](README.md#upgrading)

## 2.4.0

- Final v2.x release (except for critical fixes)
- Final release to support Redash v8.x
- Redis password is now required
- Kubernetes minimum version increased to v19.x
- Helm 2 depreciated, will be removed in a future version
- Supports stable Ingress API
- Add support for SQL Alchemy pool pre-ping configuration
- Add support for configurable worker pod labels
- Expand configurability of install/upgrade hooks

## 2.3.0

- Added externalPostgreSQLSecret / externalRedisSecret
- Depreciated envSecretName (plan to remove in 3.0.0 chart)
- Updated docs to make defaults clearer

## 2.2.0

- Update docs to Helm Docs 1.4+ format
- Removed duplicated env params that already come from "redash.env"
- Updated Redash environment variables and associated docs
- Updated CI to use Helm v3.4.1

## 2.1.0

- Added redash.samlSchemeOverride
- Added envSecretName
- Expanded service configuration: .service.annotations and .service.loadBalancerIP
- Moved postgresql and redis charts to Bitnami repo and update to latest patch release versions
- Updated CI to use Helm v2.16.12 and v3.3.4
- Updated CI to drop k8s v1.15, add v1.17, v1.18 and v1.19
- Improved CI release publishing flow

## 2.0.0

- Made secrets required, rather than auto-generating to avoid them [changing on upgrade](https://github.com/helm/charts/issues/5167)
- Variable additions and template updates to bring in line with Helm 3 chart template
- Add support for external secrets
- Extended CI testing for multiple k8s and Helm versions
- Extended CI testing for testing major version upgrades
- Moved install and upgrade logic to Helm hooks
- Added basic connectivity test hook for `helm test`
- Created values for each environment variable accepted by Redash

## 1.2.0

- Upgrade Redash to 8.0.2.b37747
- Upgrade PostgreSQL chart (the old version used depreciated APIs) and image tag
- Upgrade Redis chart

## 1.1.0

- Initial release of chart on getredash namespace
- Upgrade Redash to 8.0.1.b33387
- Add support for external Redis server
- Add CI linting/testing and release automation

## Pre-release

For pre-release versions please see the [pull request](https://github.com/helm/charts/pull/5071) where this was originally developed.
