import {task} from "hardhat/config";
import fs from "fs";
import path from "path";
import losslessJSON from "lossless-json";
import {URL} from "url";

function getSubfolders(dir: fs.PathLike) {
    const files = fs.readdirSync(dir, {withFileTypes: true});
    const result = [];

    for (const file of files) {
        if (file.isDirectory()) {
            result.push(file.name);
        }
    }
    return result;
}

function loadProof(proof_path: string) {
    return fs.readFileSync(path.resolve(__dirname, proof_path), 'utf8');
}


function getFileContents(filePath: fs.PathOrFileDescriptor) {
    return fs.readFileSync(filePath, 'utf8');
}

function loadParamsFromFile(jsonFile: string | Buffer | URL | number) {
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
        let r: any = [];
        for (let j in named_params.columns_rotations[i]) {
            r.push(BigInt(named_params.columns_rotations[i][j].value));
        }
        params['columns_rotations'].push(r);
    }
    return params;
}

function loadPublicInput(public_input_path: string) {
    public_input_path = path.resolve(__dirname, public_input_path)
    if (fs.existsSync(public_input_path)) {
        let public_input = fs.readFileSync(public_input_path, 'utf8').trim();
        let result = [];
        for (let string_item of public_input.split(/\s+/)) {
            // If is necessary for the case if there is no numbers in the file
            if( string_item != "")
                result.push(BigInt(string_item))
        }
        console.log(result)
        return result;
    } else
        return null;
}

const verify_circuit_proof = async (modular_path: string, circuit: string) => {
    let folder_path = modular_path + circuit;
    await deployments.fixture(['ModularVerifierFixture']);
    //const permutation_argument_contract = await ethers.getContract("modular_permutation_argument_"+circuit);
    const lookup_argument_contract = await ethers.getContract("modular_lookup_argument_" + circuit);
    const gate_argument_contract = await ethers.getContract("modular_gate_argument_" + circuit);
    const commitment_contract = await ethers.getContract("modular_commitment_scheme_" + circuit);

    const verifier_contract = await ethers.getContract("modular_verifier_" + circuit);
    await verifier_contract.initialize(
        //permutation_argument_contract.address,
        lookup_argument_contract.address,
        gate_argument_contract.address,
        commitment_contract.address
    );

    let proof_path = folder_path + "/proof.bin";
    console.log("Verify :", proof_path);
    let proof = loadProof(proof_path);
    let public_input = loadPublicInput(folder_path + "/public_input.inp");
    if (public_input === null) {
        console.log("Wrong public input format!");
        return null;
    }
    let receipt = await (await verifier_contract.verify(proof, public_input, {gasLimit: 30_500_000})).wait();
    console.log("⛽Gas used: ", receipt.gasUsed.toNumber());
    console.log("Events received:");
    const get_verification_event_result = (event): boolean | null => {
        if (event.event == 'VerificationResult') {
            return BigInt(event.data) != 0n;
        }
        return null;
    };
    const event_to_string = (event) => {
        const verification_result = get_verification_event_result(event);
        if (verification_result !== null) {
            return verification_result ? '✅ProofVerified' : '🛑ProofVerificationFailed';
        }
        return '🤔' + event.event;
    };

    let verification_result = null;
    for (const e of receipt.events) {
        const result = get_verification_event_result(e);
        if (result !== null) {
            verification_result = result;
        }
        console.log(event_to_string(e));
    }
    console.log("====================================");
    return verification_result;
}

task("verify-circuit-proof-all")
    .setAction(async (hre) => {
        console.log("Verify proofs of all circuits");
        let modular_path = "../contracts/zkllvm/";
        let circuits = getSubfolders(path.resolve(__dirname, modular_path));
        for (const k in circuits) {
            await verify_circuit_proof(modular_path, circuits[k]);
        }
    });

task("verify-circuit-proof")
    .addParam("test")
    .setAction(async (test, hre) => {
        console.log("Run modular verifier for:", test.test);
        let modular_path = "../contracts/zkllvm/";
        let circuit = test.test;
        process.exit((await verify_circuit_proof(modular_path, circuit)) ? 0 : 1);
    });
