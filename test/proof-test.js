const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const {anyValue} = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {expect} = require("chai");
const hre = require('hardhat')
const fs = require("fs");
const path = require("path");
const {BigNumber} = require("ethers");
const {getNamedAccounts} = hre
const losslessJSON = require("lossless-json")

/* global BigInt */

describe('Proof Tests', function () {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;

    function loadParamsFromFile(jsonFile) {
        const named_params = losslessJSON.parse(fs.readFileSync(jsonFile, 'utf8'));
        params = {};
        params.init_params = [];
        params.init_params.push(BigInt(named_params.modulus.value));
        params.init_params.push(BigInt(named_params.r.value));
        params.init_params.push(BigInt(named_params.max_degree.value));
        params.init_params.push(BigInt(named_params.lambda.value));
        params.init_params.push(BigInt(named_params.rows_amount.value));
        params.init_params.push(BigInt(named_params.omega.value));
        params.init_params.push(BigInt(named_params.D_omegas.length));
        for (i in named_params.D_omegas) {
            params.init_params.push(BigInt(named_params.D_omegas[i].value))
        }
        params.init_params.push(named_params.step_list.length);
        for (i in named_params.step_list) {
            params.init_params.push(BigInt(named_params.step_list[i].value))
        }
        params.init_params.push(named_params.arithmetization_params.length);
        for (i in named_params.arithmetization_params) {
            params.init_params.push(BigInt(named_params.arithmetization_params[i].value))
        }

        params.columns_rotations = [];
        for (i in named_params.columns_rotations) {
            r = []
            for (j in named_params.columns_rotations[i]) {
                r.push(BigInt(named_params.columns_rotations[i][j].value));
            }
            params.columns_rotations.push(r);
        }
        return params;
    }

    function getVerifierParams(configPath, proofPath) {
        let params = loadParamsFromFile(path.resolve(__dirname, configPath));
        params['proof'] = fs.readFileSync(path.resolve(__dirname, proofPath), 'utf8');
        return params
    }


    it("Unified Addition", async function () {
        let configPath = "./data/unified_addition/lambda2.json"
        let proofPath = "./data/unified_addition/lambda2.data"
        let params = getVerifierParams(configPath,proofPath);
        await deployments.fixture(['testPlaceholderAPIConsumerFixture', 'unifiedAdditionGateFixture', 'placeholderVerifierFixture']);

        let testPlaceholderAPI = await ethers.getContract('TestPlaceholderVerifier');
        let unifiedAdditionGate = await ethers.getContract('UnifiedAdditionGate');
        let placeholderVerifier = await ethers.getContract('PlaceholderVerifier');

        await testPlaceholderAPI.initialize(placeholderVerifier.address);
        await testPlaceholderAPI.verify(params['proof'],params['init_params'], params['columns_rotations'],unifiedAdditionGate.address ,{gasLimit: 30_500_000});
    });

    it("Merkle Tree Poseidon", async function () {
        let configPath = "./data/merkle_tree_poseidon/circuit_params.json"
        let proofPath = "./data/merkle_tree_poseidon/proof.bin"
        let params = getVerifierParams(configPath,proofPath);
        await deployments.fixture(['testPlaceholderAPIConsumerFixture', 'merkleTreePoseidonGateFixture', 'placeholderVerifierFixture']);

        let testPlaceholderAPI = await ethers.getContract('TestPlaceholderVerifier');
        let merkleTreePosidonGate = await ethers.getContract('MerkleTreePoseidonGate');
        let placeholderVerifier = await ethers.getContract('PlaceholderVerifier');

        await testPlaceholderAPI.initialize(placeholderVerifier.address);
        await testPlaceholderAPI.verify(params['proof'],params['init_params'], params['columns_rotations'],merkleTreePosidonGate.address ,{gasLimit: 30_500_000});
    });

    it("Mina Base", async function () {
        let configPath = "./data/mina_base/circuit_params.json"
        let proofPath = "./data/mina_base/proof.bin"
        let params = getVerifierParams(configPath,proofPath);
        await deployments.fixture(['testPlaceholderAPIConsumerFixture', 'minaBaseGateFixture', 'placeholderVerifierFixture']);

        let testPlaceholderAPI = await ethers.getContract('TestPlaceholderVerifier');
        let minaBaseGate = await ethers.getContract('MinaBaseGate');
        let placeholderVerifier = await ethers.getContract('PlaceholderVerifier');

        await testPlaceholderAPI.initialize(placeholderVerifier.address);
        await testPlaceholderAPI.verify(params['proof'],params['init_params'], params['columns_rotations'],minaBaseGate.address ,{gasLimit: 30_500_000});
    });

    it("Mina Scalar", async function () {
        let configPath = "./data/mina_scalar/circuit_params.json"
        let proofPath = "./data/mina_scalar/proof.bin"
        let params = getVerifierParams(configPath,proofPath);
        await deployments.fixture(['testPlaceholderAPIConsumerFixture', 'minaScalarGateFixture', 'placeholderVerifierFixture']);

        let testPlaceholderAPI = await ethers.getContract('TestPlaceholderVerifier');
        let minaScalarGate = await ethers.getContract('MinaScalarGate');
        let placeholderVerifier = await ethers.getContract('PlaceholderVerifier');

        await testPlaceholderAPI.initialize(placeholderVerifier.address);
        await testPlaceholderAPI.verify(params['proof'],params['init_params'], params['columns_rotations'],minaScalarGate.address ,{gasLimit: 30_500_000});
    });

})
