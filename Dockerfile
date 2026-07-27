ARG BASE=ghcr.io/cloudnative-pg/postgresql:17-standard-trixie
FROM $BASE

ARG PG_MAJOR
ARG POSTGIS_VERSION
ARG POSTGIS_MAJOR
ARG PGROUTING_VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        "postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION" \
        "postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION" \
        "postgresql-$PG_MAJOR-pgrouting=$PGROUTING_VERSION" \
        "postgresql-$PG_MAJOR-pgrouting-scripts=$PGROUTING_VERSION" \
    && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/*

USER 26
