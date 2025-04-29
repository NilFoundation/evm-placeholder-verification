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

const cold_sstore = async (hre)=>{
    let result = {};
    const signer = await ethers.provider.getSigner();
    const signer_address = await signer.getAddress();

    let eth_accounts = {};
    let accounts = {};

    // Step 1. Load ethereum accounts involved in your test
    let eth_account_data = await getEthereumAccount(signer_address);
    eth_accounts[signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    let dynamic_storage_layout = await ethers.getContract('zkEVMDynamicStorageLayout');
    accounts[dynamic_storage_layout.address] = await getAccount(dynamic_storage_layout.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
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
    let max2 = "0x" + (max_num+BigInt(2)).toString(16).padStart(64, '0');

    eth_accounts = {};
    accounts = {};

    // Step 1. Load ethereum accounts involved in your test
    eth_account_data = await getEthereumAccount(signer_address);
    eth_accounts[signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    dynamic_storage_layout = await ethers.getContract('zkEVMDynamicStorageLayout');
    accounts[dynamic_storage_layout.address] = await getAccount(dynamic_storage_layout.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002",
        max
    ]);

    let tx2 = await dynamic_storage_layout.set(max, 0x123456, {gasLimit: 1_000_000});
    let txReciept2 = await tx2.wait(1);
    blockHash = txReciept2["blockHash"];

    result[blockHash] = await loadBlock(blockHash);
    result[blockHash]["eth_accounts"] = eth_accounts;
    result[blockHash]["accounts"] = accounts;


    eth_accounts = {};
    accounts = {};

    // Step 1. Load ethereum accounts involved in your test
    eth_account_data = await getEthereumAccount(signer_address);
    eth_accounts[signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    dynamic_storage_layout = await ethers.getContract('zkEVMDynamicStorageLayout');
    accounts[dynamic_storage_layout.address] = await getAccount(dynamic_storage_layout.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002",
        max
    ]);

    let tx3 = await dynamic_storage_layout.set(max, 0x7890, {gasLimit: 1_000_000});
    let txReciept3 = await tx3.wait(1);
    blockHash = txReciept3["blockHash"];

    result[blockHash] = await loadBlock(blockHash);
    result[blockHash]["eth_accounts"] = eth_accounts;
    result[blockHash]["accounts"] = accounts;



    eth_accounts = {};
    accounts = {};

    // Step 1. Load ethereum accounts involved in your test
    eth_account_data = await getEthereumAccount(signer_address);
    eth_accounts[signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    dynamic_storage_layout = await ethers.getContract('zkEVMDynamicStorageLayout');
    accounts[dynamic_storage_layout.address] = await getAccount(dynamic_storage_layout.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002",
        max
    ]);

    let tx4 = await dynamic_storage_layout.set(max, 0x7890, {gasLimit: 1_000_000});
    let txReciept4 = await tx4.wait(1);
    blockHash = txReciept4["blockHash"];

    result[blockHash] = await loadBlock(blockHash);
    result[blockHash]["eth_accounts"] = eth_accounts;
    result[blockHash]["accounts"] = accounts;


    eth_accounts = {};
    accounts = {};

    // Step 1. Load ethereum accounts involved in your test
    eth_account_data = await getEthereumAccount(signer_address);
    eth_accounts[signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    dynamic_storage_layout = await ethers.getContract('zkEVMDynamicStorageLayout');
    accounts[dynamic_storage_layout.address] = await getAccount(dynamic_storage_layout.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002",
        max2
    ]);

    let tx5 = await dynamic_storage_layout.add(max2, 0x9876, {gasLimit: 1_000_000});
    let txReciept5 = await tx5.wait(1);
    blockHash = txReciept5["blockHash"];

    result[blockHash] = await loadBlock(blockHash);
    result[blockHash]["eth_accounts"] = eth_accounts;
    result[blockHash]["accounts"] = accounts;

    console.log(JSON.stringify(result));
}

task("zkevm-cold-sstore")
    .setAction(async (hre) => {
        await cold_sstore();
    });