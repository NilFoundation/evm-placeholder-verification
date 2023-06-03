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

function getVerifierParams(configPath, proofPath) {
    let params = loadParamsFromFile(configPath);
    params['proof'] = fs.readFileSync(proofPath, 'utf8');
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

task("verify-zkllvm")
    .setAction(async (hre) => {
        console.log("Verify all zkllvm proofs");
        let path = "./contracts/zkllvm/";
        let tests = get_subfolders(path);
        await deployments.fixture(['testPlaceholderAPIConsumerFixture', 'ZKLLVMFixture', 'placeholderVerifierFixture']);

        for(const k in tests){
            let test = tests[k];
            let configPath = path + test + "/circuit_params.json";
            let proofPath = path + test + "/proof.bin";
            console.log("Verify :",test);
            
            let params = getVerifierParams(configPath,proofPath);

            let testPlaceholderAPI = await ethers.getContract('TestPlaceholderVerifier');
            let placeholderVerifier = await ethers.getContract('PlaceholderVerifier');
            let gatesContract = await ethers.getContract(test + '_gate_argument_split_gen');
            await testPlaceholderAPI.initialize(placeholderVerifier.address);
            await testPlaceholderAPI.verify(params['proof'],params['init_params'], params['columns_rotations'], gatesContract.address ,{gasLimit: 30_500_000});
        }
});

task("verify-zkllvm-proof", "Verify zkllvm proof")
    .addParam("test")
    .setAction(async (test, hre) => {
        console.log("Verify :",test.test);
        path = "./contracts/zkllvm/"+test.test+"/";

        let configPath = path + "circuit_params.json";
        let proofPath = path + "proof.bin";
        let params = getVerifierParams(configPath,proofPath);
        await deployments.fixture(['testPlaceholderAPIConsumerFixture', 'ZKLLVMFixture', 'placeholderVerifierFixture']);

        let testPlaceholderAPI = await ethers.getContract('TestPlaceholderVerifier');
        let placeholderVerifier = await ethers.getContract('PlaceholderVerifier');
        let gatesContract = await ethers.getContract(test.test + '_gate_argument_split_gen');
       
        await testPlaceholderAPI.initialize(placeholderVerifier.address);
        await testPlaceholderAPI.verify(params['proof'],params['init_params'], params['columns_rotations'], gatesContract.address ,{gasLimit: 30_500_000});
});