from web3_test import base_path, deploy_placeholder_contract, do_placeholder_verification_test_via_transact_fully_deployed
import json
import sys

placeholder_contract_name = 'PlaceholderVerifier'
placeholder_contract_path = 'verifier.sol'
placeholder_libs_names = ['placeholder_verifier']

test_contract_name = 'TestPlaceholderVerifier'
test_contract_path = 'placeholder/test/public_api_placeholder.sol'
test_contract_linked_libs_names = []

def load_params(default_params_file, circuit_params_file, proof_file, gate_argument_addr_file):
    jsonf = open(default_params_file)
    params_json = json.load(jsonf)
    jsonf.close()

    jsonf = open(circuit_params_file)
    circuit_json = json.load(jsonf)
    jsonf.close()

    for k in circuit_json:
        params_json[k] = circuit_json[k]

    params = dict()
    params['_test_name'] = params_json['_test_name']

    params['init_params'] = []
    params['init_params'].append(params_json["modulus"])
    params['init_params'].append(params_json["r"])
    params['init_params'].append(params_json["max_degree"])
    params['init_params'].append(params_json["lambda"])
    params['init_params'].append(params_json["rows_amount"])
    params['init_params'].append(params_json["omega"])
    params['init_params'].append(len(params_json["D_omegas"]))
    params['init_params'].extend(params_json["D_omegas"])
    params['init_params'].append(len(params_json["step_list"]))
    params['init_params'].extend(params_json["step_list"])
    params['init_params'].append((len(params_json["arithmetization_params"])))
    params['init_params'].extend(params_json["arithmetization_params"])

    params['columns_rotations'] = params_json["columns_rotations"];

    f = open(proof_file)
    params["proof"] = f.read()
    f.close()

    f = open(gate_argument_addr_file)
    params["gate_argument_address"] = f.readline()
    f.close()

    return params

def init_test(folder_name):
    params =  load_params(
        base_path + 'test/data/default_params.json',
        base_path +  folder_name + '/circuit_params.json',
        base_path +  folder_name + '/proof.bin',
        base_path +  folder_name + '/addr'
    )
    return params;

if __name__ == '__main__':
    contract_inst = deploy_placeholder_contract(
        placeholder_contract_name, placeholder_contract_path,placeholder_libs_names,
        test_contract_name, test_contract_path, test_contract_linked_libs_names,
    )
    for i in range(1, len(sys.argv)):
        params = init_test(sys.argv[i])
        do_placeholder_verification_test_via_transact_fully_deployed(
            contract_inst,
            params['gate_argument_address'],
            params
        )