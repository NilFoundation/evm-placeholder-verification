from web3_test import do_placeholder_verification_test_via_transact, base_path

test_contract_name = 'TestPlaceholderVerifierMinaBase'
test_contract_path = 'placeholder/test/public_api_placeholder_mina_base_component.sol'
linked_gates_entry_lib_name = 'mina_base_split_gen'
linked_libs_names = [
    "mina_base_gate0",
    "mina_base_gate1",
    "mina_base_gate2",
    "mina_base_gate3",
    "mina_base_gate4",
    "mina_base_gate5",
    "mina_base_gate6",
    "mina_base_gate7",
    "mina_base_gate8",
    "mina_base_gate9",
    "mina_base_gate10",
    "mina_base_gate11",
    "mina_base_gate12",
    "mina_base_gate13",
    "mina_base_gate14",
    "mina_base_gate15",
    "mina_base_gate16",
    "mina_base_gate17",
    "mina_base_gate18",
    "mina_base_gate19",
    "mina_base_gate19_1",
    "mina_base_gate20",
    "mina_base_gate21"
]


def init_test1():
    params = dict()
    params['_test_name'] = "Placeholder proof verification for mina"
    f = open(base_path + '/test/data/generated_eval1_step1_base.data')
    params["proof"] = f.read()
    f.close()

    params['init_params'] = []
    params['init_params'].append(28948022309329048855892746252171976963363056481941647379679742748393362948097)
    params['init_params'].append(13)
    params['init_params'].append(16383)
    params['init_params'].append(1)
    params['init_params'].append(16384)
    params['init_params'].append(4962941270686734179124851736304457391480500057160355425531240539629160391514)
    params['init_params'].append(30)
    D_omegas = [4962941270686734179124851736304457391480500057160355425531240539629160391514,
                24698565941386146905064983207718127075873794584889341429041780832303738174137,
                19342635675472973030958703460855586838246018162847467754269942910820871215401,
                5032528351894390093615884424140114457150112013647720477219996067428709871325,
                22090338513913049959963172982829382927035332346328063108352787446596923585926,
                25165177819627306674965102406249393023864159703467953217189030835046387946339,
                20406162866908888653425069393176433404558180282626759233524330349859168426307,
                24118114923975171970075748640221677083961848771131734379542430306560974812756,
                25227411734906969830001887161842150884725543104432911324890985713481442730673,
                2799975530188595297561234903824607897079093402088395318086163719444963742400,
                19366951025174438143523342051730202536500593522667444600037456491292628123146,
                4855188899445002300170730717563617051094175372704778513906105166874447905568,
                4265513433803163958251475299683560813532603332905934989976535652412227143402]

    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)
    q = [0, 0, 1]
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    params['columns_rotations'] = []
    # for i in range(47):
    #     params['columns_rotations'].append([0, ])
    # params['columns_rotations'][0] = [0, 1, -1]
    # params['columns_rotations'][1] = [0, -1, 1]
    # params['columns_rotations'][2] = [0, 1]
    # params['columns_rotations'][5] = [0, -1]
    # params['columns_rotations'][13] = [0, 1]
    params['columns_rotations'] = [[0, 1, -1, ],
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
                                   [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ],
                                   [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ],
                                   [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ], [0, ]]
    step_list = [1] * 13
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list
    return params


if __name__ == '__main__':
    do_placeholder_verification_test_via_transact(test_contract_name, test_contract_path, linked_gates_entry_lib_name,
                                                  linked_libs_names, init_test1)
