import {task} from "hardhat/config";
import fs from "fs";
import path from "path";
import losslessJSON from "lossless-json";
import {URL} from "url";
import { expect } from "chai";

const util = require('util')
const getNonce  = async(address) =>{
    const params = {
        method: "eth_getTransactionCount",
        params: [address,"latest"],
        id:"1",
        "jsonrpc":"2.0"
    };
    const options = {
        method: 'POST',
        body: JSON.stringify( params )
    };
    const resp = await fetch( 'http://127.0.0.1:8545/', options )
    const jsoned_resp =  await resp.json()
    const result = await jsoned_resp;
    return result.result;
}

const getBalance  = async(address) =>{
    const params = {
        method: "eth_getBalance",
        params: [address,"latest"],
        id:"1",
        "jsonrpc":"2.0"
    };
    const options = {
        method: 'POST',
        body: JSON.stringify( params )
    };
    const resp = await fetch( 'http://127.0.0.1:8545/', options )
    const jsoned_resp =  await resp.json()
    const result = await jsoned_resp;
    return result.result;
}

const getEthereumAccount  = async(address) =>{
    return {
        address: address,
        balance: await getBalance(address),
        nonce: await getNonce(address),
        storage: {}
    }
}

const getBytecode  = async(address) =>{
    const params = {
        method: "eth_getCode",
        params: [address,"latest"],
        id:"1",
        "jsonrpc":"2.0"
    };
    const options = {
        method: 'POST',
        body: JSON.stringify( params )
    };
    const resp = await fetch( 'http://127.0.0.1:8545/', options )
    const jsoned_resp =  await resp.json()
    const result = await jsoned_resp;
    return result.result;
}

const getAccount  = async(address, keys) =>{
    return {
        address: address,
        balance: await getBalance(address),
        nonce: await getNonce(address),
        bytecode: await getBytecode(address),
        storage: await(getStorageItems(address, keys))
    }
}

const getTrace  = async(tx_hash) =>{
    const params = {
        method: "debug_traceTransaction",
        params: [tx_hash],
        id:"1",
        "jsonrpc":"2.0"
    };
    const options = {
        method: 'POST',
        body: JSON.stringify( params )
    };
    const resp = await fetch( 'http://127.0.0.1:8545/', options )
    const jsoned_resp =  await resp.json()
    const result = await jsoned_resp;
    return result.result;
}

const getStorageAt  = async(address, storageKey) =>{
    const params = {
        method: "eth_getStorageAt",
        params: [address,storageKey, "latest"],
        id:"1",
        "jsonrpc":"2.0"
    };
    const options = {
        method: 'POST',
        body: JSON.stringify( params )
    };
    const resp = await fetch( 'http://127.0.0.1:8545/', options )
    const jsoned_resp =  await resp.json()
    const result = await jsoned_resp;
    return result.result;
}

const getStorageItems = async(address, keys) =>{
    let result = {};
    for(let i = 0; i < keys.length; i++){
        result[keys[i]] = await getStorageAt(address, keys[i]);
    }
    return result;
}

const loadBlock = async(blockHash) => {
    let result = {};
    let block = await ethers.provider.getBlock(blockHash);;
    result["block"] = block;
    result["transactions"] = {};
    for( let i = 0; i < block.transactions.length; i++){
        let tx_hash = block.transactions[i];
        result["transactions"][tx_hash] = {};
        result["transactions"][tx_hash]["tx"] = await ethers.provider.getTransaction(tx_hash);
        result["transactions"][tx_hash]["reciept"] = await ethers.provider.getTransactionReceipt(tx_hash);
        result["transactions"][tx_hash]["trace"] = await getTrace(tx_hash);
    }
    return result;
}

const try_catch = async (hre)=>{
    let result = {};
    let eth_accounts = {};
    let accounts = {};

    // Step 1. Load ethereum accounts involved in your test
    const signer = await ethers.provider.getSigner();
    const signer_address = await signer.getAddress();
    let eth_account_data = await getEthereumAccount(signer_address);
    eth_accounts[signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    let try_catch = await ethers.getContract('zkEVMTryCatch');
    accounts[try_catch.address] = await getAccount(try_catch.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
    ]);
    let revert = await ethers.getContract('zkEVMRevert');
    accounts[revert.address] = await getAccount(revert.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
    ]);
    let counter = await ethers.getContract('zkEVMCounter');
    accounts[counter.address] = await getAccount(counter.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000057"
    ]);

    // Step 3. Run transactions, traces and get receipts
    // We won't fully simulate block logic, because it differs from cluster's
    let tx1 = await try_catch.callInc1({gasLimit: 5_000_000});
    let txReciept1 = await tx1.wait(1);
    let blockHash = txReciept1["blockHash"];

    result[blockHash] = await loadBlock(blockHash);
    result[blockHash]["eth_accounts"] = eth_accounts;
    result[blockHash]["accounts"] = accounts;

    console.log(JSON.stringify(result));
}

const try_catch2 = async (hre)=>{
    let result = {};
    let eth_accounts = {};
    let accounts = {};

    // Step 1. Load ethereum accounts involved in your test
    const signer = await ethers.provider.getSigner();
    const signer_address = await signer.getAddress();
    let eth_account_data = await getEthereumAccount(signer_address);
    eth_accounts[signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    let try_catch = await ethers.getContract('zkEVMTryCatch');
    accounts[try_catch.address] = await getAccount(try_catch.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
    ]);
    let revert = await ethers.getContract('zkEVMRevert');
    accounts[revert.address] = await getAccount(revert.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
    ]);
    let counter = await ethers.getContract('zkEVMCounter');
    accounts[counter.address] = await getAccount(counter.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000057"
    ]);

    // Step 3. Run transactions, traces and get receipts
    // We won't fully simulate block logic, because it differs from cluster's
    let tx1 = await try_catch.callInc2({gasLimit: 5_000_000});
    let txReciept1 = await tx1.wait(1);
    let blockHash = txReciept1["blockHash"];

    result[blockHash] = await loadBlock(blockHash);
    result[blockHash]["eth_accounts"] = eth_accounts;
    result[blockHash]["accounts"] = accounts;

    console.log(JSON.stringify(result));
}

const try_catch_cold = async (hre)=>{
    let result = {};

    // Step 1. Load ethereum accounts involved in your test
    const signer = await ethers.provider.getSigner();
    const signer_address = await signer.getAddress();

    eth_accounts = {};
    accounts = {};
    let eth_account_data = await getEthereumAccount(signer_address);
    eth_accounts[signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    let try_catch = await ethers.getContract('zkEVMTryCatchCold');
    accounts[try_catch.address] = await getAccount(try_catch.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
    ]);
    let revert = await ethers.getContract('zkEVMRevertCold');
    accounts[revert.address] = await getAccount(revert.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
    ]);
    let dynamic_storage_layout = await ethers.getContract('zkEVMDynamicStorageLayout');
    accounts[dynamic_storage_layout.address] = await getAccount(dynamic_storage_layout.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000004"
    ]);

    // Step 3. Run transactions, traces and get receipts
    // We won't fully simulate block logic, because it differs from cluster's
    let tx1 = await dynamic_storage_layout.get_max({gasLimit: 1_000_000});
    let txReciept1 = await tx1.wait(1);
    let blockHash = txReciept1["blockHash"];

    result[blockHash] = await loadBlock(blockHash);
    result[blockHash]["eth_accounts"] = eth_accounts;
    result[blockHash]["accounts"] = accounts;

    let max_num = BigInt(txReciept1.logs[0].data);
    let max = "0x" + (max_num+BigInt(1)).toString(16).padStart(64, '0');

    eth_accounts = {};
    accounts = {};
    eth_account_data = await getEthereumAccount(signer_address);
    eth_accounts[signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    accounts[try_catch.address] = await getAccount(try_catch.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
    ]);
    accounts[revert.address] = await getAccount(revert.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
    ]);
    accounts[dynamic_storage_layout.address] = await getAccount(dynamic_storage_layout.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000004",
        max
    ]);

    let tx2 = await try_catch.access(max, 0x654321, {gasLimit: 30_000_000});
    let txReciept2 = await tx2.wait(1);
    blockHash = txReciept2["blockHash"];

    result[blockHash] = await loadBlock(blockHash);
    result[blockHash]["eth_accounts"] = eth_accounts;
    result[blockHash]["accounts"] = accounts;

    console.log(JSON.stringify(result));
}

task("zkevm-try-catch")
    .setAction(async (hre) => {
        await try_catch();
    });

task("zkevm-try-catch2")
    .setAction(async (hre) => {
        await try_catch2();
    });

task("zkevm-try-catch-cold")
    .setAction(async (hre) => {
        await try_catch_cold();
    });