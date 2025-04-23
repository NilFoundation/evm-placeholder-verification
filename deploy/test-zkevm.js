const hre = require('hardhat')
const {getNamedAccounts} = hre

module.exports = async function () {
    console.log("Deploy me!");
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const {deployer, tokenOwner} = await getNamedAccounts();

    console.log("Minimal math test")
    await deploy('zkEVMMinimalMath', {
        from: deployer,
        log: true,
    });


    console.log("Modular operations test")
    await deploy('zkEVModularOperations', {
        from: deployer,
        log: true,
    });

    console.log("Memory initialization test")
    await deploy('zkEVMMemInit', {
        from: deployer,
        log: true,
    });

    console.log("Exponentiation test")
    await deploy('zkEVMExp', {
        from: deployer,
        log: true,
    });

    console.log("Signed test")
    let tx = await deploy('zkEVMSigned', {
        from: deployer,
        log: true,
    });
//    let txReciept = await tx.wait(1);
//    console.log("the transaction details are");

    console.log("Precompiles test")
    tx = await deploy('zkEVMPrecompiles', {
        from: deployer,
        log: true,
    });
}

module.exports.tags = ['testZKevmFixture']
