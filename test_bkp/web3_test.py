import solcx

from web3 import Web3
from web3.middleware import geth_poa_middleware
import os
import sys
import shutil

base_path = os.path.abspath(os.getcwd()) + '/../'
contracts_dir = base_path + 'contracts'


def init_profiling():
    if "--nolog" in sys.argv:
        print("No logging!")
        shutil.copyfile(contracts_dir + "/profiling_disabled.sol", contracts_dir + "/profiling.sol")
    else:
        shutil.copyfile(contracts_dir + "/profiling_enabled.sol", contracts_dir + "/profiling.sol")


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


def print_tx_info(w3, tx_receipt, tx_name, function_name = ""):
    print(tx_name, ":", function_name)
    print(f"\t{tx_receipt.transactionHash.hex()}")
    print("\tgasUsed = ", tx_receipt.gasUsed)
    print(tx_receipt)
    write_tx_calldata(w3, tx_receipt)


def deploy_link_libs(w3, compiled, test_contract_bytecode, linked_libs_names):
    linked_bytecode = test_contract_bytecode
    for lib_name in linked_libs_names:
        compiled_lib_id, component_lib = find_compiled_contract(compiled, lib_name)
        component_lib_bytecode = component_lib['bin']
        component_lib_abi = component_lib['abi']
        print(f'\tLib {lib_name} bytecode size:', len(component_lib_bytecode) // 2)
        contract_lib = w3.eth.contract(
            abi=component_lib_abi, bytecode=component_lib_bytecode)
        deploy_lib_tx_hash = contract_lib.constructor().transact()
        deploy_lib_tx_receipt = w3.eth.wait_for_transaction_receipt(deploy_lib_tx_hash)
        linked_bytecode = solcx.link_code(
            linked_bytecode,
            {compiled_lib_id: deploy_lib_tx_receipt.contractAddress},
            solc_version="0.8.17")
    print('\tBytecode size:', len(linked_bytecode) // 2)
    return linked_bytecode


profiling_start_block = 0;
profiling_end_block = 1;
profiling_log_message = 2;
profiling_log_decimal = 3;
profiling_log_hexadecimal = 4;


class gas_usage_event:
    def __init__(self, event):
        self.command = event['args']['command'];
        self.gas_usage = event['args']['gas_usage'];
        self.function_name = event['args']['function_name'];


def print_profiling_log(logs, totalGas, filename):
    f = open(filename, "w")
    stack = [];
    result = [];
    depth = 1;
    prefix = "";
    cur_gas_start = 0;
    for i in range(len(logs)):
        event = logs[i]
        e = gas_usage_event(event)

        if (e.command == profiling_start_block):
            cur_gas_start = e.gas_usage
            e.block_gas_usage = e.gas_usage
            result.append(e)
            stack.append(i)
        if (e.command == profiling_end_block):
            start_ind = stack.pop()
            cur_gas_start = result[start_ind].block_gas_usage
            e.block_gas_usage = cur_gas_start - e.gas_usage
            result.append(e)
            result[start_ind].block_gas_usage = cur_gas_start - e.gas_usage
        if (e.command == profiling_log_message):
            e.block_gas_usage = cur_gas_start - e.gas_usage
            result.append(e)
        if (e.command == profiling_log_decimal):
            e.block_gas_usage = e.gas_usage
            result.append(e)
        if (e.command == profiling_log_hexadecimal):
            e.block_gas_usage = e.gas_usage
            result.append(e)
    first = True
    print("{\"totalGas\":", "\"", totalGas, "\",", file=f, sep="")
    i = 0
    depth = 0
    for e in result:
        gas_usage = e.gas_usage;
        block_gas_usage = e.block_gas_usage
        if (e.command == profiling_start_block):
            if not first:
                print(",", file=f)
            first = False
            print(prefix, "\"", i, "_", e.function_name, '\":{', file=f, sep="")
            depth += 1
            prefix = "    " * depth
            print(prefix, "\"gas_usage\":\"", block_gas_usage, "\"", file=f, end="", sep="")
        if (e.command == profiling_end_block):
            first = False
            depth -= 1
            prefix = "    " * depth
            print("", file=f)
            print(prefix, "}", file=f, end="")
        if (e.command == profiling_log_message):
            if not first:
                print(",", file=f)
            print(prefix, "\"", i, "_message\":\"", e.function_name, "\"", file=f, end="", sep="")
            first = False
        if (e.command == profiling_log_decimal):
            if not first:
                print(",", file=f)
            print(prefix, "\"", i, "_", e.function_name, "\":\"", block_gas_usage, "\"", file=f, end="", sep="")
            first = False
        if (e.command == profiling_log_hexadecimal):
            if not first:
                print(",", file=f)
            print(prefix, "\"", i, "_", e.function_name, "\":\"", hex(block_gas_usage), "\"", file=f, end="", sep="")
            first = False
        i = i + 1;
    print("", file=f)
    print("}", file=f)


def deploy_contract_and_linked_libs(w3, contract_name, contract_path, linked_libs):
    print(f"Deploy contract {contract_name}");
    print(f"\tFilename = {contracts_dir}/{contract_path}")
    compiled = solcx.compile_files(
        [f'{contracts_dir}/{contract_path}'],
        allow_paths=[f'{contracts_dir}/'],
        output_values=['abi', 'bin'],
        solc_version="0.8.17",
        optimize=True,
        optimize_runs=200)
    compiled_test_contract_id, compiled_test_contract_interface = find_compiled_contract(
        compiled, contract_name)
    bytecode = compiled_test_contract_interface['bin']
    abi = compiled_test_contract_interface['abi']
    bytecode = deploy_link_libs(w3, compiled, bytecode, linked_libs)

    test_contract = w3.eth.contract(abi=abi, bytecode=bytecode)
    deploy_tx_hash = test_contract.constructor().transact()
    deploy_tx_receipt = w3.eth.wait_for_transaction_receipt(deploy_tx_hash)
    print("\tDeployment:", deploy_tx_receipt.gasUsed)

    contract_inst = w3.eth.contract(
        address=deploy_tx_receipt.contractAddress, abi=abi)

    return contract_inst, deploy_tx_receipt.contractAddress

def deploy_placeholder_contract(
    placeholder_contract_name, placeholder_contract_path,placeholder_libs_names,
    contract_name, contract_path, contract_linked_libs_names,
):
    w3 = init_connection()

    placeholder_contract_inst,placeholder_contract_deploy_addr = deploy_contract_and_linked_libs(
        w3, placeholder_contract_name,  placeholder_contract_path, placeholder_libs_names
    )
 
    contract_inst, contract_deploy_addr = deploy_contract_and_linked_libs(
        w3, contract_name, contract_path, contract_linked_libs_names
    )

    run_tx_hash = contract_inst.functions.initialize(placeholder_contract_deploy_addr).transact()
    run_tx_receipt =  w3.eth.wait_for_transaction_receipt(run_tx_hash)
    print_tx_info(w3, run_tx_receipt, "Placeholder contract: ", "initialize")
    return contract_inst

def deploy_gate_argument(
    gate_argument_contract_name, gate_argument_contract_path,  gate_argument_linked_libs_names,
):
    w3 = init_connection()
    gate_arg_inst, gate_arg_addr = deploy_contract_and_linked_libs(
        w3, gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs_names
    )
    return gate_arg_addr;


def do_placeholder_verification_test_via_transact_simple(
    placeholder_contract_name, placeholder_contract_path,placeholder_libs_names,
    contract_name, contract_path, contract_linked_libs_names,
    gate_argument_contract_name, gate_argument_contract_path,  gate_argument_linked_libs_names,
    init_test_params_func
):
    init_profiling()
    w3 = init_connection()

    contract_inst = deploy_placeholder_contract(
        placeholder_contract_name, placeholder_contract_path,placeholder_libs_names,
        contract_name, contract_path, contract_linked_libs_names,
    )

    gate_arg_addr = deploy_gate_argument(
        gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs_names
    )

    params = init_test_params_func()

    do_placeholder_verification_test_via_transact_fully_deployed(contract_inst, gate_arg_addr, params)


def do_placeholder_verification_test_via_transact_deployed_contract(
    contract_inst,
    gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs_names,
    init_test_params_func
):
    init_profiling()
    w3 = init_connection()
    solcx.install_solc('0.8.17')

    gate_arg_inst, gate_arg_addr = deploy_contract_and_linked_libs(
        w3, gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs_names
    )

    params = init_test_params_func()
    run_tx_hash = contract_inst.functions.verify(
        params['proof'],
        params['init_params'],
        params['columns_rotations'],
        gate_arg_addr
    ).transact()
    run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
    print_tx_info(w3, run_tx_receipt, params['_test_name'], "verify")

def do_placeholder_verification_test_via_transact(
    test_contract_name, test_contract_path,
    linked_gates_entry_libs_names,
    linked_gates_libs_names, init_test_params_func
):
    """
    linked_gates_entry_libs_names - first external lib level
    linked_gates_libs_names - second external lib level (external for 1st level)
    """
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
    # test_contract_inst = w3.eth.contract(address=deploy_tx_receipt.contractAddress, abi=abi)
    test_contract_inst = w3.eth.contract(address=deploy_tx_receipt.contractAddress, abi=abi)
    params = init_test_params_func()
    run_tx_hash = test_contract_inst.functions.verify(params['proof'], params['init_params'],
                                                      params['columns_rotations']).transact()
    run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
    print_tx_info(w3, run_tx_receipt, params['_test_name'])


def do_placeholder_verification_test_via_transact_fully_deployed(
    contract_inst,
    gate_arg_addr,
    params
):
    init_profiling()
    w3 = init_connection()

    solcx.install_solc('0.8.17')
    run_tx_hash = contract_inst.functions.verify(
        params['proof'],
        params['init_params'],
        params['columns_rotations'],
        gate_arg_addr
    ).transact()
    run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
    print_tx_info(w3, run_tx_receipt, params['_test_name'], "verify")