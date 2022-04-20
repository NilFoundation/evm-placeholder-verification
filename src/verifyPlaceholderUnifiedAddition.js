const common = require('./common.js');
const fs = require("fs");

function verifyPlaceholderUnifiedAddition(proof) {
    const contract_data = JSON.parse(
        fs.readFileSync("TestPlaceholderVerifierUnifiedAddition.json")
    );

    contractAdress = contract_data.networks["3"].address;
    contractAbi = contract_data.abi;

    x = common.sendProof(contractAdress, contractAbi, proof);
    x.then(result => {
        if (result === true) {
            console.log("Verified");
            return "Verified!";
        } else {
            console.log("Error verified");
            return "Error verified!";
        }
    });
}

// file = process.argv[2];
//
// var text = fs.readFileSync(file).toString('utf-8');
// text = text.slice(0, -1);
// x = verifyPlaceholderUnifiedAddition(text);

module.exports = {verifyPlaceholderUnifiedAddition: verifyPlaceholderUnifiedAddition};