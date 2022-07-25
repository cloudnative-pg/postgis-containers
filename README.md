# PostGIS Container Images

Maintenance scripts to generate Immutable Application Containers
for all available PostgreSQL + PostGIS versions (11 to 14) to be used as
operands with the [CloudNativePG operator](https://cloudnative-pg.io)
for Kubernetes. 

These images are built on top of the [PostGIS image](https://hub.docker.com/r/postgis/postgis)(Debian version), by adding the following software:

- Barman Cloud
- PGAudit

Barman Cloud is distributed by EnterpriseDB under the
[GNU GPL 3 License](https://github.com/2ndquadrant-it/barman/blob/master/LICENSE).

PGAudit is distributed under the [PostgreSQL License](https://github.com/pgaudit/pgaudit/blob/master/LICENSE).

Images are available via
[GitHub Container Registry](https://github.com/cloudnative-pg/postgis-containers/pkgs/container/postgis).

## License and copyright

This software is available under [Apache License 2.0](LICENSE).

Copyright The CloudNativePG Contributors.

## Trademarks

*[Postgres, PostgreSQL and the Slonik Logo](https://www.postgresql.org/about/policies/trademarks/)
are trademarks or registered trademarks of the PostgreSQL Community Association
of Canada, and used with their permission.*

