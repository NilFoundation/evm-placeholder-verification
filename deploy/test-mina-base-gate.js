const hre = require('hardhat')
const { getNamedAccounts } = hre

module.exports = async function() {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const {deployer, tokenOwner} = await getNamedAccounts();

    let libs = [
        "mina_base_gate0",
        "mina_base_gate4",
        "mina_base_gate7",
        "mina_base_gate10",
        "mina_base_gate13",
        "mina_base_gate15",
        "mina_base_gate16",
        "mina_base_gate16_1"
    ]

    let deployedLib = {}
    for (let lib of libs){
        await deploy(lib, {
            from: deployer,
            log: true,
        });
        deployedLib[lib] = (await hre.deployments.get(lib)).address
    }

    await deploy('MinaBaseGate', {
        from: deployer,
        libraries : deployedLib,
        log : true,
    })
}

module.exports.tags = ['minaBaseGateFixture']
