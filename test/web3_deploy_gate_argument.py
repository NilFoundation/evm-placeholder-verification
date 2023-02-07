import solcx
import json

from web3 import Web3
from web3.middleware import geth_poa_middleware
from web3_test import deploy_link_libs, base_path, contracts_dir
import os
import sys

def init_connection():
    w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545', request_kwargs={'timeout': 600}))
    w3.middleware_onion.inject(geth_poa_middleware, layer=0)
    w3.eth.default_account = w3.eth.accounts[0]
    return w3

def find_compiled_contract(compiled, contract_name):
    compiled_id = None
    compiled_interface = False
    for key, value in compiled.items():
        if key.endswith(contract_name):
            compiled_id = key
            compiled_interface = value
            break
    else:
        print(f'{contract_name} not found!')
        exit(1)
    return compiled_id, compiled_interface

if __name__ == '__main__':
    if len(sys.argv) == 1:
        folder_name = 'generated_gate_argument'
    else:
        folder_name = sys.argv[1]
        
    contract_name = 'gate_argument_split_gen'
    contract_path = folder_name + '/gate_argument.sol'
    print(folder_name);

    w3 = init_connection()
    solcx.install_solc('0.8.17')
    print(f'{base_path}/{contract_path}')
    compiled = solcx.compile_files(
        [f'{base_path}{contract_path}'],
        allow_paths=[f'{contracts_dir}', f'{base_path}{folder_name}'],
        output_values=['abi', 'bin'],
        solc_version="0.8.17",
        optimize=True,
        optimize_runs=200)
    compiled_test_contract_id, compiled_test_contract_interface = find_compiled_contract(compiled, contract_name)
    bytecode = compiled_test_contract_interface['bin']
    abi = compiled_test_contract_interface['abi']

    jsonf = open(f"{base_path}{folder_name}/linked_libs_list.json");
    parsed_json = json.load(jsonf);
    jsonf.close()
    bytecode = deploy_link_libs(w3, compiled, bytecode, parsed_json)

    test_contract = w3.eth.contract(abi=abi, bytecode=bytecode)
    deploy_tx_hash = test_contract.constructor().transact()
    deploy_tx_receipt = w3.eth.wait_for_transaction_receipt(deploy_tx_hash)
    print("Deployment cost:", deploy_tx_receipt.gasUsed)
    print("contractAddress:", deploy_tx_receipt.contractAddress)
    print("abi:", abi)
    with open(f'{base_path}{folder_name}/addr', 'w') as f:
        f.write(deploy_tx_receipt.contractAddress)
