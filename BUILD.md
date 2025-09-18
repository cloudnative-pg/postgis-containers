# Building PostGIS Container Images for CloudNativePG

This guide outlines the process for building PostGIS operand images for
CloudNativePG using [Docker Bake](https://docs.docker.com/build/bake/) and a
[GitHub workflow](.github/workflows/bake.yml).

## Prerequisites and Requirements

For prerequisites and requirements, refer to the [postgres-containers](https://github.com/cloudnative-pg/postgres-containers) documentation:
- [Prerequisites](https://github.com/cloudnative-pg/postgres-containers/blob/main/BUILD.md#prerequisites)
- [Verifying requirements](https://github.com/cloudnative-pg/postgres-containers/blob/main/BUILD.md#verifying-requirements)

## How it works

This project works as a dependent module of [postgres-containers](https://github.com/cloudnative-pg/postgres-containers), and requires
to include [postgres-containers's docker-bake.hcl](https://github.com/cloudnative-pg/postgres-containers/blob/main/docker-bake.hcl) as a source Bake file definition.

The local [docker-bake.hcl](docker-bake.hcl) extends the source Bake file by adding a `postgis` target.

## PostGIS Target

The `postgis` target in Bake represents a Cartesian product of the following
dimensions:

- **Base Image** (e.g `18-standard-trixie`)
  - **PostgreSQL Major version** (e.g `18`)
  - **Type** (e.g. `standard`)
  - **OS** (e.g. `trixie`)
- **Platforms**
- **PostGIS version**

## Building Images

To build PostGIS images using the `postgis` target - all the available PostGIS combinations - run:

```bash
docker buildx bake --push \
  -f docker-bake.hcl \ # The bake file relative to the remote URL
  -f cwd://docker-bake.hcl \ # The local bake file
  "https://github.com/cloudnative-pg/postgres-containers.git#main" \ # The remote URL
  postgis
```

> *Important:* It's mandatory to set the `postgis` target (or a stricter one).
> Without it, Bake will try building all targets, including the `default` one
> which contains plain PostgreSQL images inherited from the remote bake file.

This setup, described in https://docs.docker.com/build/bake/remote-definition/,
let's you combine multiple bake files so that all attributes from the source configuration
are reused. At the same time, it allows you to override specific values in the local bake file,
giving you flexible and maintainable build configurations.

You can limit the build to a stricter combination or even to a specific image.
Postgis targets use the following naming convention:
```
postgis-<postgisVersion>-<postgresMajor>-<type>-<os>
```

For example, you can limit the build to all PostGIS 3.6.0 on PostgreSQL 17 by using `postgis-360-17*` as a target,
or even specify a full image like `postgis-360-17-standard-trixie`.

