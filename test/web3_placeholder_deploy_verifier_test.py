from web3_test import do_placeholder_verification_test_via_transact_deployed_contract, base_path, deploy_placeholder_contract
import json
import sys

from prepare_logs import create_logs_dir

placeholder_contract_name = 'PlaceholderVerifier'
placeholder_contract_path = 'verifier.sol'
placeholder_libs_names = ['placeholder_verifier']

test_contract_name = 'TestPlaceholderVerifier'
test_contract_path = 'placeholder/test/public_api_placeholder.sol'
test_contract_linked_libs_names = []

def load_params(paramsfile, prooffile):
    jsonf = open(paramsfile);
    parsed_json = json.load(jsonf);
    jsonf.close();

    params = dict()
    params['_test_name'] = parsed_json['_test_name']

    params['init_params'] = []
    params['init_params'].append(parsed_json["modulus"])
    params['init_params'].append(parsed_json["r"])
    params['init_params'].append(parsed_json["max_degree"])
    params['init_params'].append(parsed_json["lambda"])
    params['init_params'].append(parsed_json["rows_amount"])
    params['init_params'].append(parsed_json["omega"])
    params['init_params'].append(len(parsed_json["D_omegas"]))
    params['init_params'].extend(parsed_json["D_omegas"])
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
        base_path + '/test/data/unified_addition/lambda2.json',
        base_path + '/test/data/unified_addition/lambda2.data'
    )

def init_test2():
    return load_params(
        base_path + '/examples/mina_scalar/circuit_params.json',
        base_path + '/examples/mina_scalar/proof.bin'
    )

def init_test3():
    return load_params(
        base_path + '/examples/merkle_tree_poseidon/circuit_params.json',
        base_path + '/examples/merkle_tree_poseidon/proof.bin'
    )

def init_test4():
    return load_params(
        base_path + '/examples/mina_base/circuit_params.json',
        base_path + '/examples/mina_base/proof.bin'
    )

def unified_addition_test(contract_inst):    
    gate_argument_contract_name = 'unified_addition_component_gen'
    gate_argument_contract_path = 'components/unified_addition_gen.sol'
    gate_argument_linked_libs = []

    do_placeholder_verification_test_via_transact_deployed_contract(
        contract_inst,
        gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs, 
        init_test1
    )

def mina_scalar_test(contract_inst):
    gate_argument_contract_name = 'gate_argument_split_gen'
    gate_argument_contract_path = '../examples/mina_scalar/gate_argument.sol'

    jsonf = open("../examples/mina_scalar/linked_libs_list.json");
    gate_argument_linked_libs = json.load(jsonf);
    jsonf.close();

    do_placeholder_verification_test_via_transact_deployed_contract(
        contract_inst,
        gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs, 
        init_test2
    )

def merkle_tree_poseidon_test(contract_inst):
    gate_argument_contract_name = 'gate_argument_split_gen'
    gate_argument_contract_path = '../examples/merkle_tree_poseidon/gate_argument.sol'

    jsonf = open("../examples/merkle_tree_poseidon/linked_libs_list.json");
    gate_argument_linked_libs = json.load(jsonf);
    jsonf.close();

    do_placeholder_verification_test_via_transact_deployed_contract(
        contract_inst,
        gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs, 
        init_test3
    )

def mina_base_test(contract_inst):
    gate_argument_contract_name = 'gate_argument_split_gen'
    gate_argument_contract_path = '../examples/mina_base/gate_argument.sol'

    jsonf = open("../examples/mina_base/linked_libs_list.json");
    gate_argument_linked_libs = json.load(jsonf);
    jsonf.close();

    do_placeholder_verification_test_via_transact_deployed_contract(
        contract_inst,
        gate_argument_contract_name, gate_argument_contract_path, gate_argument_linked_libs, 
        init_test4
    )

if __name__ == '__main__':
    create_logs_dir(base_path + '/logs')
    contract_inst = deploy_placeholder_contract(
        placeholder_contract_name, placeholder_contract_path,placeholder_libs_names,
        test_contract_name, test_contract_path, test_contract_linked_libs_names
    )

    if "1" in sys.argv:
        unified_addition_test(contract_inst);
    if "2" in sys.argv:
        mina_scalar_test(contract_inst);
    if "3" in sys.argv:
        merkle_tree_poseidon_test(contract_inst);
    if "4" in sys.argv:
        mina_base_test(contract_inst);

    if "1" not in sys.argv and "2" not in sys.argv and not "3" in sys.argv and not "4" in sys.argv:
        unified_addition_test(contract_inst);
        mina_scalar_test(contract_inst);
        merkle_tree_poseidon_test(contract_inst);
        mina_base_test(contract_inst);