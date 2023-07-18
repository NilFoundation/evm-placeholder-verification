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

    let zkllvm = get_subfolders("./contracts/zkllvm");

    for(k in zkllvm){
        let libs = losslessJSON.parse(fs.readFileSync("./contracts/zkllvm/"+zkllvm[k]+"/linked_libs_list.json", 'utf8'));
        let deployedLib = {}
        for (let lib of libs){
            await deploy(lib, {
                from: deployer,
                log: true,
            });
            deployedLib[lib] = (await hre.deployments.get(lib)).address
        }
        d = await deploy(zkllvm[k]+'_gate_argument_split_gen', {
            from: deployer,
            libraries : deployedLib,
            log : true,
        });
    }
}

module.exports.tags = ['ZKLLVMFixture'];
