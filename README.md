# EVM Placeholder proof system verifier

[![Discord](https://img.shields.io/discord/969303013749579846.svg?logo=discord&style=flat-square)](https://discord.gg/KmTAEjbmM3)
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=flat-square&logo=telegram&logoColor=dark)](https://t.me/nilfoundation)
[![Twitter](https://img.shields.io/twitter/follow/nil_foundation)](https://twitter.com/nil_foundation)

An application for in-EVM validation of zero-knowledge proofs generated
with
the [Placeholder proof system](https://nil.foundation/blog/post/placeholder-proofsystem).

## Dependencies

- [Hardhat](https://hardhat.org/)
- [Node.js](https://nodejs.org/) - Hardhat requires an LTS version of Node.js; as of September 2023 it's v18

## Contract Addresses

| Network      | Address |
| ----------- | ----------- |
| Sepolia      | [`0x489dbc0762b3d9bd9843db11eecd2a177d84ba2b`](https://sepolia.etherscan.io/address/0x489dbc0762b3d9bd9843db11eecd2a177d84ba2b)      |

## Installing with npm

You can install the package via `npm` from the command line:

```bash
npm install @nilfoundation/evm-placeholder-verification@1.1.1
```

or add it to the `package.json` file manually:

```json
"@nilfoundation/evm-placeholder-verification": "1.1.1"
```

## Contributing

Clone the project from GitHub:

```bash
git clone git@github.com:NilFoundation/evm-placeholder-verification.git
```

After that, navigate to the `evm-placeholder-verification` directory:

```bash
cd evm-placeholder-verification
```

## Install dependency packages

```bash
npm i
```

## Configure Environment Variables
Before deploying or verifying on-chain, configure your .env for RPC URLs and Private Key. Copy the evm.example file to .env and update it with your details:
```bash
cp env.example .env
# Edit .env to include your private key and RPC URLs
```

## Compile contracts

```bash
npx hardhat compile
```

## Deploy

Launch a local network using the following command:

```bash
npx hardhat node
```

Don't close the terminal and don't finish this process, the Hardhat node should be
running for the next steps.

To deploy to a test environment (Ganache, for example), run the following
from another terminal:

```bash
npx hardhat deploy --network localhost
```

Hardhat reuses old deployments by default; to force re-deploy,
add the `--reset` flag to the command.

## Testing

Tests are located in the `test` directory.
To run tests:

```bash
npx hardhat test # Execute tests
REPORT_GAS=true npx hardhat test # Test with gas reporting
```

## Local verification of zkLLVM circuit compiler output

[zkLLVM compiler](https://github.com/NilFoundation/zkllvm) prepares circuits
as instantiated contracts that can be deployed to a blockchain.

Once you get zkLLVM output, create a circuit directory under `contracts/zkllvm` for your output.
That directory should contain the following files:

```
* proof.bin — Placeholder proof file
* circuit_params.json — parameters file
* public_input.json — file with public input
* linked_libs_list.json — list of external libraries that have to be deployed for gate argument computation
* gate_argument.sol, gate0.sol, ... gateN.sol — Solidity files with gate argument computation
```

If all these files are in place, you can deploy the verifier app and verify the proofs.
You only need to deploy the verifier once, and then you can verify as many proofs as you want.

Deploying the contracts:

```bash
npx hardhat deploy
```

If you've put the files under, let's say, `contracts/zkllvm/circuit-name` directory,
you can verify the proofs with the following:

```bash
npx hardhat verify-circuit-proof --test circuit-name
```

To verify all circuits from `contracts/zkllvm` directory, run:

```bash
npx hardhat verify-circuit-proof-all
```

## Community

Submit your issue reports to the project's [Github Issues](https://github.com/NilFoundation/evm-placeholder-verification/issues).

Join us on our [Discord server](https://discord.gg/KmTAEjbmM3) or in our [Telegram chat](https://t.me/nilfoundation)
and ask your questions about the verifier's usage and development.
