fullname = ( environment == "testing") ? "${registry}/postgis-testing" : "${registry}/postgis"
url = "https://github.com/cloudnative-pg/postgis-containers"

postgisVersion = "3.5.2"
postgisMajor = index(split(".", postgisVersion),0)
shortPostgisVersion = join(".", slice(split(".", postgisVersion), 0, 2))


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
  name = "postgis-${replace(postgisVersion, ".", "")}-${index(split(".",cleanVersion(pgVersion)),0)}-${tgt}-${distro}"
  tags = [
    "${fullname}:${index(split(".",cleanVersion(pgVersion)),0)}-${shortPostgisVersion}-${tgt}-${distro}",
    "${fullname}:${cleanVersion(pgVersion)}-${postgisVersion}-${tgt}-${distro}",
    "${fullname}:${cleanVersion(pgVersion)}-${postgisVersion}-${formatdate("YYYYMMDDhhmm", now)}-${tgt}-${distro}",
  ]
  args = {
    PG_MAJOR = "${getMajor(pgVersion)}"
    POSTGIS_VERSION = "${postgisVersion}"
    POSTGIS_MAJOR = "${postgisMajor}"
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
    "index,manifest:org.opencontainers.image.version=${pgVersion}-${postgisVersion}",
    "index,manifest:org.opencontainers.image.revision=${revision}",
    "index,manifest:org.opencontainers.image.vendor=${authors}",
    "index,manifest:org.opencontainers.image.title=CloudNativePG PostGIS ${pgVersion}-${postgisVersion} ${tgt}",
    "index,manifest:org.opencontainers.image.description=A ${tgt} PostGIS ${pgVersion}-${postgisVersion} container image",
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
    "org.opencontainers.image.title" = "CloudNativePG PostGIS ${pgVersion}-${postgisVersion} ${tgt}",
    "org.opencontainers.image.description" = "A ${tgt} PostGIS ${pgVersion}-${postgisVersion} container image",
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
