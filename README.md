[![CloudNativePG](./logo/cloudnativepg.png)](https://cloudnative-pg.io/)

> **IMPORTANT:** Starting from **September 2025**, the CloudNativePG project
> has fully transitioned to the new Docker **`bake`-based build process** for
> the main [PostgreSQL container images](https://github.com/cloudnative-pg/postgres-containers).
> Consequently, the **CloudNativePG PostGIS images** will now also be built on
> top of these new base images.

---

# CNPG PostGIS Container Images

This repository provides scripts and definitions for building **immutable
application container images** that bundle PostGIS with PostgreSQL.
These images are built on top of the official
[CNPG PostgreSQL container images project](https://github.com/cloudnative-pg/postgres-containers)
and are maintained for the latest PostGIS major version (currently 3), across
all supported PostgreSQL releases, on the following base variants:

- `standard` – without Barman Cloud
- `system` – with Barman Cloud

Images are maintained in accordance with the PostgreSQL and Debian lifecycles,
following the [`postgres-containers`](https://github.com/cloudnative-pg/postgres-containers)
policy—**except that Debian `oldoldstable` is not supported**—and are
contingent upon the availability of
[Apt packages from the PostgreSQL Global Development Group (PGDG)](https://wiki.postgresql.org/wiki/Apt).

Images are available via the
[`ghcr.io/cloudnative-pg/postgis` registry](https://github.com/cloudnative-pg/postgis-containers/pkgs/container/postgis),
and intended exclusively as **operands of the [CloudNativePG (CNPG) operator](https://cloudnative-pg.io)**
in Kubernetes environments. They are **not designed for standalone use**.

> ⚠️ **IMPORTANT:** This project is transitional. The long-term plan is to
> decommission it once PostgreSQL 17 reaches end of life (November 2029).
> Starting with PostgreSQL 18, the `extension_control_path` GUC will allow
> PostGIS to be mounted as a separate image volume, removing the need for
> dedicated PostGIS container images.

## Image Tags

Each image is identified by its digest and a main tag of the form:

```
MM.mm-x.y.z-TS-TYPE-OS
```

where:

- `MM` is the PostgreSQL major version (e.g. `17`)
- `mm` is the PostgreSQL minor version (e.g. `6`)
- `x` is the PostGIS major version (e.g. `3`)
- `y` is the PostGIS minor version (e.g. `6`)
- `z` is the PostGIS patch version (e.g. `0`)
- `TS` is the build timestamp with minute precision (e.g. `202509221231`)
- `TYPE` is image type (e.g. `minimal`)
- `OS` is the underlying distribution (e.g. `trixie`)

For example: `postgis-testing:17.6-3.6.0-202509221231-system-trixie`.

### Rolling Tags

In addition to fully qualified tags, rolling tags are available in the
following formats:

- `MM.mm-x.y.TYPE-OS`: latest image for a given PostgreSQL *minor* version
  (`17.6`) with a given PostGIS *minor* version (`3.6`) of a specific type
  (`minimal`) on a Debian version (`trixie`).
  For example: `17.6-3.6-minimal-trixie`.
- `MM-x.y.TYPE-OS`: latest image for a given PostgreSQL *major* version
  (`17`) with a given PostGIS *minor* version (`3.6`) of a specific type
  (`minimal`) on a Debian version (`trixie`).
  For example: `17-3.6-minimal-trixie`.
- `MM-x-TYPE-OS`: latest image for a given PostgreSQL *major* version (`17`)
  with a given PostGIS *major* version (`3`) of a specific type a specific type
  (`minimal`) on a Debian version (`trixie`).
  For example: `17-3-minimal-trixie`.

<!--

## Image Catalogs

TODO

-->

## License and copyright

This software is available under [Apache License 2.0](LICENSE).

Copyright The CloudNativePG Contributors.

Licensing information of all the software included in the container images is
in the `/usr/share/doc/*/copyright*` files.

---

<p align="center">
We are a <a href="https://www.cncf.io/sandbox-projects/">Cloud Native Computing Foundation Sandbox project</a>.
</p>

<p style="text-align:center;" align="center">
      <picture align="center">
         <source media="(prefers-color-scheme: dark)" srcset="https://github.com/cncf/artwork/blob/main/other/cncf/horizontal/white/cncf-white.svg?raw=true">
         <source media="(prefers-color-scheme: light)" srcset="https://github.com/cncf/artwork/blob/main/other/cncf/horizontal/color/cncf-color.svg?raw=true">
         <img align="center" src="https://github.com/cncf/artwork/blob/main/other/cncf/horizontal/color/cncf-color.svg?raw=true" alt="CNCF logo" width="50%"/>
      </picture>
</p>

---

<p align="center">
CloudNativePG was originally built and sponsored by <a href="https://www.enterprisedb.com">EDB</a>.
</p>

<p style="text-align:center;" align="center">
      <picture align="center">
         <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/cloudnative-pg/.github/main/logo/edb_landscape_color_white.svg">
         <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/cloudnative-pg/.github/main/logo/edb_landscape_color_grey.svg">
         <img align="center" src="https://raw.githubusercontent.com/cloudnative-pg/.github/main/logo/edb_landscape_color_grey.svg" alt="EDB logo" width="25%"/>
      </picture>
</p>

---

<p align="center">
<a href="https://www.postgresql.org/about/policies/trademarks/">Postgres, PostgreSQL, and the Slonik Logo</a>
are trademarks or registered trademarks of the PostgreSQL Community Association
of Canada, and used with their permission.
</p>
