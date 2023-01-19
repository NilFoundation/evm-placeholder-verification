from web3_test import do_placeholder_verification_test_via_transact, base_path, do_placeholder_verification_test_via_transact_simple
import sys

test_contract_name = 'TestPlaceholderVerifierMinaBase'
test_contract_path = 'placeholder/test/public_api_placeholder_mina_base_component.sol'
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
    "mina_base_gate16_1",
    "mina_base_gate17",
    "mina_base_gate18",
    "placeholder_verifier"
]
   
def init_test1():
    params = dict()
    params['_test_name'] = "Placeholder proof verification for mina"
    f = open(base_path + '/test/data/generated_eval1_step1_base.data')
    params["proof"] = f.read()
    f.close()

    params['init_params'] = []
    params['init_params'].append(28948022309329048855892746252171976963363056481941560715954676764349967630337)
    params['init_params'].append(13)
    params['init_params'].append(16383)
    params['init_params'].append(1)
    params['init_params'].append(16384)
    params['init_params'].append(26495698845590383240609604404074423972849566255661802313591097233811292788392)
    params['init_params'].append(67)
    D_omegas = [
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

        24760239192664116622385963963284001971067308018068707868888628426778644166363,
    ]

    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)
    q = [0, 0, 1]
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    step_list = [1] * 13
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list

    arithmetization_params = [15, 1, 1, 30] # witness, public_input, constant, selector
    params['init_params'].append((len(arithmetization_params)))
    params['init_params'].extend(arithmetization_params)

    params['columns_rotations'] = [ [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [2, 0, 1, 0 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [2, 0, -1, 0],
                                    [2, 0, -1, 0],
                                    [2, 0, -1, 0],
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ]]
    
    params['log_file'] = 'logs/mina_base_test_eval1_step_1.json'

    return params

def init_test2():
    params = dict()
    params['_test_name'] = "Placeholder proof verification for mina"
    f = open(base_path + '/test/data/generated_eval10_step1_base.data')
    params["proof"] = f.read()
    f.close()

    params['init_params'] = []
    params['init_params'].append(28948022309329048855892746252171976963363056481941560715954676764349967630337)
    params['init_params'].append(16)
    params['init_params'].append(131071)
    params['init_params'].append(1)
    params['init_params'].append(131072)
    params['init_params'].append(21090803083255360924969619711782040241928172562822879037017685322859036642027)
    params['init_params'].append(67)
    D_omegas = [
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

        24760239192664116622385963963284001971067308018068707868888628426778644166363,
                ]

    params['init_params'].append(len(D_omegas))
    params['init_params'].extend(D_omegas)
    q = [0, 0, 1]
    params['init_params'].append(len(q))
    params['init_params'].extend(q)

    step_list = [1] * 16
    params['init_params'].append(len(step_list))
    params['init_params'].extend(step_list)  # step_list

    arithmentization_params = [15, 1, 1, 30] # witness, public_input, constant, selector
    params['init_params'].append((len(arithmentization_params)))
    params['init_params'].extend(arithmentization_params)

    params['columns_rotations'] = [ [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [2, 0, 1, 0 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [3, 0, 1, -1 ],
                                    [2, 0, -1, 0],
                                    [2, 0, -1, 0],
                                    [2, 0, -1, 0],
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], [1, 0, 0, 0 ], 
                                    [1, 0, 0, 0 ], [1, 0, 0, 0 ]]
    params['log_file'] = 'logs/mina_base_test_eval10_step_1.json'
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
