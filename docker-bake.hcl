fullname = ( environment == "testing") ? "${registry}/postgis-testing" : "${registry}/postgis"
url = "https://github.com/cloudnative-pg/postgis-containers"

// MANUALLY EDIT THE CONTENT - to add new PostGIS major version
variable "postgisMajorVersions" {
  default = [
    "3"
  ]
}

// PostGIS matrix of distro x versions
postgisMatrix = {
  bookworm = {
    // renovate: suite=bookworm-pgdg depName=postgresql-postgis
    "3" = "3.7.0+dfsg-1.pgdg12+1"
  }
  trixie = {
    // renovate: suite=trixie-pgdg depName=postgresql-postgis
    "3" = "3.7.0+dfsg-1.pgdg13+1"
  }
}

// PgRouting matrix of distro x versions
// Unlike postgis pgrouting has no major-version selector, so this is a plain distro -> version map.
pgRoutingMatrix = {
  // renovate: suite=bookworm-pgdg depName=postgresql-pgrouting
  "bookworm" = "4.0.2-1.pgdg12+1"
  // renovate: suite=trixie-pgdg depName=postgresql-pgrouting
  "trixie" = "4.0.2-1.pgdg13+1"
}

// address_standardizer and the tiger geocoder are separate packages since PostGIS 3.7.
// The PostgreSQL major in depName is only a Renovate lookup key: every major has the same version.
addressStandardizerMatrix = {
  // renovate: suite=bookworm-pgdg depName=postgresql-18-address-standardizer
  "bookworm" = "3.7.0-1.pgdg12+1"
  // renovate: suite=trixie-pgdg depName=postgresql-18-address-standardizer
  "trixie" = "3.7.0-1.pgdg13+1"
}

// Packaged for PostgreSQL 16 and later only.
tigerGeocoderMatrix = {
  // renovate: suite=bookworm-pgdg depName=postgresql-18-postgis-tiger-geocoder
  "bookworm" = "2025.2-1.pgdg12+1"
  // renovate: suite=trixie-pgdg depName=postgresql-18-postgis-tiger-geocoder
  "trixie" = "2025.2-1.pgdg13+1"
}

variable "distributions" {
  default = [
    "bookworm",
    "trixie"
  ]
}

variable "imageTypes" {
  default = [
    "standard",
    "system"
  ]
}

target "postgis" {
  matrix = {
    tgt = imageTypes
    distro = distributions
    postgisMajor = postgisMajorVersions
    pgVersion = getPgVersions(postgreSQLVersions, postgreSQLPreviewVersions)
  }

  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  dockerfile = "cwd://Dockerfile"
  context = "."
  name = "postgis-${postgisMajor}-${index(split(".",cleanVersion(pgVersion)),0)}-${tgt}-${distro}"
  tags = [
    "${fullname}:${index(split(".",cleanVersion(pgVersion)),0)}-${postgisMajor}-${tgt}-${distro}",
    "${fullname}:${index(split(".",cleanVersion(pgVersion)),0)}-${getShortPostgisVersion(distro, postgisMajor)}-${tgt}-${distro}",
    "${fullname}:${cleanVersion(pgVersion)}-${getPostgisVersion(distro, postgisMajor)}-${tgt}-${distro}",
    "${fullname}:${cleanVersion(pgVersion)}-${getPostgisVersion(distro, postgisMajor)}-${formatdate("YYYYMMDDhhmm", now)}-${tgt}-${distro}",
  ]
  args = {
    PG_MAJOR = "${getMajor(pgVersion)}"
    POSTGIS_VERSION = "${getPostgisPackage(distro, postgisMajor)}"
    POSTGIS_MAJOR = postgisMajor
    PGROUTING_VERSION = "${getPgRoutingPackage(distro)}"
    ADDRESS_STANDARDIZER_VERSION = "${addressStandardizerMatrix[distro]}"
    TIGER_GEOCODER_VERSION = "${tigerGeocoderMatrix[distro]}"
    BASE = "${getBaseImage(pgVersion, tgt, distro)}"
  }
  output = [
    "type=image,oci-mediatypes=true,oci-artifact=true",
  ]
  attest = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
  annotations = [
    "index,manifest:org.opencontainers.image.created=${now}",
    "index,manifest:org.opencontainers.image.url=${url}",
    "index,manifest:org.opencontainers.image.source=${url}",
    "index,manifest:org.opencontainers.image.version=${pgVersion}-${getPostgisVersion(distro, postgisMajor)}",
    "index,manifest:org.opencontainers.image.revision=${revision}",
    "index,manifest:org.opencontainers.image.vendor=${authors}",
    "index,manifest:org.opencontainers.image.title=CloudNativePG PostGIS ${pgVersion}-${getPostgisVersion(distro, postgisMajor)} ${tgt}",
    "index,manifest:org.opencontainers.image.description=A ${tgt} PostGIS ${pgVersion}-${getPostgisVersion(distro, postgisMajor)} container image",
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
    "org.opencontainers.image.title" = "CloudNativePG PostGIS ${pgVersion}-${getPostgisVersion(distro, postgisMajor)} ${tgt}",
    "org.opencontainers.image.description" = "A ${tgt} PostGIS ${pgVersion}-${getPostgisVersion(distro, postgisMajor)} container image",
    "org.opencontainers.image.documentation" = "${url}",
    "org.opencontainers.image.authors" = "${authors}",
    "org.opencontainers.image.licenses" = "Apache-2.0"
    "org.opencontainers.image.base.name" = "${getBaseImage(pgVersion, tgt, distro)}"
  }
}

function getBaseImage {
  params = [ pgVersion, imageType, distro ]
  result = format("ghcr.io/cloudnative-pg/postgresql:%s-%s-%s", cleanVersion(pgVersion), imageType, distro)
}

function getPostgisPackage {
  params = [distro, postgisMajor]
  result = postgisMatrix[distro][postgisMajor]
}

// Gets the MM.mm.pp postgis version, e.g. "3.6.0"
function getPostgisVersion {
  params = [ distro, postgisMajor ]
  result = join(".", slice(split(".", split("+", getPostgisPackage(distro, postgisMajor))[0]), 0, 3))
}

// Gets the MM.mm postgis version, e.g. "3.6"
function getShortPostgisVersion {
  params = [ distro, postgisMajor ]
  result = join(".", slice(split(".", split("+", getPostgisPackage(distro, postgisMajor))[0]), 0, 2))
}

function getPgRoutingPackage {
  params = [distro]
  result = pgRoutingMatrix[distro]
}
