require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");

require('@openzeppelin/hardhat-upgrades');

require("hardhat-deploy");
require('hardhat-deploy-ethers');
require('hardhat-contract-sizer');

import './tasks/minimal_math'
import './tasks/counter'
import './tasks/keccak'
import './tasks/call_counter'
import './tasks/call_keccak'
import './tasks/delegatecall'
import './tasks/indexed_log'
import './tasks/overflow'
import './tasks/dynamic_storage_layout'
import './tasks/try_catch'
import './tasks/transient_storage'
import './tasks/sar'
import './tasks/scmp'
import './tasks/exp'
import './tasks/codecopy'
import './tasks/mem'
import './tasks/modular'
import './tasks/precompiles'
import './tasks/staticcall'

const DEFAULT_PRIVATE_KEY = "0x" + "0".repeat(64); // 32 bytes of zeros placeholder to pass config validation

const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY || DEFAULT_PRIVATE_KEY;
const SEPOLIA_ALCHEMY_KEY = process.env.SEPOLIA_ALCHEMY_KEY || "";

const PRODUCTION_PRIVATE_KEY = process.env.PRODUCTION_PRIVATE_KEY || DEFAULT_PRIVATE_KEY;
const PRODUCTION_ALCHEMY_KEY = process.env.PRODUCTION_ALCHEMY_KEY || "";

const ETHERSCAN_KEY = "ETHERSCAN_KEY"

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        version: "0.8.24",
        settings: {
            optimizer: {
                enabled: false, /* Optimizer disables some opcodes (MSIZE, for example) */
                runs: 200,
            },
            metadata: {
                appendCBOR: false
            },
            evmVersion: "cancun"
        },
    },
    namedAccounts: {
        deployer: 0,
    },
    networks: {
        hardhat: {
            gas: "auto",
            mining: {
                auto: false,
                interval: 1000
            },
            hardfork: "cancun"
        },
        sepolia: {
            url: `https://eth-sepolia.g.alchemy.com/v2/${SEPOLIA_ALCHEMY_KEY}`,
            accounts: [SEPOLIA_PRIVATE_KEY]
        },
        production: {
            url: `https://eth-mainnet.g.alchemy.com/v2/${PRODUCTION_ALCHEMY_KEY}`,
            accounts: [PRODUCTION_PRIVATE_KEY]
        },
        localhost: {
            url: "http://127.0.0.1:8545",
            gas: "auto",
            mining: {
                auto: false,
                interval: 1000
            },
            hardfork: "cancun"
        }
    },
    etherscan: {
        apiKey: ETHERSCAN_KEY,
    },
    allowUnlimitedContractSize: true,
};