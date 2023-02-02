from web3_test import do_placeholder_verification_test_via_transact, base_path, do_placeholder_verification_test_via_transact_simple
import sys, json

test_contract_name = 'TestPlaceholderVerifierMinaBase'
test_contract_path = 'placeholder/test/public_api_placeholder_mina_base_component.sol'
linked_libs_names = [
    "mina_base_gate0",
    "mina_base_gate4",
    "mina_base_gate7",
    "mina_base_gate10",
    "mina_base_gate13",
    "mina_base_gate15",
    "mina_base_gate16",
    "mina_base_gate16_1",
    "placeholder_verifier"
]


def load_params(default_paramsfile, paramsfile, prooffile):
    jsonf = open(default_paramsfile);
    parsed_json = json.load(jsonf);
    jsonf.close()

    jsonf = open(paramsfile);
    test_json = json.load(jsonf);
    jsonf.close()
    
    for key in test_json:
        parsed_json[key] = test_json[key]

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
    params = load_params(
        base_path + "test/data/mina_base/default_params.json",
        base_path + "test/data/mina_base/eval1_step1.json",
        base_path + "test/data/mina_base/eval1_step1.data"
    )
    return params 

def init_test2():
    params = load_params(
        base_path + "test/data/mina_base/default_params.json",
        base_path + "test/data/mina_base/eval10_step1.json",
        base_path + "test/data/mina_base/eval10_step1.data"
    )
    return params

if __name__ == '__main__':
    if "1" in sys.argv:
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path,
                                                         linked_libs_names, init_test1)
    if "2" in sys.argv:
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path,
                                                         linked_libs_names, init_test2)
    if "1" not in sys.argv and "2" not in sys.argv:
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path,
            linked_libs_names, init_test1)
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path,
            linked_libs_names, init_test2)
