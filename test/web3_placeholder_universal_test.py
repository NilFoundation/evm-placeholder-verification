from web3_test import base_path, do_placeholder_verification_test_via_transact_with_external_gates, do_placeholder_verification_test_via_transact_simple
import json
import sys

test_contract_name = 'TestPlaceholderVerifierUniversal'
test_contract_path = 'placeholder/test/public_api_placeholder_universal_test_component.sol'
# linked_gates_entry_lib_name = "unified_addition_component_gen"
linked_libs_names = ["placeholder_verifier"]


def load_params(paramsfile, prooffile):
    jsonf = open(paramsfile);
    parsed_json = json.load(jsonf);
    jsonf.close()

    params = dict()
    params['_test_name'] = parsed_json['_test_name']

    params['init_params'] = []
    params['init_params'].append(parsed_json["modulus"])
    params['init_params'].append(parsed_json["r"])
    params['init_params'].append(parsed_json["max_degree"])
    params['init_params'].append(parsed_json["lambda"])
    params['init_params'].append(parsed_json["rows_amount"])
    params['init_params'].append(parsed_json["omega"])
    params['init_params'].append(parsed_json["max_batch"])
    params['init_params'].append(len(parsed_json["D_omegas"]))
    params['init_params'].extend(parsed_json["D_omegas"])
    params['init_params'].append(len(parsed_json["q"]))
    params['init_params'].extend(parsed_json["q"])
    params['init_params'].append(len(parsed_json["step_list"]))
    params['init_params'].extend(parsed_json["step_list"])
    params['init_params'].append((len(parsed_json["arithmetization_params"])))
    params['init_params'].extend(parsed_json["arithmetization_params"])

    params['columns_rotations'] = parsed_json["columns_rotations"];

    f = open(prooffile)
    params["proof"] = f.read()
    f.close()

    return params

def init_test1():
    params =  load_params(
        base_path + '/test/data/unified_addition_test1_params.json',
        base_path + '/test/data/unified_addition_proof2.data'
    )
    params["gate_argument_address"] = int(sys.argv[1], 16);
    return params;

if __name__ == '__main__':
    do_placeholder_verification_test_via_transact_with_external_gates(test_contract_name, test_contract_path, linked_libs_names, init_test1)
