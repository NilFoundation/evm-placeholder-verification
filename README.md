# EVM Placeholder Proof System Verifier 

[![Discord](https://img.shields.io/discord/969303013749579846.svg?logo=discord&style=flat-square)](https://discord.gg/KmTAEjbmM3)
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=flat-square&logo=telegram&logoColor=dark)](https://t.me/nilfoundation)
[![Twitter](https://img.shields.io/twitter/follow/nil_foundation)](https://twitter.com/nil_foundation)

This repository contains the smart contracts for validating zero knowledge proofs 
generated in placeholder proof system in EVM. 

## Dependencies

- [Hardhat](https://hardhat.org/)
- [nodejs](https://nodejs.org/en/) >= 16.0


## Clone
```
git clone git@github.com:NilFoundation/evm-placeholder-verification.git
cd evm-placeholder-verification
```

## Install dependency packages
```
npm i
```

## Compile contracts
```
npx hardhat compile
```

## Test
```
npx hardhat test #Execute tests
REPORT_GAS=true npx hardhat test # Test with gas reporting
```

## Deploy

Launch a local-network using the following
```
npx hardhat node
```

To deploy to test environment (ex: Ganache)
```
npx hardhat deploy  --network localhost 
```

Hardhat re-uses old deployments, to force re-deploy add the `--reset` flag above


# Warp Instructions

Clone the warp transpiler repository
```
git clone git@github.com:NethermindEth/warp.git
cd warp
```

## Launch the test network

Check if this is the right docker file contents (not commited to develop on warp yet)

```
version: '3.8'

services:
  warp:
    image: nethermind/warp:v2.5.1
    links:
      - devnet
    volumes:
      - .:/dapp
    environment:
      - STARKNET_NETWORK=alpha-goerli
      - STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount
      - STARKNET_GATEWAY_URL=http://devnet:5050
      - STARKNET_FEEDER_GATEWAY_URL=http://devnet:5050
    entrypoint: tail -F anything

  devnet:
    image: shardlabs/starknet-devnet:0.4.4-seed0
    ports:
      - '5050:5050'
```

Bring up docker containers

```
docker-compose up
```

## Bash into docker
Find the container id and bash into the warp container.

```shell
➜  warp git:(develop) ✗ docker ps -a
CONTAINER ID   IMAGE                                   COMMAND                  CREATED        STATUS                    PORTS                                       NAMES
9f156f579a4e   nethermind/warp:v2.5.1                  "tail -F anything"       24 hours ago   Up 24 seconds                                                         warp2-warp-1
69c639ee81e8   shardlabs/starknet-devnet:0.4.4-seed0   "starknet-devnet --h…"   24 hours ago   Up 24 seconds             0.0.0.0:5050->5050/tcp, :::5050->5050/tcp   warp2-devnet-1
➜  warp2 git:(develop) ✗ docker exec -it 9f156f579a4e /bin/bash
```

All interactions here on are carried out in the docker environment.

### Create an account

You need to create an account and fund it and deploy it before being able to deploy contracts/test.

```
starknet new_account --feeder_gateway_url http://devnet:5050 --gateway_url http://devnet:5050
```

Add some tokens to your address.
```
curl http://devnet:5050/mint -H "Content-Type: application/json" -d '{"amount": 1000000000000000000, "address": "<account-address>"}'
```

Deploy the account

```
starknet deploy_account --feeder_gateway_url http://devnet:5050 --gateway_url http://devnet:5050
```

If you get a below error

```
Error: 
BadRequest: HTTP error ocurred. Status: 500. 
Text: {"code":"StarknetErrorCode.UNINITIALIZED_CONTRACT","message":"Requested contract 
address 0x7b66ab9b86126568a44856c1a548977b11ad67f18c760b02d83e9ed14bca134 is not deployed."}
```

This could happen if your account was not funded. Try re-funding and re-deploying but this needs
a force flag.

```
starknet deploy_account --feeder_gateway_url http://devnet:5050 --gateway_url http://devnet:5050 --force
```


## Transpiling/Compiling/Deploying

## Transpiling contracts

```
warp transpile exampleContracts/ERC20.sol
```

Transpilation outputs to `warp_output/exampleContracts/ERC20.sol/` or similar directories based on
your contract name.

## Compile

```
root@9f156f579a4e:/dapp# warp compile warp_output/exampleContracts/ERC20.sol/WARP.cairo
Running starknet compile with cairoPath /usr/src/warp-stable
starknet-compile output written to warp_output/exampleContracts/ERC20.sol/WARP_compiled.json
```

Compilation outputs a json file

### Deploy

Deployment on testnet is done via the following two steps

1. Create a class hash
```
 starknet declare --contract WARP_compiled.json --feeder_gateway_url http://devnet:5050 --gateway_url http://devnet:5050
```

2. Deploy
```
starknet deploy --class_hash 0x5c341f52e9284d3a3925440ce43d1a825962d26e82731997cd3b3aedec81b3f  --gateway_url http://devnet:5050  --feeder_gateway_url http://devnet:5050
```






## Community

Issue reports are preferred to be done with Github Issues in here: https://github.com/NilFoundation/evm-placeholder-verification/issues.

Usage and development questions are preferred to be asked in a Telegram chat: https://t.me/nilfoundation or in Discord (https://discord.gg/KmTAEjbmM3)