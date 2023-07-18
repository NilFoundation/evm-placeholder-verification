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

    function loadPublicInput(public_input_path){
        if(fs.existsSync(public_input_path)){
            return losslessJSON.parse(fs.readFileSync(jsonFile, 'utf8'));
        } else 
            return [];
    }

    function getVerifierParams(configPath, proofPath, publicInputPath) {
        let public_input = loadPublicInput(path.resolve(__dirname, publicInputPath));
        let params = loadParamsFromFile(path.resolve(__dirname, configPath));
        params['proof'] = fs.readFileSync(path.resolve(__dirname, proofPath), 'utf8');
        params['public_input'] = public_input;
        return params
    }

    it("Unified Addition", async function () {
        let configPath = "./data/unified_addition/lambda2.json"
        let proofPath = "./data/unified_addition/lambda2.data"
        let publicInputPath = "./data/unified_addition/public_input.json";
        let params = getVerifierParams(configPath,proofPath, publicInputPath);
        await deployments.fixture(['testPlaceholderAPIConsumerFixture', 'unifiedAdditionGateFixture', 'placeholderVerifierFixture']);

        let testPlaceholderAPI = await ethers.getContract('TestPlaceholderVerifier');
        let unifiedAdditionGate = await ethers.getContract('UnifiedAdditionGate');
        let placeholderVerifier = await ethers.getContract('PlaceholderVerifier');
        
        await testPlaceholderAPI.initialize(placeholderVerifier.address);
        await testPlaceholderAPI.verify(
            params['proof'],params['init_params'], 
            params['columns_rotations'], params['public_input'],
            unifiedAdditionGate.address ,{gasLimit: 30_500_000}
        );
    });
})
