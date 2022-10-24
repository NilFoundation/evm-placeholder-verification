import solcx

from web3 import Web3
from web3.middleware import geth_poa_middleware
import os

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


def deploy_link_libs(w3, compiled, contract_bytecode, linked_libs_names):
    linked_bytecode = contract_bytecode
    for lib_name in linked_libs_names:
        compiled_lib_id, component_lib = find_compiled_contract(compiled, lib_name)
        component_lib_bytecode = component_lib['bin']
        component_lib_abi = component_lib['abi']
        print(f'Lib {lib_name} bytecode size:', len(component_lib_bytecode) // 2)
        contract_lib = w3.eth.contract(
            abi=component_lib_abi, bytecode=component_lib_bytecode)
        deploy_lib_tx_hash = contract_lib.constructor().transact()
        deploy_lib_tx_receipt = w3.eth.wait_for_transaction_receipt(deploy_lib_tx_hash)
        linked_bytecode = solcx.link_code(
            linked_bytecode,
            {compiled_lib_id: deploy_lib_tx_receipt.contractAddress},
            solc_version="0.8.17")
    print('Bytecode size:', len(linked_bytecode) // 2)
    return linked_bytecode


if __name__ == '__main__':
    contract_name = 'MinaStateProof'
    contract_path = '/mina/mina_state_proof.sol'

    linked_gates_libs_names = [
        "mina_scalar_gate0",
        "mina_scalar_gate1",
        "mina_scalar_gate2",
        "mina_scalar_gate3",
        "mina_scalar_gate4",
        "mina_scalar_gate8",
        "mina_scalar_gate9",
        "mina_scalar_gate10",
        "mina_scalar_gate11",
        "mina_scalar_gate12",
        "mina_scalar_gate13",
        "mina_scalar_gate14",
        "mina_scalar_gate15",
        "mina_scalar_gate16",
        "mina_scalar_gate17",
        "mina_scalar_gate18",
        "mina_scalar_gate19",
        "mina_scalar_gate20",
        "mina_scalar_gate21",
        "mina_scalar_gate22",
        "mina_base_gate0",
        "mina_base_gate1",
        "mina_base_gate2",
        "mina_base_gate3",
        "mina_base_gate4",
        "mina_base_gate5",
        "mina_base_gate6",
        "mina_base_gate7",
        "mina_base_gate8",
        "mina_base_gate9",
        "mina_base_gate10",
        "mina_base_gate11",
        "mina_base_gate12",
        "mina_base_gate13",
        "mina_base_gate14",
        "mina_base_gate15",
        "mina_base_gate16",
        "mina_base_gate16_1",
        "mina_base_gate17",
        "mina_base_gate18",
        "placeholder_verifier",
    ]

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
    bytecode = deploy_link_libs(w3, compiled, bytecode, linked_gates_libs_names)

    test_contract = w3.eth.contract(abi=abi, bytecode=bytecode)
    deploy_tx_hash = test_contract.constructor().transact()
    deploy_tx_receipt = w3.eth.wait_for_transaction_receipt(deploy_tx_hash)
    print("Deployment:", deploy_tx_receipt.gasUsed)
    print("contractAddress:", deploy_tx_receipt.contractAddress)
    print("abi:", abi)
