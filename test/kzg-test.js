const hre = require('hardhat')

/* global BigInt */

describe('KZG test', function () {
    const {deployments} = hre;

    it("Pairing precompile test", async function () {
        await deployments.fixture(['testKZGVerifierFixture']);
        const v = await ethers.getContract('kzg_estimation');
        let x = await v.verify({gasLimit: 30_500_000});
        console.log(x.gasUsed);
        const receipt = await (await v.test_kzg({gasLimit: 30_500_000})).wait();
        console.log("⛽Gas used: ", receipt.gasUsed.toNumber());
    });
})
