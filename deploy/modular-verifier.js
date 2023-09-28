const hre = require('hardhat')
const { getNamedAccounts } = hre
const fs = require('fs');
const path = require('path');
const losslessJSON = require('lossless-json');

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

module.exports = async function() {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const {deployer, tokenOwner} = await getNamedAccounts();


    let circuits = get_subfolders("./contracts/modular");

    for(k in circuits){
        let addrs = {};
/*      let libs = losslessJSON.parse(fs.readFileSync("./contracts/zkllvm/"+circuits[k]+"/linked_libs_list.json", 'utf8'));
        let deployedLib = {}
        for (let lib of libs){
            await deploy(lib, {
                from: deployer,
                log: true,
            });
            deployedLib[lib] = (await hre.deployments.get(lib)).address
        }*/
        commitment_contract = await deploy("modular_commitment_scheme_" + circuits[k], {
            from: deployer,
            libraries : [], //deployedLib,
            log : true,
        });
/*
        permutation_argument_contract = await deploy("modular_permutation_argument_" + circuits[k], {
            from: deployer,
            libraries : [], //deployedLib,
            log : true,
        });
*/
        lookup_argument_contract = await deploy("modular_lookup_argument_" + circuits[k], {
            from: deployer,
            libraries : [], //deployedLib,
            log : true,
        });

        gate_argument_contract = await deploy("modular_gate_argument_" + circuits[k], {
            from: deployer,
            libraries : [], //deployedLib,
            log : true,
        });

        verifier_contract = await deploy("modular_verifier_" + circuits[k], {
            from: deployer,
            libraries : [], //deployedLib,
            log : true,
        });
    }
}

module.exports.tags = ['ModularVerifierFixture'];