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

const call_large_memory_key = async (hre)=>{
    let result = {};

    // Step 1. Load ethereum accounts involved in your test
    const signer = await ethers.provider.getSigner();
    const signer_address = await signer.getAddress();
    let eth_account_data = await getEthereumAccount(signer_address);
    let eth_accounts = {};
    eth_accounts[signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    let accounts = {};
    let call_large_memory_key = await ethers.getContract('zkEVMCallLargeMemoryKey');
    accounts[call_large_memory_key.address] = await getAccount(call_large_memory_key.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
    ]);
    let large_memory_key = await ethers.getContract('zkEVMLargeMemoryKey');
    accounts[large_memory_key.address] = await getAccount(large_memory_key.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
    ]);

    // Step 3. Run transactions, traces and get receipts
    // We won't fully simulate block logic, because it differs from cluster's
    let tx = await call_large_memory_key.callLargeMemoryKey({gasLimit: 30_000_000});
    let txReciept = await tx.wait(1);
    let blockHash = txReciept["blockHash"];

    result[blockHash] = await loadBlock(blockHash);
    result[blockHash]["eth_accounts"] = eth_accounts;
    result[blockHash]["accounts"] = accounts;

    console.log(JSON.stringify(result));
}

task("zkevm-call-large-memory-key")
    .setAction(async (hre) => {
        await call_large_memory_key();
    });