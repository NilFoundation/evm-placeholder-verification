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
})
