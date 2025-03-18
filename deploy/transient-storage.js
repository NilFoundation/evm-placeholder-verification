const hre = require('hardhat')
const {getNamedAccounts} = hre

module.exports = async function () {
    console.log("Deploy calls!");
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();

    console.log("Deploy counter");
    let counter_tx = await deploy('TransientStorageDemo', {
      from: deployer,
      log: true,
    });
  
    console.log("Deploy tester");
    let tester_tx = await deploy('TransientStorageTester', {
      from: deployer,
      args: [counter_tx.address],
      log: true,
    });

}

module.exports.tags = ['testTransientStorage']
