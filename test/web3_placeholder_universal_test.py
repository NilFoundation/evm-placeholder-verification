from web3_test import base_path, do_placeholder_verification_test_via_transact_with_external_gates, do_placeholder_verification_test_via_transact_simple
import json
import sys

from prepare_logs import create_logs_dir

test_contract_name = 'TestPlaceholderVerifierUniversal'
test_contract_path = 'placeholder/test/public_api_placeholder_universal_test_component.sol'
linked_libs_names = ["placeholder_verifier"]


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
    params['init_params'].append(params_json["max_batch"])
    params['init_params'].append(len(params_json["D_omegas"]))
    params['init_params'].extend(params_json["D_omegas"])
    params['init_params'].append(len(params_json["q"]))
    params['init_params'].extend(params_json["q"])
    params['init_params'].append(len(params_json["step_list"]))
    params['init_params'].extend(params_json["step_list"])
    params['init_params'].append((len(params_json["arithmetization_params"])))
    params['init_params'].extend(params_json["arithmetization_params"])

    params['columns_rotations'] = params_json["columns_rotations"];

    f = open(proof_file)
    params["proof"] = f.read()
    f.close()

    f = open(gate_argument_addr_file);
    params["gate_argument_address"] = int(f.read(), 16)
    f.close()

    return params

def init_test1():
    folder_name = sys.argv[1];
    params =  load_params(
        base_path + '/test/data/default_params.json',
        base_path + '/' + folder_name + '/circuit_params.json',
        base_path + '/' + folder_name + '/proof.bin',
        base_path + '/' + folder_name + '/addr'
    )
    return params;

if __name__ == '__main__':
    create_logs_dir(base_path + '/logs')
    if( len(sys.argv) < 2 ):
        print("Print input folder name in command_line")
        exit        
    do_placeholder_verification_test_via_transact_with_external_gates(test_contract_name, test_contract_path, linked_libs_names, init_test1)
