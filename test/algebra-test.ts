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

import { Field3_gas_estiamtion, Field3_gas_estimation__factory } from "../typechain-types";

/* global BigInt */

describe('Algebra test', async function () {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;

    let fge : Field3_gas_estimation;
    let owner;

    before(async () => {
        const signers = await ethers.getSigners();
        owner = signers[0];
        fge = await new Field3_gas_estimation__factory().connect(owner).deploy();
    });

    it("field3 gas measure", async function () {
        //await deployments.fixture(['testFieldMathFixture']);
        //const field3 = await ethers.getContract('field3_gas_estimation');
        //console.log(field3);
        const runs = 20_000;
        await fge.test_add(runs, {gasLimit: 30_500_000});
        await fge.test_sub(runs, {gasLimit: 30_500_000});
        //console.log("⛽Gas used: ", receipt.gasUsed.toNumber());
        /*
        await field3.test_sub(runs, {gasLimit: 30_500_000});
        await field3.test_mul({gasLimit: 30_500_000});
        */
    });

    it("field3 test", async function () {
        await deployments.fixture(['testFieldMathFixture']);
        const field3 = await ethers.getContract('test_field3');
        /*
        await field3.test_add({gasLimit: 30_500_000});
        await field3.test_sub({gasLimit: 30_500_000});
        await field3.test_mul({gasLimit: 30_500_000});
        */
        await field3.test_mulmod_p381({gasLimit: 30_500_000});
        console.log("field3 tests passed");
    });

    it("2pi test", async function () {
        await deployments.fixture(['testFieldMathFixture']);
        const field3 = await ethers.getContract('test_2pi');
        await field3.test_div256({gasLimit: 30_500_000});
        await field3.test_mod256({gasLimit: 30_500_000});
        await field3.test_div512({gasLimit: 30_500_000});
    });


    it("uint512 test", async function () {
        await deployments.fixture(['testFieldMathFixture']);
        const test_uint512 = await ethers.getContract('test_uint512');
        await test_uint512.test_create({gasLimit: 30_500_000});
        await test_uint512.test_add({gasLimit: 30_500_000});
        await test_uint512.test_sub({gasLimit: 30_500_000});
        await test_uint512.test_mul({gasLimit: 30_500_000});
    });

    it("Field math", async function () {
        await deployments.fixture(['testFieldMathFixture']);
        let fieldMath = await ethers.getContract('TestFieldMath');
        await fieldMath.test_log2_ceil({gasLimit: 30_500_000});
    });

    it("Transcript", async function () {
        await deployments.fixture(['testTranscriptFixture']);
        let testTranscript = await ethers.getContract('TestTranscript');
        await testTranscript.test_transcript({gasLimit: 30_500_000});
    });

    it("Polynomial", async function () {
        await deployments.fixture(['testFieldMathFixture']);
        let testPolynomial = await ethers.getContract('TestPolynomial');
        await testPolynomial.test_polynomial_evaluation_aDeg15_bDeg20({gasLimit: 30_500_000});
        await testPolynomial.test_polynomial_addition_aDeg15_bDeg20({gasLimit: 30_500_000});
        await testPolynomial.test_polynomial_multiplication_aDeg15_bDeg20({gasLimit: 30_500_000});
        await testPolynomial.test_lagrange_interpolation_by_2_points_neg_x({gasLimit: 30_500_000});
        await testPolynomial.test_lagrange_interpolation_by_2_points1({gasLimit: 30_500_000});
        await testPolynomial.test_lagrange_interpolation_by_2_points2({gasLimit: 30_500_000});
        await testPolynomial.test_lagrange_interpolate_then_evaluate_by_2_points({gasLimit: 30_500_000});
        // This test goes out of gas / times out
        //await testPolynomial.test_lagrange_interpolation({gasLimit: 80_500_000});
    });
})
