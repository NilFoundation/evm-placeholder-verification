import solcx

from web3 import Web3
from web3.middleware import geth_poa_middleware
import os

base_path = os.path.abspath(os.getcwd()) + '/../'
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


def write_tx_calldata(w3, tx_receipt, ofname='tx_calldata.txt'):
    with open(ofname, 'w') as f:
        f.write(w3.eth.get_transaction(tx_receipt.transactionHash).input)


def print_tx_info(w3, tx_receipt, tx_name):
    print(tx_name)
    print(tx_receipt.transactionHash.hex())
    print('gasUsed =', tx_receipt.gasUsed)
    write_tx_calldata(w3, tx_receipt)


def deploy_link_libs(w3, compiled, test_contract_bytecode, linked_libs_names):
    linked_bytecode = test_contract_bytecode
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
    test_contract_name = 'TestPlaceholderMinaMix'
    test_contract_path = 'placeholder/test/public_api_placeholder_mina_mix.sol'

    linked_proofs_libs_names = []
    linked_gates_entry_libs_names = ["placeholder_verifier_mina_component", "placeholder_verifier_mina_base_component"]
    linked_gates_libs_names = [
        "mina_gate0",
        "mina_gate1",
        "mina_gate2",
        "mina_gate3",
        "mina_gate4",
        "mina_gate5",
        "mina_gate6",
        "mina_gate7",
        "mina_gate8",
        "mina_gate9",
        "mina_gate10",
        "mina_gate11",
        "mina_gate12",
        "mina_gate13",
        "mina_gate14",
        "mina_gate15",
        "mina_gate16",
        "mina_gate17",
        "mina_gate18",
        "mina_gate19",
        "mina_gate20",
        "mina_gate21",
        "mina_gate22",
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
        "mina_base_gate19",
        "mina_base_gate20",
        "mina_base_gate21"
    ]

    w3 = init_connection()
    solcx.install_solc('0.8.17')
    print(f'{contracts_dir}/{test_contract_path}')
    compiled = solcx.compile_files(
        [f'{contracts_dir}/{test_contract_path}'],
        allow_paths=[f'{contracts_dir}/'],
        output_values=['abi', 'bin'],
        solc_version="0.8.17",
        optimize=True,
        optimize_runs=200)

    linked_contracts = dict()

    for linked_gates_entry_lib_name in linked_gates_entry_libs_names:
        compiled_gates_entry_lib_id, compiled_gates_entry_lib_interface = find_compiled_contract(
            compiled, linked_gates_entry_lib_name)
        gates_entry_lib_bytecode = compiled_gates_entry_lib_interface['bin']
        gates_entry_lib_abi = compiled_gates_entry_lib_interface['abi']
        gates_entry_lib_bytecode = deploy_link_libs(w3, compiled, gates_entry_lib_bytecode, linked_gates_libs_names)

        gates_entry_contract_lib = w3.eth.contract(abi=gates_entry_lib_abi, bytecode=gates_entry_lib_bytecode)
        deploy_gates_entry_lib_tx_hash = gates_entry_contract_lib.constructor().transact()
        deploy_gates_entry_lib_tx_receipt = w3.eth.wait_for_transaction_receipt(deploy_gates_entry_lib_tx_hash)

        compiled_test_contract_id, compiled_test_contract_interface = find_compiled_contract(
            compiled, test_contract_name)
        linked_contracts[compiled_gates_entry_lib_id] = deploy_gates_entry_lib_tx_receipt.contractAddress

    bytecode = compiled_test_contract_interface['bin']
    abi = compiled_test_contract_interface['abi']

    bytecode = solcx.link_code(bytecode, linked_contracts, solc_version="0.8.17")

    test_contract = w3.eth.contract(abi=abi, bytecode=bytecode)
    deploy_tx_hash = test_contract.constructor().transact()
    deploy_tx_receipt = w3.eth.wait_for_transaction_receipt(deploy_tx_hash)
    print("Deployment:", deploy_tx_receipt.gasUsed)
    print("contractAddress:", deploy_tx_receipt.contractAddress)
    print("abi:", abi)
