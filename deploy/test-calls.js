const hre = require('hardhat')
const {getNamedAccounts} = hre

module.exports = async function () {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const {deployer, tokenOwner} = await getNamedAccounts();

    console.log("Deploy counter")
    let counter_tx = await deploy('zkEVMCounter', {
        from: deployer,
        log: true,
    });

    console.log("Deploy call counter")
    let call_counter_tx = await deploy("zkEVMCallCounter", {
        from: deployer,
        log: true,
        args: [counter_tx.address]
    });

    console.log("Deploy revert")
    let revert_tx = await deploy("zkEVMRevert", {
        from: deployer,
        log: true,
        args: [counter_tx.address]
    });

    console.log("Deploy try-catching")
    let try_catch_tx = await deploy("zkEVMTryCatch", {
        from: deployer,
        log: true,
        args: [counter_tx.address, revert_tx.address]
    });

    console.log("Deploy dynamic storage layout contract")
    let dynamic_storage_tx = await deploy("zkEVMDynamicStorageLayout", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy arithmetic overflow tests")
    let dynanmic_storage_tx = await deploy("zkEVMOverflow", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy DELEGATECALL example")
    let delegatecall_tx = await deploy("zkEVMDelegateCall", {
        from: deployer,
        log: true,
        args: [counter_tx.address]
    });

    console.log("Deploy indexed logs example")
    let indexed_logs_tx = await deploy("zkEVMIndexedLog", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy revert cold access")
    let revert_cold_tx = await deploy("zkEVMRevertCold", {
        from: deployer,
        log: true,
        args: [dynamic_storage_tx.address]
    });

    console.log("Deploy revert cold access try catch")
    let try_catch_cold_tx = await deploy("zkEVMTryCatchCold", {
        from: deployer,
        log: true,
        args: [dynamic_storage_tx.address, revert_cold_tx.address]
    });

    console.log("Deploy keccak and calldatacopy example")
    let keccak_tx = await deploy("zkEVMKeccak", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy keccak caller to test calldata inside CALLS")
    let call_keccak_tx = await deploy("zkEVMCallKeccak", {
        from: deployer,
        log: true,
        args: [keccak_tx.address]
    });

    console.log("Deploy exponentiation test")
    let exp_tx = await deploy("zkEVMExp", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy codecopy test")
    let code_copy_tx = await deploy("MinimalCodeCopy", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy memory test")
    let meminit_tx = await deploy("zkEVMMemInit", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy modular test")
    let modular_tx = await deploy("zkEVMModular", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy precompiles test")
    let precompiles_tx = await deploy("zkEVMPrecompiles", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy exponentiator for staticcall testing")
    let exponentiator_tx = await deploy("zkEVMExponentiator", {
        from: deployer,
        log: true,
        args: [3]
    });

    console.log("Deploy staticcall test")
    let staticcall_tx = await deploy("zkEVMStaticCall", {
        from: deployer,
        log: true,
        args: [exponentiator_tx.address]
    });

    console.log("Deploy large calldata key test")
    let large_calldata_tx = await deploy("zkEVMLargeCalldataKey", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy large memory key test")
    let large_memory_tx = await deploy("zkEVMLargeMemoryKey", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy call large mload key test")
    let call_large_memory_tx = await deploy("zkEVMCallLargeMemoryKey", {
        from: deployer,
        log: true,
        args: [large_memory_tx.address]
    });

    console.log("Deploy large mstore key test")
    let large_mstore_tx = await deploy("zkEVMLargeMstoreKey", {
        from: deployer,
        log: true,
        args: []
    });

    console.log("Deploy call large mload key test")
    let call_large_mstore_tx = await deploy("zkEVMCallLargeMstoreKey", {
        from: deployer,
        log: true,
        args: [large_mstore_tx.address]
    });
}

module.exports.tags = ['testZKevmFixture']
