const myModule = require('./main.js');
const fs = require("fs");

const contract_data = JSON.parse(
fs.readFileSync("TestRedshiftVerifierUnifiedAddition.json")
);

contractAdress = contract_data.networks["3"].address;
contractAbi = contract_data.abi;

const { performance } = require('perf_hooks');

var startTime = performance.now()

var proof = fs.readFileSync(0).toString('utf-8').trim();

x = myModule.sendProof(contractAdress, contractAbi, proof);

var endTime = performance.now()

let t = x.then(result => {
    if (result === true) {
        fs.appendFileSync('time.log', 'redshift-unified-addition: ' + Math.trunc(endTime - startTime).toString() + 'ms Verified ');
        myModule.estimateGas(contractAdress, contractAbi, proof).then(result => {fs.appendFileSync('time.log', result + '\n')});
        return "Verified!";
    } else {
        fs.appendFileSync('time.log', 'redshift-unified-addition: ' + Math.trunc(endTime - startTime).toString() + 'ms Error ');
        return "Error verified!";
    }
});