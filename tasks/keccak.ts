import {task} from "hardhat/config";
import fs from "fs";
import path from "path";
import losslessJSON from "lossless-json";
import {URL} from "url";
import { expect } from "chai";

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

const keccak = async ()=>{
    let result = {};
    result["eth_accounts"] = {};
    result["accounts"] = {};
    result["blocks"] = {};

    // Step 1. Load ethereum accounts involved in your test
    const signer = await ethers.provider.getSigner();
    const signer_address = await signer.getAddress();
    let eth_account_data = await getEthereumAccount(signer_address);
    result["eth_accounts"][signer_address] = eth_account_data;

    // Step 2. Load contracts involved in your test
    let keccak_contract = await ethers.getContract('zkEVMKeccak');
    result["accounts"][keccak_contract.address] = await getAccount(keccak_contract.address, [
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000000000000000000000000001"
    ]);

    // Step 3. Two transactions in the first block
    {
        let tx1 = await keccak_contract.hash("Hello, world!", {gasLimit: 100_000});
        let tx2 = await keccak_contract.hash("", {gasLimit: 100_000});

        let txReciept1 = await tx1.wait(1);
        let txReciept2 = await tx2.wait(1);

        // console.log(txReciept1["blockHash"]);
        // console.log(txReciept2["blockHash"]);
        // console.log(txReciept3["blockHash"]);

        let trace1 = await getTrace(tx1.hash);
        result["blocks"][txReciept1["blockHash"]] = {};
        result["blocks"][txReciept1["blockHash"]]["transactions"] = {};
        result["blocks"][txReciept1["blockHash"]]["transactions"][tx1.hash] = {};
        result["blocks"][txReciept1["blockHash"]]["transactions"][tx1.hash]["tx"] = tx1;
        result["blocks"][txReciept1["blockHash"]]["transactions"][tx1.hash]["reciept"] = txReciept1;
        result["blocks"][txReciept1["blockHash"]]["transactions"][tx1.hash]["trace"] = trace1;

        let trace2 = await getTrace(tx2.hash);
        if( txReciept2["blockHash"] != txReciept1["blockHash"] ) {
            result["blocks"][txReciept2["blockHash"]] = {};
            result["blocks"][txReciept2["blockHash"]]["transactions"] = {};
        }
        result["blocks"][txReciept2["blockHash"]]["transactions"][tx2.hash] = {};
        result["blocks"][txReciept2["blockHash"]]["transactions"][tx2.hash]["tx"] = tx2;
        result["blocks"][txReciept2["blockHash"]]["transactions"][tx2.hash]["reciept"] = txReciept2;
        result["blocks"][txReciept2["blockHash"]]["transactions"][tx2.hash]["trace"] = trace2;
    }

    // Step 4. One transaction in the second block
    {
        let tx1 = await keccak_contract.hash("0x11223344556677889900aabbccddeeff0011223344556677889900aabbccddeeffgghh", {gasLimit: 100_000});
        let txReciept1 = await tx1.wait(1);
        let trace1 = await getTrace(tx1.hash);
        result["blocks"][txReciept1["blockHash"]] = {};
        result["blocks"][txReciept1["blockHash"]]["transactions"] = {};
        result["blocks"][txReciept1["blockHash"]]["transactions"][tx1.hash] = {};
        result["blocks"][txReciept1["blockHash"]]["transactions"][tx1.hash]["tx"] = tx1;
        result["blocks"][txReciept1["blockHash"]]["transactions"][tx1.hash]["reciept"] = txReciept1;
        result["blocks"][txReciept1["blockHash"]]["transactions"][tx1.hash]["trace"] = trace1;
    }
    console.log(JSON.stringify(result));
}

task("zkevm-keccak")
    .setAction(async (hre) => {
        await keccak();
    });