from web3_test import do_placeholder_verification_test_via_transact, base_path, do_placeholder_verification_test_via_transact_simple
import json
import sys

from prepare_logs import create_logs_dir

test_contract_name = 'TestPlaceholderVerifierUnifiedAddition'
test_contract_path = 'placeholder/test/public_api_placeholder_unified_addition_component.sol'
linked_libs_names = [""]

placeholder_contract_name = 'PlaceholderVerifier'
placeholder_contract_path = './verifier.sol'
placeholder_libs_names = [""]

gate_argument_contract_name = 'unified_addition_component_gen'
gate_argument_contract_path = 'components/test/unified_addition_gen.sol'
gate_argument_linked_libs = [""]

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

    params['log_file'] = parsed_json['log_file'];

    return params

def init_test1():
    return load_params(
        base_path + '/test/data/unified_addition_test1_params.json',
        base_path + '/test/data/unified_addition_proof1.data'
    )

def init_test2():
    return load_params(
        base_path + '/test/data/unified_addition_test2_params.json',
        base_path + '/test/data/unified_addition_proof2.data'
    )


if __name__ == '__main__':
    create_logs_dir(base_path + '/logs')
    if "1" in sys.argv:
        do_placeholder_verification_test_via_transact_simple(placeholder_contract_name, placeholder_contract_path,placeholder_libs_names,
                                                             test_contract_name,test_contract_path, linked_libs_names,
                                                             gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs, init_test1)
    if "2" in sys.argv:
        do_placeholder_verification_test_via_transact_simple(placeholder_contract_name, placeholder_contract_path, placeholder_libs_names,
                                                             test_contract_name, test_contract_path, linked_libs_names,
                                                             gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs,init_test2)

    if "1" not in sys.argv and "2" not in sys.argv and "3" not in sys.argv:
        do_placeholder_verification_test_via_transact_simple(placeholder_contract_name, placeholder_contract_path, placeholder_libs_names,
                                                             test_contract_name, test_contract_path, linked_libs_names,
                                                             gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs,init_test1)
        do_placeholder_verification_test_via_transact_simple(placeholder_contract_name, placeholder_contract_path, placeholder_libs_names,
                                                             test_contract_name, test_contract_path, linked_libs_names,
                                                             gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs,init_test2)
