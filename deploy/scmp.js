const hre = require('hardhat')
const {getNamedAccounts} = hre

module.exports = async function () {
    console.log("Deploy calls!");
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    console.log("Deploy scmp");
    let counter_tx = await deploy('TestSCMP', {
      from: deployer,
      log: true,
    });


}

module.exports.tags = ['testSCMP']
