FROM node:18.18-bullseye

ADD . /opt/evm-placeholder-verification

WORKDIR /opt/evm-placeholder-verification

RUN npm install
RUN npx hardhat compile
