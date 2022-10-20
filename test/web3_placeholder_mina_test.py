from web3_test import do_placeholder_verification_test_via_transact, base_path

test_contract_name = 'TestPlaceholderVerifierMina'
test_contract_path = 'placeholder/test/public_api_placeholder_mina_component.sol'
linked_gates_entry_lib_name = 'mina_split_gen'
linked_libs_names = [
    "mina_gate0",
    "mina_gate1",
    "mina_gate2",
    "mina_gate3",
    "mina_gate4",
    "mina_gate5",
    "mina_gate6",
    "mina_gate7",
    "mina_gate8",
    "mina_gate9",
    "mina_gate10",
    "mina_gate11",
    "mina_gate12",
    "mina_gate13",
    "mina_gate14",
    "mina_gate15",
    "mina_gate16",
    "mina_gate17",
    "mina_gate18",
    "mina_gate19",
    "mina_gate20",
    "mina_gate21",
    "mina_gate22"
]


def init_test1():
    params = dict()
    params['_test_name'] = "Placeholder proof verification for mina"
    f = open(base_path + '/test/data/generated_eval1_step1_scalar.data')
    params["proof"] = f.read()
    f.close()

    params['init_params'] = []
    params['init_params'].append(28948022309329048855892746252171976963363056481941560715954676764349967630337)
    params['init_params'].append(11)
    params['init_params'].append(4095)
    params['init_params'].append(1)
    params['init_params'].append(4096)
    params['init_params'].append(18589158034707770508497743761528839450567399299956641192723316341154428793508)
    params['init_params'].append(30)
    # f = open('./test/data/domain8_unified_addition.txt')
    # lines = f.readlines()
    # for line in lines:
    #     D_omegas.append(int(line))
    # f.close()
    D_omegas = [18589158034707770508497743761528839450567399299956641192723316341154428793508,
                5207999989657576140891498154897385491612440083899963290755562031717636435093,
                21138537593338818067112636105753818200833244613779330379839660864802343411573,
                22954361264956099995527581168615143754787441159030650146191365293282410739685,
                23692685744005816481424929253249866475360293751445976741406164118468705843520,
                7356716530956153652314774863381845254278968224778478050456563329565810467774,
                17166126583027276163107155648953851600645935739886150467584901586847365754678,
                3612152772817685532768635636100598085437510685224817206515049967552954106764,
                14450201850503471296781915119640920297985789873634237091629829669980153907901,
                199455130043951077247265858823823987229570523056509026484192158816218200659,
                24760239192664116622385963963284001971067308018068707868888628426778644166363]

    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)
    q = [0, 0, 1]
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    params['columns_rotations'] = []
    for i in range(47):
        params['columns_rotations'].append([0, ])
    params['columns_rotations'][0] = [0, 1, -1]
    params['columns_rotations'][1] = [0, -1, 1]
    params['columns_rotations'][2] = [0, 1]
    params['columns_rotations'][5] = [0, -1]
    params['columns_rotations'][13] = [0, 1]

    # step_list = [3, 3, 3, 1, 1]
    step_list = [1] * 11
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list

    return params


def init_test2():
    params = dict()
    params['_test_name'] = "Placeholder proof verification for mina"
    f = open(base_path + '/test/data/generated_eval9_step1_scalar.data')
    params["proof"] = f.read()
    f.close()

    params['init_params'] = []
    params['init_params'].append(28948022309329048855892746252171976963363056481941560715954676764349967630337)
    params['init_params'].append(12)
    params['init_params'].append(8191)
    params['init_params'].append(1)
    params['init_params'].append(8192)
    params['init_params'].append(13175653644678658737556805326666943932741525539026001701374450696535194715445)
    params['init_params'].append(30)
    # f = open('./test/data/domain8_unified_addition.txt')
    # lines = f.readlines()
    # for line in lines:
    #     D_omegas.append(int(line))
    # f.close()
    D_omegas = [13175653644678658737556805326666943932741525539026001701374450696535194715445,
                18589158034707770508497743761528839450567399299956641192723316341154428793508,
                5207999989657576140891498154897385491612440083899963290755562031717636435093,
                21138537593338818067112636105753818200833244613779330379839660864802343411573,
                22954361264956099995527581168615143754787441159030650146191365293282410739685,
                23692685744005816481424929253249866475360293751445976741406164118468705843520,
                7356716530956153652314774863381845254278968224778478050456563329565810467774,
                17166126583027276163107155648953851600645935739886150467584901586847365754678,
                3612152772817685532768635636100598085437510685224817206515049967552954106764,
                14450201850503471296781915119640920297985789873634237091629829669980153907901,
                199455130043951077247265858823823987229570523056509026484192158816218200659,
                24760239192664116622385963963284001971067308018068707868888628426778644166363]

    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)
    q = [0, 0, 1]
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    params['columns_rotations'] = []
    for i in range(47):
        params['columns_rotations'].append([0, ])
    params['columns_rotations'][0] = [0, 1, -1]
    params['columns_rotations'][1] = [0, -1, 1]
    params['columns_rotations'][2] = [0, 1]
    params['columns_rotations'][5] = [0, -1]
    params['columns_rotations'][13] = [0, 1]

    # step_list = [3, 3, 3, 1, 1]
    step_list = [1] * 12
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list

    return params


def init_test3():
    params = dict()
    params['_test_name'] = "Placeholder proof verification for mina"
    f = open(base_path + '/test/data/generated_eval15_step1_scalar.data')
    params["proof"] = f.read()
    f.close()

    params['init_params'] = []
    params['init_params'].append(28948022309329048855892746252171976963363056481941560715954676764349967630337)
    params['init_params'].append(17)
    params['init_params'].append(262143)
    params['init_params'].append(1)
    params['init_params'].append(262144)
    params['init_params'].append(1052476823299314129969668407141491286911278219597830940957003018745899426804)
    params['init_params'].append(30)
    # f = open('./test/data/domain8_unified_addition.txt')
    # lines = f.readlines()
    # for line in lines:
    #     D_omegas.append(int(line))
    # f.close()
    D_omegas = [1052476823299314129969668407141491286911278219597830940957003018745899426804,
                21090803083255360924969619711782040241928172562822879037017685322859036642027,
                10988054172925167713694812535142550583545019937971378974362050426778203868934,
                22762810496981275083229264712375994604562198468579727082239970810950736657129,
                26495698845590383240609604404074423972849566255661802313591097233811292788392,
                13175653644678658737556805326666943932741525539026001701374450696535194715445,
                18589158034707770508497743761528839450567399299956641192723316341154428793508,
                5207999989657576140891498154897385491612440083899963290755562031717636435093,
                21138537593338818067112636105753818200833244613779330379839660864802343411573,
                22954361264956099995527581168615143754787441159030650146191365293282410739685,
                23692685744005816481424929253249866475360293751445976741406164118468705843520,
                7356716530956153652314774863381845254278968224778478050456563329565810467774,
                17166126583027276163107155648953851600645935739886150467584901586847365754678,
                3612152772817685532768635636100598085437510685224817206515049967552954106764,
                14450201850503471296781915119640920297985789873634237091629829669980153907901,
                199455130043951077247265858823823987229570523056509026484192158816218200659,
                24760239192664116622385963963284001971067308018068707868888628426778644166363]

    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)
    q = [0, 0, 1]
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    params['columns_rotations'] = []
    for i in range(47):
        params['columns_rotations'].append([0, ])
    params['columns_rotations'][0] = [0, 1, -1]
    params['columns_rotations'][1] = [0, -1, 1]
    params['columns_rotations'][2] = [0, 1]
    params['columns_rotations'][5] = [0, -1]
    params['columns_rotations'][13] = [0, 1]

    # step_list = [3, 3, 3, 1, 1]
    step_list = [1] * 17
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list

    return params


if __name__ == '__main__':
    do_placeholder_verification_test_via_transact(test_contract_name, test_contract_path, linked_gates_entry_lib_name,
                                                  linked_libs_names, init_test1)
    do_placeholder_verification_test_via_transact(test_contract_name, test_contract_path, linked_gates_entry_lib_name,
                                                  linked_libs_names, init_test2)
    do_placeholder_verification_test_via_transact(test_contract_name, test_contract_path, linked_gates_entry_lib_name,
                                                  linked_libs_names, init_test3)
