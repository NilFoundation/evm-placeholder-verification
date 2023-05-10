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

        params.evaluation_points = [[[]]];
        for (i in named_params.evaluation_points) {
            params.init_params.push(BigInt(named_params.evaluation_points[i].value))
        }
        return params;
    }

    function getVerifierParamsV2() {
        let params = loadParamsFromFile(path.resolve(__dirname, "./data/lpc_tests/lpc_basic_test.json"));
        console.log(params)
        params['proof'] = fs.readFileSync(path.resolve(__dirname, "./data/lpc_tests/lpc_basic_test.data"), 'utf8');

        return params
    }


    describe('T1', function () {
        it("LPCT1 ", async function () {

            let params = getVerifierParamsV2();
            console.log(params['init_params'])
            console.log(params['evaluation_points'])
//            await deployments.fixture(['testLPCVerifierFixture']);
  //          let lpcVerifier = await ethers.getContract('TestLpcVerifier');
//            await lpcVerifier.batched_verify(params['proof'], params['init_params'], params['evaluation_points']);
        });
    })
})
