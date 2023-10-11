
// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2022 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2022 Ilias Khairullin <ilias@nil.foundation>
// Copyright (c) 2022 Aleksei Moskvin <alalmoskvin@nil.foundation>
// Copyright (c) 2022-2023 Elena Tatuzova <e.tatuzova@nil.foundation>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//---------------------------------------------------------------------------//
pragma solidity >=0.8.4;

import "../../../contracts/types.sol";
import "./gate_argument.sol";

library template_gate4{
    uint256 constant MODULUS_OFFSET = 0x0;
    uint256 constant THETA_OFFSET = 0x20;

    uint256 constant CONSTRAINT_EVAL_OFFSET = 0x00;
    uint256 constant GATE_EVAL_OFFSET = 0x20;
    uint256 constant GATES_EVALUATIONS_OFFSET = 0x40;
    uint256 constant THETA_ACC_OFFSET = 0x60;
    
	uint256 constant WITNESS_EVALUATIONS_OFFSET = 0x80;
	uint256 constant CONSTANT_EVALUATIONS_OFFSET = 0xa0;
	uint256 constant SELECTOR_EVALUATIONS_OFFSET = 0xc0;


    function evaluate_gate_be(
        types.gate_argument_params memory gate_params,
        template_gate_argument_split_gen.local_vars_type memory local_vars
    ) external pure returns (uint256 gates_evaluation, uint256 theta_acc) {
        gates_evaluation = local_vars.gates_evaluation;
        theta_acc = local_vars.theta_acc;
        uint256 terms;
        assembly {
            let modulus := mload(gate_params)
            let theta := mload(add(gate_params, THETA_OFFSET))

            mstore(add(local_vars, GATE_EVAL_OFFSET), 0)

            function get_witness_i_by_rotation_idx(idx, rot_idx, ptr) -> result {
                result := mload(
                    add(
                        add(mload(add(add(mload(add(ptr, WITNESS_EVALUATIONS_OFFSET)), 0x20), mul(0x20, idx))), 0x20),
                        mul(0x20, rot_idx)
                    )
                )
            }

            function get_constant_i(idx, ptr) -> result {
                result := mload(add(add(mload(add(ptr, CONSTANT_EVALUATIONS_OFFSET)), 0x20), mul(0x20, idx)))
            }

            function get_selector_i(idx, ptr) -> result {
                result := mload(add(add(mload(add(ptr, SELECTOR_EVALUATIONS_OFFSET)), 0x20), mul(0x20, idx)))
            }

			//Gate4
			mstore(add(local_vars, GATE_EVAL_OFFSET), 0)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(0,0, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffc1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffff801
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfe000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(0,1, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffe3470
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ec8a24636a
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf8d2e61c5ca0a1eff23a
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(5,1, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x9de93ece51
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(6,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x6167eb8c7252078275a1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x12a4e415e1e1b36ff883d1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(8,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094ceb3152f48e386fe46402
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992767e469f2b8a8
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b9904b112fc6609d8
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf71eabf7085562106e72
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, GATE_EVAL_OFFSET),mulmod(mload(add(local_vars, GATE_EVAL_OFFSET)),get_selector_i(4,local_vars),modulus))
			gates_evaluation := addmod(gates_evaluation,mload(add(local_vars, GATE_EVAL_OFFSET)),modulus)

			//Gate5
			mstore(add(local_vars, GATE_EVAL_OFFSET), 0)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(0,1, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x57f6c1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1e39a5057d81
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xa62b942e656949441
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(0,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffff
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffe
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(0,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, GATE_EVAL_OFFSET),mulmod(mload(add(local_vars, GATE_EVAL_OFFSET)),get_selector_i(9,local_vars),modulus))
			gates_evaluation := addmod(gates_evaluation,mload(add(local_vars, GATE_EVAL_OFFSET)),modulus)

			//Gate6
			mstore(add(local_vars, GATE_EVAL_OFFSET), 0)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(4,2, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffc001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(6,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecf0000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecc0000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(8,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff01
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(6,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffff0001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecff000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(8,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_constant_i(0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(4,1, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x100000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(4,0, local_vars)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffff
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x2
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffe
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x3
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x6
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffb
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffd
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x4
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x8
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xc
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x18
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffc
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xa
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff7
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xf
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff2
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe3
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1e
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x14
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffed
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffd9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x28
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffc5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x3c
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x78
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff89
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, GATE_EVAL_OFFSET),mulmod(mload(add(local_vars, GATE_EVAL_OFFSET)),get_selector_i(6,local_vars),modulus))
			gates_evaluation := addmod(gates_evaluation,mload(add(local_vars, GATE_EVAL_OFFSET)),modulus)

			//Gate7
			mstore(add(local_vars, GATE_EVAL_OFFSET), 0)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(2,2, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x100000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffc001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(6,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecf0000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecc0000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(8,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff01
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(6,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffff0001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecff000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(8,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(3,2, local_vars)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffff
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x2
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffe
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x3
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x6
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffb
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffd
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x4
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x8
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xc
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x18
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffc
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xa
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff7
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xf
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff2
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe3
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1e
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x14
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffed
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffd9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x28
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffc5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x3c
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x78
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff89
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffb
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x6
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xc
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x12
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffef
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffdd
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x24
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x18
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffd1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x30
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffb9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x48
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x90
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff71
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1e
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe3
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffc5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x3c
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffa7
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x5a
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xb4
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff4d
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff89
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x78
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xf0
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff11
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x168
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffe99
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffd31
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x2d0
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, GATE_EVAL_OFFSET),mulmod(mload(add(local_vars, GATE_EVAL_OFFSET)),get_selector_i(7,local_vars),modulus))
			gates_evaluation := addmod(gates_evaluation,mload(add(local_vars, GATE_EVAL_OFFSET)),modulus)

			//Gate8
			mstore(add(local_vars, GATE_EVAL_OFFSET), 0)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(0,1, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x10000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x100000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1000000000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(0,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, GATE_EVAL_OFFSET),mulmod(mload(add(local_vars, GATE_EVAL_OFFSET)),get_selector_i(8,local_vars),modulus))
			gates_evaluation := addmod(gates_evaluation,mload(add(local_vars, GATE_EVAL_OFFSET)),modulus)

			//Gate9
			mstore(add(local_vars, GATE_EVAL_OFFSET), 0)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(0,2, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffd
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffe001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffc00001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(0,0, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfc000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d20ed00000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(2,2, local_vars)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffff
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x2
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffe
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x3
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x6
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffb
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(0,1, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x10000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x100000000000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(6,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1000000000000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b892d30acfff00001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d2cecff000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992cf0ecffc00000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d2fecfffc0000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, GATE_EVAL_OFFSET),mulmod(mload(add(local_vars, GATE_EVAL_OFFSET)),get_selector_i(5,local_vars),modulus))
			gates_evaluation := addmod(gates_evaluation,mload(add(local_vars, GATE_EVAL_OFFSET)),modulus)

			//Gate10
			mstore(add(local_vars, GATE_EVAL_OFFSET), 0)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(0,2, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x100000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(0,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(1,2, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x100000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(2,2, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x100000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(6,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(6,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(3,2, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x100000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,2, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, GATE_EVAL_OFFSET),mulmod(mload(add(local_vars, GATE_EVAL_OFFSET)),get_selector_i(10,local_vars),modulus))
			gates_evaluation := addmod(gates_evaluation,mload(add(local_vars, GATE_EVAL_OFFSET)),modulus)

			//Gate11
			mstore(add(local_vars, GATE_EVAL_OFFSET), 0)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(1,2, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ec00000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(6,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91a992d30ed00000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fb094cf91b992d30ed00000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(0,2, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ec00000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91a992d30ed00000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fb094cf91b992d30ed00000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(0,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, GATE_EVAL_OFFSET),mulmod(mload(add(local_vars, GATE_EVAL_OFFSET)),get_selector_i(11,local_vars),modulus))
			gates_evaluation := addmod(gates_evaluation,mload(add(local_vars, GATE_EVAL_OFFSET)),modulus)

			//Gate12
			mstore(add(local_vars, GATE_EVAL_OFFSET), 0)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=get_witness_i_by_rotation_idx(0,1, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=get_witness_i_by_rotation_idx(1,1, local_vars)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, local_vars), modulus)
			mstore(add(local_vars, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(local_vars, GATE_EVAL_OFFSET),addmod(mload(add(local_vars, GATE_EVAL_OFFSET)),mulmod(mload(add(local_vars, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc, theta, modulus)
			mstore(add(local_vars, GATE_EVAL_OFFSET),mulmod(mload(add(local_vars, GATE_EVAL_OFFSET)),get_selector_i(12,local_vars),modulus))
			gates_evaluation := addmod(gates_evaluation,mload(add(local_vars, GATE_EVAL_OFFSET)),modulus)


        }
    }
}
