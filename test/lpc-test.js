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

describe('LPC tests', function () {
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
        params.init_params.push(BigInt(named_params.omega.value));
        params.init_params.push(BigInt(named_params.D_omegas.length));
        for (i in named_params.D_omegas) {
            params.init_params.push(BigInt(named_params.D_omegas[i].value))
        }
        params.init_params.push(named_params.step_list.length);
        for (i in named_params.step_list) {
            params.init_params.push(BigInt(named_params.step_list[i].value))
        }
        params.init_params.push(named_params.batches_sizes.length);
        for (i in named_params.batches_sizes) {
            params.init_params.push(BigInt(named_params.batches_sizes[i].value))
        }

        params.evaluation_points = [];
        for (let i in named_params.evaluation_points) {
            let ir = []
            for (let j in i)
            {
                let ij = []
                for(let k in j) {
                    ij.push(BigInt(named_params.evaluation_points[i][j][k].value))
                }
                ir.push(ij)
            }
            params.evaluation_points.push(ir)
        }
        return params;
    }

    function getVerifierParams(configPath, proofPath) {
        let params = loadParamsFromFile(path.resolve(__dirname, configPath));
        params['proof'] = fs.readFileSync(path.resolve(__dirname, proofPath), 'utf8');
        return params
    }


    it("Basic verification", async function () {
         let configPath = "./data/lpc_tests/lpc_basic_test.json"
         let proofPath = "./data/lpc_tests/lpc_basic_test.data"
         let params = getVerifierParams(configPath,proofPath);
         await deployments.fixture(['testLPCVerifierFixture']);
         let lpcVerifier = await ethers.getContract('TestLpcVerifier');
         await lpcVerifier.batched_verify(params['proof'], params['init_params'], params['evaluation_points'],{gasLimit: 30_500_000});
    });


    it("Skipping layers verification", async function () {
        let configPath = "./data/lpc_tests/lpc_skipping_layers_test.json"
        let proofPath = "./data/lpc_tests/lpc_skipping_layers_test.data"
        let params = getVerifierParams(configPath,proofPath);
        await deployments.fixture(['testLPCVerifierFixture']);
        let lpcVerifier = await ethers.getContract('TestLpcVerifier');
        await lpcVerifier.batched_verify(params['proof'], params['init_params'], params['evaluation_points'],{gasLimit: 30_500_000});
    });

    it("Batches_num=3 verification", async function () {
        let configPath = "./data/lpc_tests/lpc_batches_num_3_test.json"
        let proofPath = "./data/lpc_tests/lpc_batches_num_3_test.data"
        let params = getVerifierParams(configPath,proofPath);
        await deployments.fixture(['testLPCVerifierFixture']);
        let lpcVerifier = await ethers.getContract('TestLpcVerifier');
        await lpcVerifier.batched_verify(params['proof'], params['init_params'], params['evaluation_points'],{gasLimit: 30_500_000});
    });

    it("Evaluation points verification", async function () {
        let configPath = "./data/lpc_tests/lpc_eval_points_test.json"
        let proofPath = "./data/lpc_tests/lpc_eval_points_test.data"
        let params = getVerifierParams(configPath,proofPath);
        await deployments.fixture(['testLPCVerifierFixture']);
        let lpcVerifier = await ethers.getContract('TestLpcVerifier');
        await lpcVerifier.batched_verify(params['proof'], params['init_params'], params['evaluation_points'],{gasLimit: 30_500_000});
    });

    it("Evaluation point 2 verification", async function () {
        let configPath = "./data/lpc_tests/lpc_eval_point2_test.json"
        let proofPath = "./data/lpc_tests/lpc_eval_point2_test.data"
        let params = getVerifierParams(configPath,proofPath);
        await deployments.fixture(['testLPCVerifierFixture']);
        let lpcVerifier = await ethers.getContract('TestLpcVerifier');
        await lpcVerifier.batched_verify(params['proof'], params['init_params'], params['evaluation_points'],{gasLimit: 30_500_000});
    });

    it("Evaluation point 3 verification", async function () {
        let configPath = "./data/lpc_tests/lpc_eval_point3_test.json"
        let proofPath = "./data/lpc_tests/lpc_eval_point3_test.data"
        let params = getVerifierParams(configPath,proofPath);
        await deployments.fixture(['testLPCVerifierFixture']);
        let lpcVerifier = await ethers.getContract('TestLpcVerifier');
        await lpcVerifier.batched_verify(params['proof'], params['init_params'], params['evaluation_points'],{gasLimit: 30_500_000});
    });

})
