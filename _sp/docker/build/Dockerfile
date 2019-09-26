# Dockerfile by Stanislav Povolotsky (stas.dev<AT>povolotsky.info)

# ---------------------------------------------------------------------
# Builder

FROM ubuntu:18.04 AS build-env

# Packages required to build TON
RUN \
    apt-get update && \
    apt-get install -y cmake clang ninja-build pkg-config libssl-dev zlib1g-dev libreadline-dev gperf libmicrohttpd-dev

COPY \
    . /var/ton/src

WORKDIR /var/ton/

RUN \
    /var/ton/src/_sp/docker/build/build.all.sh

# ---------------------------------------------------------------------
# Production env

FROM ubuntu:18.04

# Packages required to run TON
RUN \
    apt-get update && \
    apt-get install -y libmicrohttpd12 libssl1.1 libreadline7 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/ton/bin

COPY --from=build-env /var/ton /var/ton

CMD ["/var/ton/run/autorun.sh"]
