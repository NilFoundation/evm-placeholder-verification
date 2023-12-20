const hre = require('hardhat')
const { getNamedAccounts } = hre

module.exports = async function() {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const {deployer, tokenOwner} = await getNamedAccounts();

    await deploy('test_2pi', {
        from: deployer,
        log : true,
    });

    await deploy('test_field3', {
        from: deployer,
        log : true,
    });

    await deploy('field3_gas_estimation', {
        from: deployer,
        log : true,
    });

    await deploy('test_uint512', {
        from: deployer,
        log : true,
    });

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
