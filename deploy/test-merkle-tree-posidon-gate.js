const hre = require('hardhat')
const { getNamedAccounts } = hre

module.exports = async function() {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const {deployer, tokenOwner} = await getNamedAccounts();

    let libs = [
        // "contracts/test/merkle_tree_poseidon/gate0.sol:gate0",
        // "contracts/test/merkle_tree_poseidon/gate2.sol:gate2",
        // "contracts/test/merkle_tree_poseidon/gate4.sol:gate4",
        // "contracts/test/merkle_tree_poseidon/gate6.sol:gate6",
        // "contracts/test/merkle_tree_poseidon/gate8.sol:gate8",
        // "contracts/test/merkle_tree_poseidon/gate10.sol:gate10"
        "merkle_tree_poseidon_gate0",
        "merkle_tree_poseidon_gate2",
        "merkle_tree_poseidon_gate4",
        "merkle_tree_poseidon_gate6",
        "merkle_tree_poseidon_gate8",
        "merkle_tree_poseidon_gate10"
    ]

    let deployedLib = {}
    for (let lib of libs){
        await deploy(lib, {
            from: deployer,
            log: true,
        });
        deployedLib[lib] = (await hre.deployments.get(lib)).address
    }

    await deploy('MerkleTreePoseidonGate', {
        from: deployer,
        libraries : deployedLib,
        log : true,
    })
}

module.exports.tags = ['merkleTreePoseidonGateFixture']
