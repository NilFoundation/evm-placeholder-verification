require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");

require('@openzeppelin/hardhat-upgrades');

require("hardhat-deploy");
require('hardhat-deploy-ethers');
require('hardhat-contract-sizer');

import "dotenv/config";
import './tasks/modular-test'

const DEFAULT_PRIVATE_KEY = "0x" + "0".repeat(64); // 32 bytes of zeros placeholder to pass config validation

const MUMBAI_PRIVATE_KEY = process.env.MUMBAI_PRIVATE_KEY || DEFAULT_PRIVATE_KEY;
const MUMBAI_ALCHEMY_KEY = process.env.MUMBAI_ALCHEMY_KEY || "";

const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY || DEFAULT_PRIVATE_KEY;
const SEPOLIA_ALCHEMY_KEY = process.env.SEPOLIA_ALCHEMY_KEY || "";

const PRODUCTION_PRIVATE_KEY = process.env.PRODUCTION_PRIVATE_KEY || DEFAULT_PRIVATE_KEY;
const PRODUCTION_ALCHEMY_KEY = process.env.PRODUCTION_ALCHEMY_KEY || "";

const ETHERSCAN_KEY = "ETHERSCAN_KEY"

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        version: "0.8.18",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    namedAccounts: {
        deployer: 0,
    },
    networks: {
        hardhat: {
            blockGasLimit: 100_000_000,
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
        },
        mumbai: {
            url: `https://polygon-mumbai.g.alchemy.com/v2/${MUMBAI_ALCHEMY_KEY}`,
            accounts: [MUMBAI_PRIVATE_KEY]
        }
    },
    etherscan: {
        apiKey: ETHERSCAN_KEY,
    },
    allowUnlimitedContractSize: true,
};
