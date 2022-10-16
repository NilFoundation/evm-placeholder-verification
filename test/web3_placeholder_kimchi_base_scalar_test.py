from web3_test import do_kimchi_verification_test_via_transact

test_contract_name = 'TestKimchiBaseField'
test_contract_path = 'placeholder/test/public_api_placeholder_kimchi_base_field_component.sol'
linked_gates_entry_lib_name = 'kimchi_base_field_component_split_gen'
linked_gates_libs_names = [
    'kimchi_base_field_gate0',
    'kimchi_base_field_gate1',
    'kimchi_base_field_gate2',
    'kimchi_base_field_gate3',
    'kimchi_base_field_gate4',
    'kimchi_base_field_gate5',
    'kimchi_base_field_gate6',
    'kimchi_base_field_gate7',
    'kimchi_base_field_gate8',
    'kimchi_base_field_gate9',
    'kimchi_base_field_gate10',
    'kimchi_base_field_gate11',
    'kimchi_base_field_gate12',
    'kimchi_base_field_gate13',
    'kimchi_base_field_gate14',
    'kimchi_base_field_gate15',
    'kimchi_base_field_gate16',
    'kimchi_base_field_gate17',
    'kimchi_base_field_gate18_0',
    'kimchi_base_field_gate18_1',
    'kimchi_base_field_gate19_0',
    'kimchi_base_field_gate19_1',
    'kimchi_base_field_gate20',
    'kimchi_base_field_gate21',
]

def init_test1():
    params = dict()
    params['_test_name'] = "Kimchi proof verification for base field (case 1)"
    f = open('./test/data/kimchi_base_field_proof.txt')
    params["proof"] = f.read()
    f.close()


    params['init_params'] = []
    params['init_params'].append(
        28948022309329048855892746252171976963363056481941647379679742748393362948097)
    params['init_params'].append(13)
    params['init_params'].append(16383)
    params['init_params'].append(1)
    params['init_params'].append(16384)
    params['init_params'].append(4962941270686734179124851736304457391480500057160355425531240539629160391514)
    params['init_params'].append(5)
    D_omegas = []
    f = open('./test/data/domain8_unified_addition.txt')
    lines = f.readlines()
    for line in lines:
        D_omegas.append(int(line))
    f.close()
    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)
    q = []
    q.append(0)
    q.append(0)
    q.append(1)
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    params['columns_rotations'] = [
        [0, 1, -1, ],
        [0, 1, -1, ],
        [0, 1, -1, ],
        [0, 1, -1, ],
        [0, 1, -1, ],
        [0, 1, -1, ],
        [0, 1, ],
        [0, 1, -1, ],
        [0, 1, -1, ],
        [0, 1, -1, ],
        [0, 1, -1, ],
        [0, 1, -1, ],
        [0, -1, ],
        [0, -1, ],
        [0, -1, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
        [0, ],
    ]

    step_list = [3, 3, 3, 3, 1]
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)                                                 #step_list

    return params

if __name__ == '__main__':
    do_kimchi_verification_test_via_transact(
        test_contract_name, 
        test_contract_path, 
        linked_gates_entry_lib_name, 
        linked_gates_libs_names, 
        init_test1)
