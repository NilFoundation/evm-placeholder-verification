import {task} from "hardhat/config";
import fs from "fs";
import path from "path";
import losslessJSON from "lossless-json";

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

function loadPublicInput(public_input_path){
    if(fs.existsSync(public_input_path)){
        let json_file_content = losslessJSON.parse(fs.readFileSync(public_input_path, 'utf8'));
        let result = [];
        for(let i in json_file_content){
            result.push(BigInt(json_file_content[i]));
        }
        return result;
    } else 
        return [];
}

function getVerifierParams(configPath, proofPath, publicInputPath) {
    let public_input = loadPublicInput(path.resolve(__dirname, publicInputPath));
    let params = loadParamsFromFile(path.resolve(__dirname, configPath));
    params['proof'] = fs.readFileSync(path.resolve(__dirname, proofPath), 'utf8');
    params['public_input'] = public_input;
    return params
}


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

task("verify")
    .setAction(async (hre) => {
        console.log("Verify all zkllvm proofs");
        let zkllvm_path = "../contracts/zkllvm/";
        let tests = get_subfolders(path.resolve(__dirname, zkllvm_path));
        await deployments.fixture(['testPlaceholderAPIConsumerFixture', 'ZKLLVMFixture', 'placeholderVerifierFixture']);

        for(const k in tests){
            let test = tests[k];
            let configPath = zkllvm_path + test + "/circuit_params.json";
            let proofPath = zkllvm_path + test + "/proof.bin";
            let publicInputPath = zkllvm_path + test + "/public_input.json";
            console.log("Verify :",test);
            
            let params = getVerifierParams(configPath,proofPath, publicInputPath);

            let testPlaceholderAPI = await ethers.getContract('TestPlaceholderVerifier');
            let placeholderVerifier = await ethers.getContract('PlaceholderVerifier');
            let gatesContract = await ethers.getContract(test + '_gate_argument_split_gen');
            await testPlaceholderAPI.initialize(placeholderVerifier.address);
            await testPlaceholderAPI.verify(params['proof'],params['init_params'], params['columns_rotations'], params['public_input'], gatesContract.address ,{gasLimit: 30_500_000});
        }
});

task("verify-one", "Verify zkllvm proof")
    .addParam("test")
    .setAction(async (test, hre) => {
        console.log("Verify :",test.test);
        let zkllvm_path = "../contracts/zkllvm/"+test.test+"/";
        let configPath = zkllvm_path + "circuit_params.json";
        let proofPath = zkllvm_path + "proof.bin";
        let publicInputPath = zkllvm_path + "public_input.json";
        let params = getVerifierParams(configPath,proofPath, publicInputPath);
        await deployments.fixture(['testPlaceholderAPIConsumerFixture', 'ZKLLVMFixture', 'placeholderVerifierFixture']);

        let testPlaceholderAPI = await ethers.getContract('TestPlaceholderVerifier');
        let placeholderVerifier = await ethers.getContract('PlaceholderVerifier');
        let gatesContract = await ethers.getContract(test.test + '_gate_argument_split_gen');
       
        await testPlaceholderAPI.initialize(placeholderVerifier.address);
        await testPlaceholderAPI.verify(
            params['proof'],params['init_params'], params['columns_rotations'],
            params['public_input'], gatesContract.address,
            {gasLimit: 30_500_000}
        );
});