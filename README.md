# PostGIS Container Images

Maintenance scripts to generate Immutable Application Containers
for all available PostgreSQL + PostGIS versions (12 to 17) to be used as
operands with the [CloudNativePG operator](https://cloudnative-pg.io)
for Kubernetes.

These images are built on top of the [PostGIS image](https://hub.docker.com/r/postgis/postgis)
(Debian version), by adding the following software:

- [Barman Cloud](https://www.pgbarman.org)
- [PGAudit](https://github.com/pgaudit/pgaudit)
- [Postgres Failover Slots](https://github.com/EnterpriseDB/pg_failover_slots)
- [pgRouting](https://github.com/pgRouting/pgrouting)

Barman Cloud is distributed by EnterpriseDB under the
[GNU GPL 3 License](https://github.com/EnterpriseDB/barman/blob/master/LICENSE).

PGAudit is distributed under the
[PostgreSQL License](https://github.com/pgaudit/pgaudit/blob/master/LICENSE).

Postgres Failover Slots is distributed by EnterpriseDB under the
[PostgreSQL License](https://github.com/EnterpriseDB/pg_failover_slots/blob/master/LICENSE).

pgRouting is distributed under the
[GNU GPL 2 License](https://github.com/pgRouting/pgrouting/blob/main/LICENSE),
with the some Boost extensions being available under
[Boost Software License](https://docs.pgrouting.org/latest/en/pgRouting-introduction.html#licensing).

Licensing information of all the software included in the container images is
in the `/usr/share/doc/*/copyright*` files.

## Where to get them

Images are available via the
[GitHub Container Registry](https://github.com/cloudnative-pg/postgis-containers/pkgs/container/postgis).

## How to use them

The following example shows how you can easily create a new PostgreSQL 17
cluster with PostGIS 3.4 in it. All you have to do is set the `imageName`
accordingly. Please look at the registry for a list of available images
and select the one you need.

Create a YAML manifest. For example, you can put the YAML below into a file
named `postgis.yaml` (any name is fine). (Please refer to
[CloudNativePG](https://cloudnative-pg.io/docs) for details on the API):

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-example
spec:
  instances: 3
  imageName: ghcr.io/cloudnative-pg/postgis:17-3.4
  bootstrap:
    initdb:
      postInitTemplateSQL:
        - CREATE EXTENSION postgis;
        - CREATE EXTENSION postgis_topology;
        - CREATE EXTENSION fuzzystrmatch;
        - CREATE EXTENSION postgis_tiger_geocoder;

  storage:
    size: 1Gi
```

Then run `kubectl apply -f postgis.yaml`.

When the cluster is up, run the following command to verify the version of
PostGIS that is available in the system, by connecting to the `app` database:

```console
$ kubectl exec -ti cluster-example-1 -- psql app
psql (17.0 (Debian 17.0-1.pgdg110+1))
Type "help" for help.

app=# SELECT * FROM pg_available_extensions WHERE name ~ '^postgis' ORDER BY 1;
           name           | default_version | installed_version |                          comment
--------------------------+-----------------+-------------------+------------------------------------------------------------
 postgis                  | 3.4.0           |                   | PostGIS geometry and geography spatial types and functions
 postgis-3                | 3.4.0           |                   | PostGIS geometry and geography spatial types and functions
 postgis_raster           | 3.4.0           |                   | PostGIS raster types and functions
 postgis_raster-3         | 3.4.0           |                   | PostGIS raster types and functions
 postgis_sfcgal           | 3.4.0           |                   | PostGIS SFCGAL functions
 postgis_sfcgal-3         | 3.4.0           |                   | PostGIS SFCGAL functions
 postgis_tiger_geocoder   | 3.4.0           |                   | PostGIS tiger geocoder and reverse geocoder
 postgis_tiger_geocoder-3 | 3.4.0           |                   | PostGIS tiger geocoder and reverse geocoder
 postgis_topology         | 3.4.0           |                   | PostGIS topology spatial types and functions
 postgis_topology-3       | 3.4.0           |                   | PostGIS topology spatial types and functions
(10 rows)
```

The following command shows the extensions installed in the `app` database,
thanks to the `postInitTemplateSQL` section in the bootstrap which runs the
selected `CREATE EXTENSION` commands in the `template1` database, which is
inherited by the application database - called `app` and created by default by
CloudNativePG.

```console
app=# \dx
                                        List of installed extensions
          Name          | Version |   Schema   |                        Description
------------------------+---------+------------+------------------------------------------------------------
 fuzzystrmatch          | 1.2     | public     | determine similarities and distance between strings
 plpgsql                | 1.0     | pg_catalog | PL/pgSQL procedural language
 postgis                | 3.4.0   | public     | PostGIS geometry and geography spatial types and functions
 postgis_tiger_geocoder | 3.4.0   | tiger      | PostGIS tiger geocoder and reverse geocoder
 postgis_topology       | 3.4.0   | topology   | PostGIS topology spatial types and functions
(5 rows)
```

You can now enjoy PostGIS!

## License and copyright

This software is available under [Apache License 2.0](LICENSE).

Copyright The CloudNativePG Contributors.

## Trademarks

*[Postgres, PostgreSQL and the Slonik Logo](https://www.postgresql.org/about/policies/trademarks/)
are trademarks or registered trademarks of the PostgreSQL Community Association
of Canada, and used with their permission.*
