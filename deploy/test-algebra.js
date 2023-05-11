const hre = require('hardhat')
const { getNamedAccounts } = hre

module.exports = async function() {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const {deployer, tokenOwner} = await getNamedAccounts();

    await deploy('TestFieldMath', {
        from: deployer,
        log : true,
    });

    await deploy('TestPolynomial', {
        from: deployer,
        log : true,
    })
}

module.exports.tags = ['testFieldMathFixture']
