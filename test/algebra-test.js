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

describe('Algebra test', function () {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;

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
