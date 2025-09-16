fullname = ( environment == "testing") ? "${registry}/postgis-testing" : "${registry}/postgis"
url = "https://github.com/cloudnative-pg/postgis-containers"

variable "postgisMatrix" {
  default = {
    "bullseye" = "3.5.2"
    "bookworm" = "3.6.0"
    "trixie" = "3.6.0"
  }
}

target "postgis" {
  matrix = {
    tgt = [
      "standard",
      "system"
    ]
    distro = [
      "bullseye",
      "bookworm",
      "trixie"
    ]
    pgVersion = postgreSQLVersions
  }

  platforms = [
    "linux/amd64",
    // "linux/arm64"
  ]
  dockerfile = "cwd://Dockerfile"
  context = "."
  name = "postgis-${replace(getPostgisByDistro(distro), ".", "")}-${index(split(".",cleanVersion(pgVersion)),0)}-${tgt}-${distro}"
  tags = [
    "${fullname}:${index(split(".",cleanVersion(pgVersion)),0)}-${getShortPostgisVersion(getPostgisByDistro(distro))}-${tgt}-${distro}",
    "${fullname}:${cleanVersion(pgVersion)}-${getPostgisByDistro(distro)}-${tgt}-${distro}",
    "${fullname}:${cleanVersion(pgVersion)}-${getPostgisByDistro(distro)}-${formatdate("YYYYMMDDhhmm", now)}-${tgt}-${distro}",
  ]
  args = {
    PG_MAJOR = "${getMajor(pgVersion)}"
    POSTGIS_VERSION = "${getPostgisByDistro(distro)}"
    POSTGIS_MAJOR = "${getPostgisMajor(getPostgisByDistro(distro))}"
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
    "index,manifest:org.opencontainers.image.version=${pgVersion}-${getPostgisByDistro(distro)}",
    "index,manifest:org.opencontainers.image.revision=${revision}",
    "index,manifest:org.opencontainers.image.vendor=${authors}",
    "index,manifest:org.opencontainers.image.title=CloudNativePG PostGIS ${pgVersion}-${getPostgisByDistro(distro)} ${tgt}",
    "index,manifest:org.opencontainers.image.description=A ${tgt} PostGIS ${pgVersion}-${getPostgisByDistro(distro)} container image",
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
    "org.opencontainers.image.title" = "CloudNativePG PostGIS ${pgVersion}-${getPostgisByDistro(distro)} ${tgt}",
    "org.opencontainers.image.description" = "A ${tgt} PostGIS ${pgVersion}-${getPostgisByDistro(distro)} container image",
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
  params = [ postgisVersion ]
  result = index(split(".", postgisVersion),0)
}

function getShortPostgisVersion {
  params = [ postgisVersion ]
  result = join(".", slice(split(".", postgisVersion), 0, 2))
}
