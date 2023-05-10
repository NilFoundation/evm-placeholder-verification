from web3 import Web3
from web3.middleware import geth_poa_middleware
import solcx
import os
import pathlib
from pathlib import Path
from web3_test import find_compiled_contract, print_tx_info
import sys
import shutil
import json

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)
w3.eth.default_account = w3.eth.accounts[0]

base_path = os.path.abspath(os.getcwd())  + '/../'
contracts_dir = base_path + 'contracts'
contract_name = 'TestLpcVerifier'


def init_profiling():
    if "--nolog" in sys.argv:
        print("No logging!")
        shutil.copyfile(contracts_dir+"/profiling_disabled.sol", contracts_dir+"/profiling.sol")
    else:
        shutil.copyfile(contracts_dir+"/profiling_enabled.sol", contracts_dir+"/profiling.sol")

def load_params(proof_file, params_file):
    jsonf = open(params_file);
    parsed_json = json.load(jsonf);
    jsonf.close()
    
    params = dict()

    params['init_params'] = []
    params['init_params'].append(parsed_json["modulus"])
    params['init_params'].append(parsed_json["r"])
    params['init_params'].append(parsed_json["max_degree"])
    params['init_params'].append(parsed_json["lambda"])
    params['init_params'].append(parsed_json["omega"])
    params['init_params'].append(len(parsed_json["D_omegas"]))
    params['init_params'].extend(parsed_json["D_omegas"])
    params['init_params'].append(len(parsed_json["step_list"]))
    params['init_params'].extend(parsed_json["step_list"])
    params['init_params'].append(len(parsed_json["batches_sizes"]))
    params['init_params'].extend(parsed_json["batches_sizes"])

    params['evaluation_points'] = parsed_json["evaluation_points"];

    f = open(proof_file)
    params["proof"] = f.read()
    f.close()

    if 'log_file' in parsed_json.keys() :
        params['log_file'] = parsed_json['log_file'];
    else:
        params['log_file'] = "lpc.log";

    return params

def init_basic_test():
    params = dict()
    params = load_params(
        base_path + "test/data/lpc_tests/lpc_basic_test.data",
        base_path + "test/data/lpc_tests/lpc_basic_test.json"
    )
    params['_test_name'] = "Lpc basic verification test"
    return params

def init_skipping_layers_test():
    params = dict()
    params = load_params(
        base_path + "test/data/lpc_tests/lpc_skipping_layers_test.data",
        base_path + "test/data/lpc_tests/lpc_skipping_layers_test.json"
    )
    params['_test_name'] = "Lpc skipping layers verification test"
    return params

def init_batches_num_3_test():
    params = dict()
    params = load_params(
        base_path + "test/data/lpc_tests/lpc_batches_num_3_test.data",
        base_path + "test/data/lpc_tests/lpc_batches_num_3_test.json"
    )
    params['_test_name'] = "Lpc batches_num=3 verification test"
    return params

def init_eval_points_test():
    params = dict()
    params = load_params(
        base_path + "test/data/lpc_tests/lpc_eval_points_test.data",
        base_path + "test/data/lpc_tests/lpc_eval_points_test.json"
    )
    params['_test_name'] = "Lpc different evaluation points verification test"
    return params

def init_eval_point2_test():
    params = dict()
    params = load_params(
        base_path + "test/data/lpc_tests/lpc_eval_point2_test.data",
        base_path + "test/data/lpc_tests/lpc_eval_point2_test.json"
    )
    params['_test_name'] = "Lpc evaluation point 2 verification test"
    return params

def init_eval_point3_test():
    params = dict()
    params = load_params(
        base_path + "test/data/lpc_tests/lpc_eval_point3_test.data",
        base_path + "test/data/lpc_tests/lpc_eval_point3_test.json"
    )
    params['_test_name'] = "Lpc evaluation point 3 verification test"
    return params

if __name__ == '__main__':
    solcx.install_solc('0.8.12')
    init_profiling()
    
    compiled = solcx.compile_files(
        [f'{contracts_dir}/commitments/test/public_api_lpc_verification.sol'],
        allow_paths=[f'{contracts_dir}/'],
        output_values=['abi', 'bin'],
        solc_version="0.8.12",
        optimize=True,
        optimize_runs=200)
    compiled_id, compiled_interface = find_compiled_contract(compiled, contract_name)
    bytecode = compiled_interface['bin']
    abi = compiled_interface['abi']
    print('Bytecode size:', len(bytecode) // 2)

    contract = w3.eth.contract(abi=abi, bytecode=bytecode)
    deploy_tx_hash = contract.constructor().transact()
    deploy_tx_receipt = w3.eth.wait_for_transaction_receipt(deploy_tx_hash)
    contract_inst = w3.eth.contract(address=deploy_tx_receipt.contractAddress, abi=abi)

    if "1" in sys.argv:
        params = init_basic_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'],  params['init_params'], params['evaluation_points']
        ).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])
    if "2" in sys.argv:
        params = init_skipping_layers_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'], params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])
    if "3" in sys.argv:
        params = init_batches_num_3_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'], params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])
    if "4" in sys.argv:
        params = init_eval_points_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'], params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])
    if "5" in sys.argv:
        params = init_eval_point2_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'], params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])
    if "6" in sys.argv:
        params = init_eval_point3_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'], params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])

    if "1" not in sys.argv and "2" not in sys.argv and "3" not in sys.argv and "4" not in sys.argv and "5" not in sys.argv and "6" not in sys.argv:
        params = init_basic_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'],  params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])
        
        params = init_skipping_layers_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'],  params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])

        params = init_batches_num_3_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'],  params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])

        params = init_eval_points_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'], params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])

        params = init_eval_point2_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'], params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])

        params = init_eval_point3_test()
        run_tx_hash = contract_inst.functions.batched_verify(
            params['proof'], params['init_params'], params['evaluation_points']).transact()
        run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
        print_tx_info(w3, run_tx_receipt, params['_test_name'])