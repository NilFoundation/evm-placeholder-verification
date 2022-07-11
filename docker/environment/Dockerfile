FROM ubuntu:22.04

WORKDIR /home

# Disable Prompt During Packages Installation
RUN export DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y ssh \
      build-essential \
      gcc \
      g++ \
      gdb \
      clang \
      make \
      cmake \
      autoconf \
      automake \
      locales-all \
      dos2unix \
      rsync \
      tar \
  && apt-get clean

RUN apt install -y pkg-config libc-ares-dev libfmt-dev liblz4-dev gnutls-dev libprotobuf-dev libyaml-cpp-dev libhwloc-dev libsctp-dev ragel
RUN apt install -y libaio-dev libnuma-dev libpciaccess-dev libcrypto++-dev libxen-dev libxml2-dev xfslibs-dev systemtap-sdt-dev

RUN apt install -y build-essential

RUN apt install -y nodejs npm
RUN apt install -y bsdmainutils

RUN apt install -y wget
RUN wget https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.bz2
RUN tar --bzip2 -xf boost_1_76_0.tar.bz2
RUN cd boost_1_76_0 && ./bootstrap.sh && ./b2 && ./b2 install
RUN rm boost_1_76_0.tar.bz2
RUN rm -r boost_1_76_0