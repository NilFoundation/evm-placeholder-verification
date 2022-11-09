import sys
from web3_test import do_placeholder_verification_test_via_transact, base_path, do_placeholder_verification_test_via_transact_with_external_gates

test_contract_name = 'TestPlaceholderVerifierUnifiedAddition'
test_contract_path = 'placeholder/test/public_api_placeholder_unified_addition_component.sol'
# linked_gates_entry_lib_name = "unified_addition_component_gen"
linked_libs_names = ["placeholder_verifier"]


def init_test1():
    print(sys.argv[1])
    params = dict()
    params['_test_name'] = "Placeholder proof verification for unified addition (case 1)"
    f = open(base_path + '/test/data/unified_addition_proof1.data')
    params["proof"] = f.read()
    f.close()

    params['init_params'] = []
    params['init_params'].append(
        28948022309329048855892746252171976963363056481941560715954676764349967630337)
    params['init_params'].append(2)
    params['init_params'].append(7)
    params['init_params'].append(2)
    params['init_params'].append(8)
    params['init_params'].append(199455130043951077247265858823823987229570523056509026484192158816218200659)
    params['init_params'].append(27)
    D_omegas = []
    f = open(base_path + '/test/data/domain8_unified_addition.txt')
    lines = f.readlines()
    for line in lines:
        D_omegas.append(int(line))
    f.close()
    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)
    q = [0, 0, 1]
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    step_list = [1, 1]
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list

    arithmentization_params = [11, 1, 0, 1] # witness, public_input, constant, selector
    params['init_params'].append((len(arithmentization_params)))
    params['init_params'].extend(arithmentization_params)

    params['gate_argument_address'] = int(sys.argv[1], 16)

    params['columns_rotations'] = []
    for i in range(14):
        params['columns_rotations'].append([0, ])
    
    return params


def init_test2():
    params = dict()
    params['_test_name'] = "Placeholder proof verification for unified addition (case 2)"
    f = open(base_path + '/test/data/unified_addition_proof2.data')
    params["proof"] = f.read()
    f.close()

    params['init_params'] = []
    params['init_params'].append(
        28948022309329048855892746252171976963363056481941560715954676764349967630337)  # modulus+
    params['init_params'].append(2)  # r
    params['init_params'].append(7)  # max_degree
    params['init_params'].append(2)  # lambda
    params['init_params'].append(8)  # rows_amount
    params['init_params'].append(
        199455130043951077247265858823823987229570523056509026484192158816218200659)  # 1st domen?
    params['init_params'].append(30)  
    D_omegas = []
    f = open(base_path + '/test/data/domain8_unified_addition.txt')
    lines = f.readlines()
    for line in lines:
        D_omegas.append(int(line))
    f.close()
    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)
    q = [0, 0, 1]
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    params['columns_rotations'] = []

    step_list = [1, 1]
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list

    arithmentization_params = [11, 1, 1, 1] # witness, public_input, constant, selector
    params['init_params'].append((len(arithmentization_params)))
    params['init_params'].extend(arithmentization_params)

    for i in range(14):
        params['columns_rotations'].append([0, ])

    params['gate_argument_address'] = int(sys.argv[1], 16)

    return params


if __name__ == '__main__':
    #gate_argument_contract_name = "unified_addition_component_gen";
    #gate_argument_contract_path = "";
    #raise ValueError('Outdates data files and maybe public api')
    do_placeholder_verification_test_via_transact_with_external_gates(test_contract_name, test_contract_path, linked_libs_names, init_test1)
    do_placeholder_verification_test_via_transact_with_external_gates(test_contract_name, test_contract_path, linked_libs_names, init_test2)
    # do_placeholder_verification_test_via_transact(test_contract_name, test_contract_path, linked_gates_entry_lib_name, linked_libs_names, init_test1)
    # do_placeholder_verification_test_via_transact(test_contract_name, test_contract_path, linked_gates_entry_lib_name, linked_libs_names, init_test2)
