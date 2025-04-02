# // Copyright (c) 2012-2017, The CryptoNote developers, The Bytecoin developers
# // Copyright (c) 2014-2018, The Monero Project
# // Copyright (c) 2018-2019, The TurtleCoin Developers
# // Copyright (c) 2019, The Kryptokrona Developers
# //
# // Please see the included LICENSE file for more information.

# this docker file can be used for the blockchain node daemon.

ARG ARCH=
FROM ${ARCH}ubuntu:22.04 AS build
ARG VERSION=v.1.1.7

# install build dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -yqq update \
    && apt-get upgrade -yqq \
    && apt-get install -yqq \
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
    && make -j$(nproc) --ignore-errors kryptokronad

###
FROM ${ARCH}ubuntu:22.04

ENV PATH "$PATH:/kryptokrona"
ENV NODE_ARGS ""

# Exposing outside-to-node port
EXPOSE 11898
EXPOSE 11897

WORKDIR /kryptokrona

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -yqq update \
    && apt-get upgrade -yqq \
    && apt-get install -yqq \
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
    && apt-get clean -yqq \
    && apt-get autoremove -yqq \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /kryptokrona/blockloc

COPY --from=build /usr/src/kryptokrona/build/src/kryptokronad .
RUN chmod +x kryptokronad

# --data-dir is binded to a volume - this volume is binded when starting the container
# to start the container follow instructions on readme or in article published by marcus cvjeticanin on https://mjovanc.com
# The --data-dir should be inputted via the NODE_ARGS variable
CMD [ "/bin/sh", "-c", "./kryptokronad --enable-cors=* --rpc-bind-ip=0.0.0.0 --rpc-bind-port=11898 ${NODE_ARGS}" ]
