import solcx

from web3 import Web3
from web3.middleware import geth_poa_middleware
import os
import sys

base_path = os.path.abspath(os.getcwd())
contracts_dir = base_path + '/contracts'


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
    contract_name = 'unified_addition_component_gen'
    contract_path = 'components/unified_addition_gen.sol'

    w3 = init_connection()
    solcx.install_solc('0.8.17')
    print(f'{contracts_dir}/{contract_path}')
    compiled = solcx.compile_files(
        [f'{contracts_dir}/{contract_path}'],
        allow_paths=[f'{contract_path}'],
        output_values=['abi', 'bin'],
        solc_version="0.8.17",
        optimize=True,
        optimize_runs=200)
    compiled_test_contract_id, compiled_test_contract_interface = find_compiled_contract(compiled, contract_name)
    bytecode = compiled_test_contract_interface['bin']
    abi = compiled_test_contract_interface['abi']
#    bytecode = deploy_link_libs(w3, compiled, bytecode, linked_gates_libs_names)

    test_contract = w3.eth.contract(abi=abi, bytecode=bytecode)
    deploy_tx_hash = test_contract.constructor().transact()
    deploy_tx_receipt = w3.eth.wait_for_transaction_receipt(deploy_tx_hash)
    print("Deployment cost:", deploy_tx_receipt.gasUsed)
    print("contractAddress:", deploy_tx_receipt.contractAddress)
    print("abi:", abi)
    if (len(sys.argv) > 1):
        with open(sys.argv[1], 'w') as f:
            f.write(deploy_tx_receipt.contractAddress)
