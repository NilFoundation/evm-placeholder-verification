FROM ubuntu:22.04

WORKDIR /home

# Disable Prompt During Packages Installation
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update

RUN apt install -y cmake

RUN apt install -y build-essential

RUN apt install -y nodejs npm
RUN apt install -y bsdmainutils

RUN apt install -y wget
RUN wget https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.bz2
RUN tar --bzip2 -xf boost_1_76_0.tar.bz2
RUN cd boost_1_76_0 && ./bootstrap.sh && ./b2 && ./b2 install
RUN rm boost_1_76_0.tar.bz2
RUN rm -r boost_1_76_0