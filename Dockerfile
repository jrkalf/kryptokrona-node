# // Copyright (c) 2012-2017, The CryptoNote developers, The Bytecoin developers
# // Copyright (c) 2014-2018, The Monero Project
# // Copyright (c) 2018-2019, The TurtleCoin Developers
# // Copyright (c) 2019, The Kryptokrona Developers
# //
# // Please see the included LICENSE file for more information.

ARG ARCH=
FROM ${ARCH}ubuntu:22.04 as build
ARG VERSION=v1.1.3

# install build dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
      build-essential \
      libssl-dev \
      libffi-dev \
      python3-dev \
      gcc-11 \
      g++-11 \
      git \
      cmake \
      librocksdb-dev \
      libboost-all-dev \
      libboost-system1.74.0 \
      libboost-filesystem1.74.0 \
      libboost-thread1.74.0 \
      libboost-date-time1.74.0 \
      libboost-chrono1.74.0 \
      libboost-regex1.74.0 \
      libboost-serialization1.74.0 \
      libboost-program-options1.74.0 \
      libicu70

WORKDIR /usr/src
RUN git clone https://github.com/kryptokrona/kryptokrona.git
WORKDIR /usr/src/kryptokrona
RUN git checkout ${VERSION}

# create the build directory
RUN mkdir build
WORKDIR /usr/src/kryptokrona/build

# build and install
RUN cmake -DCMAKE_CXX_FLAGS="-g0 -O3 -fPIC -std=gnu++17" .. \
    && make -j$(nproc) --ignore-errors service

###
FROM ${ARCH}ubuntu:22.04

ENV PATH "$PATH:/kryptokrona"
ENV NODE_ARGS ""

# Exposing miner-to-node port
EXPOSE 8070

WORKDIR /kryptokrona

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get -y install \
        libffi8 \
        libssl3 \
        librocksdb6.11 \
        libboost-system1.74.0 \
        libboost-filesystem1.74.0 \
        libboost-thread1.74.0 \
        libboost-date-time1.74.0 \
        libboost-chrono1.74.0 \
        libboost-regex1.74.0 \
        libboost-serialization1.74.0 \
        libboost-program-options1.74.0 \
        libicu70 \
    && rm -rf /var/lib/apt/lists/*

# create the directory for the daemon files
RUN mkdir -p /kryptokrona/config

COPY --from=build /usr/src/kryptokrona/build/src/kryptokrona-* .

# --data-dir is binded to a volume - this volume is binded when starting the container
# to start the container follow instructions on readme or in article published by marcus cvjeticanin on https://mjovanc.com
CMD [ "/bin/sh", "-c", "./kryptokrona-service --rpc-legacy-security true --bind-address 0.0.0.0 --bind-port 8070 ${NODE_ARGS}" ]