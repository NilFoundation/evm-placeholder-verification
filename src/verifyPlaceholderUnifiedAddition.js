const common = require('./common.js');
const fs = require("fs");

async function verifyPlaceholderUnifiedAddition(proof) {
    const contract_data = JSON.parse(
        fs.readFileSync("TestPlaceholderVerifierUnifiedAddition.json")
    );

    contractAdress = contract_data.networks["80001"].address;
    contractAbi = contract_data.abi;

    x = await common.sendProof(contractAdress, contractAbi, proof);
    return x;
}

// file = process.argv[2];
//
// var text = fs.readFileSync(file).toString('utf-8');
// text = text.slice(0, -1);
// x = verifyPlaceholderUnifiedAddition(text);

module.exports = {verifyPlaceholderUnifiedAddition: verifyPlaceholderUnifiedAddition};