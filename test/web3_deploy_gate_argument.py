import json

from web3 import Web3
from web3.middleware import geth_poa_middleware
from web3_test import deploy_gate_argument, base_path
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
    for i in range(len(sys.argv)):
        if i == 0:
            continue;
        folder = sys.argv[i]
        gate_argument_contract_name = 'gate_argument_split_gen'
        gate_argument_contract_path = "../" + folder + '/gate_argument.sol'

        jsonf = open(base_path+folder + "/linked_libs_list.json");
        gate_argument_linked_libs = json.load(jsonf);
        jsonf.close();

        addr = deploy_gate_argument(gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs)
        with open(base_path+folder+'/addr', 'w') as f:
            f.write(addr)
