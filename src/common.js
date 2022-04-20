const Web3 = require('web3');
const bip39 = require('bip39');
const {hdkey} = require('ethereumjs-wallet');
const fs = require('fs');

const host = "https://rpc-mumbai.matic.today"
const mnemonic = fs.readFileSync(".secret").toString().trim();
const count = 1;

const web3 = new Web3(new Web3.providers.HttpProvider(
    host
));

function generateAddressesFromSeed(mnemonic, count) {
    let seed = bip39.mnemonicToSeedSync(mnemonic);
    let hdwallet = hdkey.fromMasterSeed(seed);
    let wallet_hdpath = "m/44'/60'/0'/0/";

    let accounts = [];
    for (let i = 0; i < count; i++) {
        let wallet = hdwallet.derivePath(wallet_hdpath + i).getWallet();
        let address = "0x" + wallet.getAddress().toString("hex");
        let privateKey = wallet.getPrivateKey().toString("hex");
        accounts.push({address: address, privateKey: privateKey});
    }
    return accounts;
}

function sendProof(address, abi, proof, privateKey) {
    var contract = new web3.eth.Contract(abi, address);
    // return contract.methods.verify(proof).call({from: generateAddressesFromSeed(mnemonic, count)[0].address}).then(res => {
    //     return true
    // }).catch(res => {
    //     return false
    // });
    var tx = {
        to : "0x9cF57Df512ADf3a14b98a1793106444B9aE999b7",
        gasPrice: web3.utils.toHex(web3.utils.toWei('20', 'gwei')),
        gasLimit: 5500000,
        data: contract.methods.verify(proof).encodeABI()
    }

     return web3.eth.accounts.signTransaction(tx, generateAddressesFromSeed(mnemonic, count)[0].privateKey).then(signed => {
        return web3.eth.sendSignedTransaction(signed.rawTransaction).then(res => {
           return true
        }).catch(res => {
           return false
        });
    });
}

function estimateGas(address, abi, proof) {
    var contract = new web3.eth.Contract(abi, address);

    contract.methods.verify(proof).estimateGas({gas: 5000000}, function (error, gasAmount) {
        if (gasAmount === 5000000) {
            console.log('Method ran out of gas');
        } else {
            console.log(gasAmount);
        }
    });
}

module.exports = {generateAddressesFromSeed, sendProof, estimateGas};
