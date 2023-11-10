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
  

function getFileContents(filePath) {
    return fs.readFileSync(filePath, 'utf8');
}

function loadParamsFromFile(jsonFile) {
    let named_params: any = {};
    named_params = losslessJSON.parse(fs.readFileSync(jsonFile, 'utf8'));
    let params: { [key: string]: any } = {};
    params['init_params'] = [];
    params['init_params'].push(BigInt(named_params.modulus));
    params['init_params'].push(BigInt(named_params.r));
    params['init_params'].push(BigInt(named_params.max_degree));
    params['init_params'].push(BigInt(named_params.lambda));
    params['init_params'].push(BigInt(named_params.rows_amount));
    params['init_params'].push(BigInt(named_params.omega));
    params['init_params'].push(BigInt(named_params.D_omegas.length));
    for (let i in named_params.D_omegas) {
        params['init_params'].push(BigInt(named_params.D_omegas[i]))
    }
    params['init_params'].push(BigInt(named_params.step_list.length));
    for (let i in named_params.step_list) {
        params['init_params'].push(BigInt(named_params.step_list[i].value))
    }
    params['init_params'].push(BigInt(named_params.arithmetization_params.length));
    for (let i in named_params.arithmetization_params) {
        params['init_params'].push(BigInt(named_params.arithmetization_params[i].value))
    }

    params['columns_rotations'] = [];
    for (let i in named_params.columns_rotations) {
        let r : any = [];
        for (let j in named_params.columns_rotations[i]) {
            r.push(BigInt(named_params.columns_rotations[i][j].value));
        }
        params['columns_rotations'].push(r);
    }
    return params;
}

function loadFieldElement(element){
    let result = [];
    if( element.isLosslessNumber ){
        result.push(BigInt(element));
    } else if ( typeof(element) == 'string' ){
        result.push(BigInt(element));
    } else {
        for(let i in element){
            let e  = loadFieldElement(element[i]);
            for(let j in e) result.push(e[j]);
        }
    }
    return result;
}

function loadCurveElement(element){
    let result = [];
    if( element.isLosslessNumber ){
        result.push(BigInt(element));
    } else if ( typeof(element) == 'string' ){
        result.push(BigInt(element));
    } else {
        for(let i in element){
            let e  = loadFieldElement(element[i]);
            for(let j in e) result.push(e[j]);
        }
    }
    return result;
}

function loadIntegerElement(public_input){
    let modulus = BigInt(28948022309329048855892746252171976963363056481941560715954676764349967630337);

    let result = [];
    let i = parseInt(public_input);
    if( i < 0 ) {
        result.push(modulus - BigInt(i));
    } else {
        result.push(BigInt(i));
    }
    return result;
}

function loadStringElement(public_input){
    let modulus = BigInt(28948022309329048855892746252171976963363056481941560715954676764349967630337);

    let result = [];
    for(let i in public_input){
        let c = public_input.charCodeAt(i);
        result.push(BigInt(c));
    }
    return result;
}


function loadArray(public_input){
    let result = [];

    for(let i in public_input){
        let e  = loadFieldElement(public_input[i]);
        for(let j in e) result.push(e[j]);
    }
    return result;
}

function loadVector(public_input){
    let result = [];

    for(let i in public_input){
        let e  = loadFieldElement(public_input[i]);
        for(let j in e) {
            result.push(e[j]);
        }
    }
    return result;
}

function loadPublicInput(public_input_path){
    public_input_path = path.resolve(__dirname, public_input_path)
    if(fs.existsSync(public_input_path)){
        let public_input  = losslessJSON.parse(fs.readFileSync(public_input_path, 'utf8'));
        let result = [];
        for(let i in public_input){
            let field = public_input[i];
            for(let k in field){
                let element;
                if( k == 'field' ){
                    element = loadFieldElement(field[k]);
                }
                if( k == 'curve' ){
                    element = loadCurveElement(field[k]);
                }
                if( k == 'int' ){
                    element = loadIntegerElement(field[k]);
                }
                if( k == 'string' ){
                    element = loadStringElement(field[k]);
                }
                if( k == 'array'){
                    element = loadArray(field[k]);
                }
                if( k == 'vector'){
                    element = loadVector(field[k]);
                }
                for(let e in element) result.push(element[e]);
            }
        }
        return result;
    } else 
        return [];
}

task("verify-circuit-proof-all")
    .setAction(async (hre) => {
        console.log("Verify proof in modular style");
        let modular_path = "../contracts/zkllvm/";
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
            let public_input = loadPublicInput(folder_path + "/input.json");
            let receipt = await(await verifier_contract.verify(proof, public_input, {gasLimit: 30_500_000})).wait();
            console.log("Gas used: ⛽ ", receipt.gasUsed.toNumber());
            console.log("Events received:");
            for(const e of receipt.events) {
                console.log(e.event);
            }
            console.log("====================================");

//            proof_path = folder_path + "/proof2.bin";
//            console.log("Verify :",proof_path);
//            proof  = loadProof(proof_path);
//            await verifier_contract.verify(proof, {gasLimit: 30_500_000});

        }
});

task("verify-circuit-proof")
    .addParam("test")
    .setAction(async (test, hre) => {
        console.log("Run modular verifier for:",test.test);
        let modular_path = "../contracts/zkllvm/";

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
        let public_input = loadPublicInput(folder_path + "/input.json");
        let receipt = await (await verifier_contract.verify(proof, public_input, {gasLimit: 30_500_000})).wait();
        console.log("Gas used: ⛽ ", receipt.gasUsed.toNumber());
        console.log("Events received:");
        for(const e of receipt.events) {
            console.log(e.event);
        }
        console.log("====================================");

//            proof_path = folder_path + "/proof2.bin";
//            console.log("Verify :",proof_path);
//            proof  = loadProof(proof_path);
//            await verifier_contract.verify(proof, {gasLimit: 30_500_000});
});
