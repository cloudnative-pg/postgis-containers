ARG BASE=ghcr.io/cloudnative-pg/postgresql:17-standard-trixie
FROM $BASE

ARG PG_MAJOR
ARG POSTGIS_VERSION
ARG POSTGIS_MAJOR
ARG PGROUTING_VERSION
ARG ADDRESS_STANDARDIZER_VERSION
ARG TIGER_GEOCODER_VERSION

USER root

# Since PostGIS 3.7 Debian ships address_standardizer and the tiger geocoder
# as separate packages. The tiger geocoder is only packaged for PostgreSQL 16+.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        "postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION" \
        "postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION" \
        "postgresql-$PG_MAJOR-address-standardizer=$ADDRESS_STANDARDIZER_VERSION" \
        "postgresql-$PG_MAJOR-pgrouting=$PGROUTING_VERSION" \
        "postgresql-$PG_MAJOR-pgrouting-scripts=$PGROUTING_VERSION" \
    && \
    if [ "$PG_MAJOR" -ge 16 ]; then \
        apt-get install -y --no-install-recommends \
            "postgresql-$PG_MAJOR-postgis-tiger-geocoder=$TIGER_GEOCODER_VERSION"; \
    fi && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/*

# Extension versions follow PostGIS, except the tiger geocoder, which has its own.
RUN set -eu; \
    ext="/usr/share/postgresql/$PG_MAJOR/extension"; \
    postgis="${POSTGIS_VERSION%%+*}"; \
    short="${postgis%.*}"; \
    check() { grep -q "^default_version = '$2'" "$ext/$1.control" \
        || { echo "ERROR: $1 is not at version $2" >&2; exit 1; }; }; \
    check postgis "$postgis"; \
    check address_standardizer "$short"; \
    check address_standardizer_data_us "$short"; \
    if [ "$PG_MAJOR" -ge 16 ]; then \
        check postgis_tiger_geocoder "${TIGER_GEOCODER_VERSION%%-*}"; \
    fi

USER 26
