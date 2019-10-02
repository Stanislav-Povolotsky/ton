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

ARG EX_BUILD_ARGS

RUN \
    export EX_BUILD_ARGS="${EX_BUILD_ARGS}" && \
    echo Using additional build arguments: ${EX_BUILD_ARGS} 1>&2 && \
    chmod +x /var/ton/src/_sp/docker/build/build.all.sh && \
    /bin/bash -c /var/ton/src/_sp/docker/build/build.all.sh

# ---------------------------------------------------------------------
# Production env

FROM ubuntu:18.04

# Packages required to run TON
RUN \
    apt-get update && \
    apt-get install -y libmicrohttpd12 libssl1.1 libreadline7 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/ton/bin
ENV PATH="${PATH}:/var/ton/bin"
ENV FIFTPATH="/var/ton/src/crypto/fift/lib/"

COPY --from=build-env /var/ton /var/ton

CMD ["/var/ton/run/autorun.sh"]
