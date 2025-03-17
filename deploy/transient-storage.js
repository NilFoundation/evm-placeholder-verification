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
    console.log(counter_tx);
  
    console.log("Deploy tester");
    let tester_tx = await deploy('TransientStorageTester', {
      from: deployer,
      args: [counter_tx.address], // Link to the deployed TransientStorageDemo
      log: true,
    });
    console.log(tester_tx);

}

module.exports.tags = ['testTransientStorage']
