from web3 import Web3
from web3.middleware import geth_poa_middleware
import solcx
import os
import pathlib
from pathlib import Path
from web3_test import find_compiled_contract, print_tx_info

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)
w3.eth.default_account = w3.eth.accounts[0]

base_path = os.path.abspath(os.getcwd())
contracts_dir = base_path + '/contracts'
contract_name = 'TestLpcVerifier'


def init_basic_test():
    params = dict()
    params['_test_name'] = "Lpc basic verification test"
    f = open('./test/data/lpc_basic_test.txt')
    params["proof"] = f.read()
    f.close()
    params['init_transcript'] = '0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'

    params['init_params'] = []
    params['init_params'].append(
        52435875175126190479447740508185965837690552500527637822603658699938581184513)  # modulus
    params['init_params'].append(3)  # r
    params['init_params'].append(15)  # max_degree
    params['init_params'].append(1)  # leaf_size
    params['init_params'].append(2)  # lambda

    D_omegas = [
        14788168760825820622209131888203028446852016562542525606630160374691593895118,
        23674694431658770659612952115660802947967373701506253797663184111817857449850,
        3465144826073652318776269530687742778270252468765361963008
    ]

    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)  # Domain

    q = []
    q.append(0)
    q.append(0)
    q.append(1)
    params['init_params'].append(len(q))
    params['init_params'].extend(q)  # q

    step_list = [];
    step_list.append(1);
    step_list.append(1);
    step_list.append(1);
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list

    params['init_params'].append(
        26217937587563095239723870254092982918845276250263818911301829349969290592257)  # const 1/2

    params['evaluation_points'] = [[7, ], ]

    return params


def init_batched_test():
    params = dict()
    params['_test_name'] = "Lpc batched verification test"
    f = open('./test/data/lpc_batched_basic_test.txt')
    params["proof"] = f.read()
    f.close()
    params['init_transcript'] = '0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'

    params['init_params'] = []
    params['init_params'].append(
        52435875175126190479447740508185965837690552500527637822603658699938581184513)  # modulus
    params['init_params'].append(3)  # r
    params['init_params'].append(15)  # max_degree
    params['init_params'].append(2)  # leaf_size
    params['init_params'].append(2)  # lambda

    D_omegas = [
        14788168760825820622209131888203028446852016562542525606630160374691593895118,
        23674694431658770659612952115660802947967373701506253797663184111817857449850,
        3465144826073652318776269530687742778270252468765361963008
    ]

    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)  # Domain

    q = []
    q.append(0)
    q.append(0)
    q.append(1)
    params['init_params'].append(len(q))
    params['init_params'].extend(q)  # q

    step_list = [];
    step_list.append(1);
    step_list.append(1);
    step_list.append(1);
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list

    params['init_params'].append(
        26217937587563095239723870254092982918845276250263818911301829349969290592257)  # const 1/2

    params['evaluation_points'] = [[7, ], [7, ]]

    return params


def init_skipping_layers_test():
    params = dict()
    params['_test_name'] = "Lpc verification skipping layers test (case 1)"
    test_path = Path('./test/data/lpc_skipping_layers_test.txt')
    if not test_path.is_file():
        print("Non-existing test file")
        return
    f = open('./test/data/lpc_skipping_layers_test.txt')
    params["proof"] = f.read()
    f.close()

    params['init_transcript'] = '0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'

    params['init_params'] = []
    params['init_params'].append(
        52435875175126190479447740508185965837690552500527637822603658699938581184513)  # modulus
    params['init_params'].append(10)  # r
    params['init_params'].append(2047)  # max_degree
    params['init_params'].append(1)  # leaf_size
    params['init_params'].append(2)  # lambda

    D_omegas = [
        49307615728544765012166121802278658070711169839041683575071795236746050763237,
        22781213702924172180523978385542388841346373992886390990881355510284839737428,
        4214636447306890335450803789410475782380792963881561516561680164772024173390,
        36007022166693598376559747923784822035233416720563672082740011604939309541707,
        47309214877430199588914062438791732591241783999377560080318349803002842391998,
        31519469946562159605140591558550197856588417350474800936898404023113662197331,
        36581797046584068049060372878520385032448812009597153775348195406694427778894,
        14788168760825820622209131888203028446852016562542525606630160374691593895118,
        23674694431658770659612952115660802947967373701506253797663184111817857449850,
        3465144826073652318776269530687742778270252468765361963008
    ]
    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)

    q = []
    q.append(0)
    q.append(0)
    q.append(1)
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    step_list = [];
    step_list.append(2);
    step_list.append(1);
    step_list.append(1);
    step_list.append(1);
    step_list.append(4);
    step_list.append(1);
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list
    params['init_params'].append(
        26217937587563095239723870254092982918845276250263818911301829349969290592257)  # const 1/2

    params['evaluation_points'] = [[7, ]]

    return params


if __name__ == '__main__':
    compiled = solcx.compile_files(
        [f'{contracts_dir}/commitments/test/public_api_lpc_verification.sol'],
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

    print("Skipping layers test")
    params = init_skipping_layers_test()
    run_tx_hash = contract_inst.functions.batched_verify(
        params['proof'], params['init_transcript'], params['init_params'], params['evaluation_points']).transact()
    run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
    print_tx_info(w3, run_tx_receipt, params['_test_name'])

    print("Basic test")
    params = init_basic_test()
    run_tx_hash = contract_inst.functions.batched_verify(
        params['proof'], params['init_transcript'], params['init_params'], params['evaluation_points']).transact()
    run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
    print_tx_info(w3, run_tx_receipt, params['_test_name'])

    print("Batched test")
    params = init_batched_test()
    run_tx_hash = contract_inst.functions.batched_verify(
        params['proof'], params['init_transcript'], params['init_params'], params['evaluation_points']).transact()
#    run_tx_receipt = w3.eth.wait_for_transaction_receipt(run_tx_hash)
#    print_tx_info(w3, run_tx_receipt, params['_test_name'])