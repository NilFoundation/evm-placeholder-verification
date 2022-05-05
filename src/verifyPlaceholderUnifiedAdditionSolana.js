const common = require(__dirname + '/common.js');
const fs = require("fs");
const BN = require("bn.js");

async function verifyPlaceholderUnifiedAddition(proof, mnemonic) {
    const contract_data = JSON.parse(
        fs.readFileSync(__dirname + "/TestPlaceholderVerifierUnifiedAddition.json")
    );

    let contractAdress = contract_data.networks["80001"].address;
    let contractAbi = contract_data.abi;

    const leaf_size = 11;

    let init_params = [];
    // 0) modulus
    // 1) r
    // 2) max_degree
    // 3) leaf_size
    // 4) lambda
    // 5) rows_amount
    // 6) omega
    init_params.push(new BN('28948022309329048855892746252171976963363056481941560715954676764349967630337', 10));
    init_params.push(2);
    init_params.push(7);
    init_params.push(leaf_size);
    init_params.push(1);
    init_params.push(8);
    init_params.push(new BN('199455130043951077247265858823823987229570523056509026484192158816218200659', 10));

    const D_omegas = [];
    D_omegas.push(new BN('199455130043951077247265858823823987229570523056509026484192158816218200659', 10));
    D_omegas.push(new BN('24760239192664116622385963963284001971067308018068707868888628426778644166363', 10));
    init_params.push(D_omegas.length);
    init_params = init_params.concat(D_omegas);

    const q = [];
    q.push(0);
    q.push(0);
    q.push(1);
    init_params.push(q.length);
    init_params = init_params.concat(q);

    const columns_rotations = [];
    for (let i = 0; i < 13; i++) {
        columns_rotations.push([0,]);
    }

    const contract = new common.web3.eth.Contract(contractAbi, contractAdress);

    let encodeABI = contract.methods.verify(proof, init_params, columns_rotations).encodeABI()

    return await common.sendProof(contractAdress, encodeABI, mnemonic);
}

function estimateGasPlaceholderUnifiedAddition(proof) {
    const contract_data = JSON.parse(
        fs.readFileSync(__dirname + "/TestPlaceholderVerifierUnifiedAddition.json")
    );

    contractAdress = contract_data.networks["80001"].address;
    contractAbi = contract_data.abi;

    return common.estimateGas(contractAdress, contractAbi, proof);
}

const mnemonic = fs.readFileSync(process.argv[2]).toString().trim();
var proof = fs.readFileSync(0).toString('utf-8').trim();

const {performance} = require('perf_hooks');

const startTime = performance.now();

verifyPlaceholderUnifiedAddition(proof, mnemonic).then(res => {
    // console.log("Result verify: ", res.verify, ' Gas used:', res.gasUsed)
    fs.appendFileSync('time.log', 'redshift-unified-addition: ' + Math.trunc(performance.now() - startTime).toString() + 'ms ' + res.verify + ' ' + res.gasUsed + '\n');
})


module.exports = {verifyPlaceholderUnifiedAddition, estimateGasPlaceholderUnifiedAddition};