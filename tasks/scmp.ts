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

const scmp = async (hre) => {
    let result = {};
    result["eth_accounts"] = {};
    result["accounts"] = {};
    result["blocks"] = {};

    const signer = await ethers.provider.getSigner();
    const signer_address = await signer.getAddress();
    let eth_account_data = await getEthereumAccount(signer_address);
    result["eth_accounts"][signer_address] = eth_account_data;

    let tester;
    try {
        const SCMPTest = await ethers.getContractFactory("TestSCMP");
        tester = await SCMPTest.deploy();
        await tester.deployed();
    } catch (deployError) {
        console.error("Failed to deploy contract:", deployError);
        return;
    }
    result["accounts"][tester.address] = await getAccount(tester.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001",
        "0x0000000000000000000000000000000000000000000000000000000000000002"
    ]);

    const testCases = [
        [3, 3],                
        [-8, 2],             
    ];

    let tx, txReceipt, trace;
    for (const [a, b] of testCases) {
        try {
            tx = await tester.compareSigned(a, b, { gasLimit: 1_000_000 });
            txReceipt = await tx.wait(1);
            trace = await getTrace(tx.hash);
        } catch (error) {
            console.error("Error during transaction:", error);
            if (tx && tx.hash) {
                txReceipt = await ethers.provider.getTransactionReceipt(tx.hash);
                trace = await getTrace(tx.hash);
            } else {
                console.error("No transaction was generated");
            }
        }

        if (tx && txReceipt) {
            result["blocks"][txReceipt["blockHash"]] = result["blocks"][txReceipt["blockHash"]] || {};
            result["blocks"][txReceipt["blockHash"]]["transactions"] = result["blocks"][txReceipt["blockHash"]]["transactions"] || {};
            result["blocks"][txReceipt["blockHash"]]["transactions"][tx.hash] = {};
            result["blocks"][txReceipt["blockHash"]]["transactions"][tx.hash]["tx"] = tx;
            result["blocks"][txReceipt["blockHash"]]["transactions"][tx.hash]["reciept"] = txReceipt;
            result["blocks"][txReceipt["blockHash"]]["transactions"][tx.hash]["trace"] = trace;
        }
    }

    console.log(JSON.stringify(result));
};
  module.exports = scmp;

task("scmp-test")
    .setAction(async (hre) => {
        await scmp();
    });