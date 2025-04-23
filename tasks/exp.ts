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

const exp = async (hre) => {
    let result = {};

    let tester = await ethers.getContract('zkEVMExp');
    if( !tester ) {
        console.log("Contract not found");
        return;
    }

    const testCases = [
        [3n, [0n, 1n, 2n, 0x12334n, 2n ** 255n - 1n]],
        [2n ** 255n - 1n, [1n, 2n]]
    ];

    let tx, txReceipt, trace;
    for (const [a, b] of testCases) {
        let ethereum_accounts = {};
        let accounts = {};

        const signer = await ethers.provider.getSigner();
        const signer_address = await signer.getAddress();
        let eth_account_data = await getEthereumAccount(signer_address);
        ethereum_accounts[signer_address] = eth_account_data;

        accounts[tester.address] = await getAccount(tester.address, [
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "0x0000000000000000000000000000000000000000000000000000000000000001",
            "0x0000000000000000000000000000000000000000000000000000000000000002"
        ]);

        try {
            tx = await tester.test_exp(a, b, { gasLimit: 30_000_000 });
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
            let blockHash = txReceipt["blockHash"];
            result[blockHash] = await loadBlock(blockHash);
            result[blockHash]["eth_accounts"] = ethereum_accounts;
            result[blockHash]["accounts"] = accounts;
        }
    }

    console.log(JSON.stringify(result));
};
module.exports = exp;

task("zkevm-exp")
    .setAction(async (hre) => {
        await exp();
    });