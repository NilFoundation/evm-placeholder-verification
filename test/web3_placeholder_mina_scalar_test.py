from web3_test import do_placeholder_verification_test_via_transact, do_placeholder_verification_test_via_transact_simple, base_path
import sys, json

test_contract_name = 'TestPlaceholderVerifierMinaScalar'
test_contract_path = 'placeholder/test/public_api_placeholder_mina_scalar_component.sol'
linked_libs_names = [
    "mina_scalar_gate0",
    "mina_scalar_gate1",
    "mina_scalar_gate2",
    "mina_scalar_gate3",
    "mina_scalar_gate4",
    "mina_scalar_gate5",
    "mina_scalar_gate6",
    "mina_scalar_gate7",
    "mina_scalar_gate8",
    "mina_scalar_gate9",
    "mina_scalar_gate10",
    "mina_scalar_gate11",
    "mina_scalar_gate12",
    "mina_scalar_gate13",
    "mina_scalar_gate14",
    "mina_scalar_gate15",
    "mina_scalar_gate16",
    "mina_scalar_gate17",
    "mina_scalar_gate18",
    "mina_scalar_gate19",
    "mina_scalar_gate20",
    "mina_scalar_gate21",
    "mina_scalar_gate22",
    "mina_scalar_gate23",
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
        base_path + "test/data/mina_scalar/default_params.json", 
        base_path + "test/data/mina_scalar/eval1_step1.json", 
        base_path + "test/data/mina_scalar/eval1_step1.data"
    )
    return params

def init_test2():
    params = load_params(
        base_path + "test/data/mina_scalar/default_params.json", 
        base_path + "test/data/mina_scalar/eval1_step3_3_3_2_1.json", 
        base_path + "test/data/mina_scalar/eval1_step3_3_3_2_1.data"
    )
    return params

def init_test3():
    params = load_params(
        base_path + "test/data/mina_scalar/default_params.json", 
        base_path + "test/data/mina_scalar/eval1_step1_3_3_3_1_1.json", 
        base_path + "test/data/mina_scalar/eval1_step1_3_3_3_1_1.data"
    )
    return params

def init_test4():
    params = load_params(
        base_path + "test/data/mina_scalar/default_params.json",
        base_path + "test/data/mina_scalar/eval10_step1.json",
        base_path + "test/data/mina_scalar/eval10_step1.data"
    )
    return params

if __name__ == '__main__':
    if "1" in sys.argv:
        #   eval1_step1
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path, linked_libs_names, init_test1)
    if "2" in sys.argv:
        #   eval1_step3_3_3_2_1
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path, linked_libs_names, init_test2)
    if "3" in sys.argv:
        #   eval1_step1_3_3_3_1_1
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path, linked_libs_names, init_test3)
    if "4" in sys.argv:
        #   eval10_step1
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path, linked_libs_names, init_test4)

    if "1" not in sys.argv and "2" not in sys.argv and "3" not in sys.argv and "4" not in sys.argv:
        #   eval1_step1
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path, linked_libs_names, init_test1)
        #   eval1_step3
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path, linked_libs_names, init_test2)
        #   eval1_step1_3_3_3_1_1
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path, linked_libs_names, init_test3)
        #   eval10_step1
        do_placeholder_verification_test_via_transact_simple(test_contract_name, test_contract_path, linked_libs_names, init_test4)
