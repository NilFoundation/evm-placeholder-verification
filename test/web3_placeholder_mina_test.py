from web3_test import do_placeholder_verification_test_via_transact

test_contract_name = 'TestPlaceholderVerifierMina'
test_contract_path = 'placeholder/test/public_api_placeholder_mina_component.sol'
linked_libs_names = [
    # 'unified_addition_component_gen_0',
    # 'unified_addition_component_gen_1',
    # 'unified_addition_component_gen_2'
]

def init_test1():
    params = dict()
    params['_test_name'] = "Placeholder proof verification for mina"
    f = open('./test/data/mina.txt')
    params["proof"] = f.read()
    f.close()


    params['init_params'] = []
    params['init_params'].append(
        28948022309329048855892746252171976963363056481941560715954676764349967630337)
    params['init_params'].append(11)
    params['init_params'].append(4095)
    params['init_params'].append(1)
    params['init_params'].append(4096)
    params['init_params'].append(18589158034707770508497743761528839450567399299956641192723316341154428793508)
    params['init_params'].append(30)
    D_omegas = []
    # f = open('./test/data/domain8_unified_addition.txt')
    # lines = f.readlines()
    # for line in lines:
    #     D_omegas.append(int(line))
    # f.close()
    D_omegas = [18589158034707770508497743761528839450567399299956641192723316341154428793508, 5207999989657576140891498154897385491612440083899963290755562031717636435093, 21138537593338818067112636105753818200833244613779330379839660864802343411573, 22954361264956099995527581168615143754787441159030650146191365293282410739685, 23692685744005816481424929253249866475360293751445976741406164118468705843520, 7356716530956153652314774863381845254278968224778478050456563329565810467774, 17166126583027276163107155648953851600645935739886150467584901586847365754678, 3612152772817685532768635636100598085437510685224817206515049967552954106764, 14450201850503471296781915119640920297985789873634237091629829669980153907901, 199455130043951077247265858823823987229570523056509026484192158816218200659, 24760239192664116622385963963284001971067308018068707868888628426778644166363]
    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)
    q = []
    q.append(0)
    q.append(0)
    q.append(1)
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    params['columns_rotations'] = []
    for i in range(14):
        params['columns_rotations'].append([0,])

    step_list = [3, 3, 3, 1, 1]
    # step_list.append(1)
    # step_list.append(1)
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)                                                 #step_list

    return params

if __name__ == '__main__':
   do_placeholder_verification_test_via_transact(test_contract_name, test_contract_path, linked_libs_names, init_test1)