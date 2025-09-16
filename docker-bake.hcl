fullname = ( environment == "testing") ? "${registry}/postgis-testing" : "${registry}/postgis"
url = "https://github.com/cloudnative-pg/postgis-containers"

variable "postgisMatrix" {
  default = {
    "bullseye" = "3.5.2+dfsg-1.pgdg110+1"
    "bookworm" = "3.6.0+dfsg-1.pgdg12+1"
    "trixie" = "3.6.0+dfsg-1.pgdg13+1"
  }
}

variable "distributions" {
  default = [
    "bullseye",
    "bookworm",
    "trixie"
  ]
}

target "postgis" {
  matrix = {
    tgt = [
      "standard",
      "system"
    ]
    distro = distributions
    pgVersion = postgreSQLVersions
  }

  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  dockerfile = "cwd://Dockerfile"
  context = "."
  name = "postgis-${replace(getPostgisVersion(distro), ".", "")}-${index(split(".",cleanVersion(pgVersion)),0)}-${tgt}-${distro}"
  tags = [
    "${fullname}:${index(split(".",cleanVersion(pgVersion)),0)}-${getShortPostgisVersion(distro)}-${tgt}-${distro}",
    "${fullname}:${cleanVersion(pgVersion)}-${getPostgisVersion(distro)}-${tgt}-${distro}",
    "${fullname}:${cleanVersion(pgVersion)}-${getPostgisVersion(distro)}-${formatdate("YYYYMMDDhhmm", now)}-${tgt}-${distro}",
  ]
  args = {
    PG_MAJOR = "${getMajor(pgVersion)}"
    POSTGIS_VERSION = "${getPostgisByDistro(distro)}"
    POSTGIS_MAJOR = "${getPostgisMajor(distro)}"
    BASE = "${getBaseImage(pgVersion, tgt, distro)}"
  }
  attest = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
  annotations = [
    "index,manifest:org.opencontainers.image.created=${now}",
    "index,manifest:org.opencontainers.image.url=${url}",
    "index,manifest:org.opencontainers.image.source=${url}",
    "index,manifest:org.opencontainers.image.version=${pgVersion}-${getPostgisVersion(distro)}",
    "index,manifest:org.opencontainers.image.revision=${revision}",
    "index,manifest:org.opencontainers.image.vendor=${authors}",
    "index,manifest:org.opencontainers.image.title=CloudNativePG PostGIS ${pgVersion}-${getPostgisVersion(distro)} ${tgt}",
    "index,manifest:org.opencontainers.image.description=A ${tgt} PostGIS ${pgVersion}-${getPostgisVersion(distro)} container image",
    "index,manifest:org.opencontainers.image.documentation=${url}",
    "index,manifest:org.opencontainers.image.authors=${authors}",
    "index,manifest:org.opencontainers.image.licenses=Apache-2.0",
    "index,manifest:org.opencontainers.image.base.name=${getBaseImage(pgVersion, tgt, distro)}",
  ]
  labels = {
    "org.opencontainers.image.created" = "${now}",
    "org.opencontainers.image.url" = "${url}",
    "org.opencontainers.image.source" = "${url}",
    "org.opencontainers.image.version" = "${pgVersion}",
    "org.opencontainers.image.revision" = "${revision}",
    "org.opencontainers.image.vendor" = "${authors}",
    "org.opencontainers.image.title" = "CloudNativePG PostGIS ${pgVersion}-${getPostgisVersion(distro)} ${tgt}",
    "org.opencontainers.image.description" = "A ${tgt} PostGIS ${pgVersion}-${getPostgisVersion(distro)} container image",
    "org.opencontainers.image.documentation" = "${url}",
    "org.opencontainers.image.authors" = "${authors}",
    "org.opencontainers.image.licenses" = "Apache-2.0"
    "org.opencontainers.image.base.name" = "${getBaseImage(pgVersion, tgt, distro)}"
  }
}

function getBaseImage {
  params = [ pgVersion, imageType, distro ]
  result = format("ghcr.io/cloudnative-pg/postgresql:%s-%s-%s", pgVersion, imageType, distro)
}

function getPostgisByDistro {
  params = [ distro ]
  result = postgisMatrix[distro]
}

function getPostgisMajor {
  params = [ distro ]
  result = index(split(".", getPostgisByDistro(distro)),0)
}

function getPostgisVersion {
  params = [ distro ]
  result = join(".", slice(split(".", split("+", getPostgisByDistro(distro))[0]), 0, 3))
}

function getShortPostgisVersion {
  params = [ distro ]
  result = join(".", slice(split(".", split("+", getPostgisByDistro(distro))[0]), 0, 2))
}
