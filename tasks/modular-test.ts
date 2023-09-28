import {task} from "hardhat/config";
import fs from "fs";
import path from "path";
import losslessJSON from "lossless-json";

function get_subfolders(dir) {
    const files = fs.readdirSync(dir, { withFileTypes: true });
    const result = [];

    for (const file of files) {
        if (file.isDirectory()) {
            result.push(file.name);
        } 
    }
    return result;
}

function loadProof(proof_path){
    return fs.readFileSync(path.resolve(__dirname, proof_path), 'utf8');
}
  

task("modular-tests")
    .setAction(async (hre) => {
        console.log("Verify proof in modular style");
        let modular_path = "../contracts/modular/";
        let circuits = get_subfolders(path.resolve(__dirname, modular_path));
//        await deployments.fixture(['ModularVerifierFixture']);

        for(const k in circuits){
            let circuit = circuits[k];
            let folder_path = modular_path + circuit;
            await deployments.fixture(['ModularVerifierFixture']);
//            const permutation_argument_contract = await ethers.getContract("modular_permutation_argument_"+circuit);
            const lookup_argument_contract = await ethers.getContract("modular_lookup_argument_"+circuit);
            const gate_argument_contract = await ethers.getContract("modular_gate_argument_"+circuit);
            const commitment_contract = await ethers.getContract("modular_commitment_scheme_"+circuit);

            const verifier_contract = await ethers.getContract("modular_verifier_"+circuit);
            await verifier_contract.initialize(
//                permutation_argument_contract.address,
                lookup_argument_contract.address,
                gate_argument_contract.address,
                commitment_contract.address
            );

            let proof_path = folder_path + "/proof.bin";
            console.log("Verify :",proof_path);
            let proof  = loadProof(proof_path);
            await verifier_contract.verify(proof, {gasLimit: 30_500_000});
            console.log("====================================");

//            proof_path = folder_path + "/proof2.bin";
//            console.log("Verify :",proof_path);
//            proof  = loadProof(proof_path);
//            await verifier_contract.verify(proof, {gasLimit: 30_500_000});

        }
});

task("modular-test")
    .addParam("test")
    .setAction(async (test, hre) => {
        console.log("Run modular verifier for:",test.test);
        let modular_path = "../contracts/modular/";

        let circuit = test.test;
        let folder_path = modular_path + circuit;
        await deployments.fixture(['ModularVerifierFixture']);
//            const permutation_argument_contract = await ethers.getContract("modular_permutation_argument_"+circuit);
        const lookup_argument_contract = await ethers.getContract("modular_lookup_argument_"+circuit);
        const gate_argument_contract = await ethers.getContract("modular_gate_argument_"+circuit);
        const commitment_contract = await ethers.getContract("modular_commitment_scheme_"+circuit);

        const verifier_contract = await ethers.getContract("modular_verifier_"+circuit);
        await verifier_contract.initialize(
//                permutation_argument_contract.address,
            lookup_argument_contract.address,
            gate_argument_contract.address,
            commitment_contract.address
        );

        let proof_path = folder_path + "/proof.bin";
        console.log("Verify :",proof_path);
        let proof  = loadProof(proof_path);
        await verifier_contract.verify(proof, {gasLimit: 30_500_000});
        console.log("====================================");

//            proof_path = folder_path + "/proof2.bin";
//            console.log("Verify :",proof_path);
//            proof  = loadProof(proof_path);
//            await verifier_contract.verify(proof, {gasLimit: 30_500_000});
});