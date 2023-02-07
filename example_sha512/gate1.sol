
// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2022 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2022 Ilias Khairullin <ilias@nil.foundation>
// Copyright (c) 2022 Aleksei Moskvin <alalmoskvin@nil.foundation>
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

import "../contracts/types.sol";
import "../contracts/logging.sol";

// TODO: name component
library gate1{
    uint256 constant MODULUS_OFFSET = 0x0;
    uint256 constant THETA_OFFSET = 0x20;
    uint256 constant CONSTRAINT_EVAL_OFFSET = 0x40;
    uint256 constant GATE_EVAL_OFFSET = 0x60;
    uint256 constant GATES_EVALUATIONS_OFFSET = 0x80;
    uint256 constant THETA_ACC_OFFSET = 0xa0;
    uint256 constant WITNESS_EVALUATIONS_OFFSET = 0xc0;
    uint256 constant CONSTANT_EVALUATIONS_OFFSET = 0xe0;
    uint256 constant SELECTOR_EVALUATIONS_OFFSET =0x100;
    uint256 constant PUBLIC_INPUT_EVALUATIONS_OFFSET =0x120;

    function evaluate_gate_be(
        types.gate_argument_local_vars memory gate_params
    ) external pure returns (uint256 gates_evaluation, uint256 theta_acc) {
        gates_evaluation = gate_params.gates_evaluation;
        theta_acc = gate_params.theta_acc;
        uint256 terms;
        assembly {
            let modulus := mload(gate_params)
            mstore(add(gate_params, GATE_EVAL_OFFSET), 0)

            function get_witness_i_by_rotation_idx(idx, rot_idx, ptr) -> result {
                result := mload(
                    add(
                        add(mload(add(add(mload(add(ptr, WITNESS_EVALUATIONS_OFFSET)), 0x20), mul(0x20, idx))), 0x20),
                        mul(0x20, rot_idx)
                    )
                )
            }

            function get_selector_i(idx, ptr) -> result {
                result := mload(add(add(mload(add(ptr, SELECTOR_EVALUATIONS_OFFSET)), 0x20), mul(0x20, idx)))
            }

            function get_public_input_i(idx, ptr) -> result {
                result := mload(add(add(mload(add(ptr, PUBLIC_INPUT_EVALUATIONS_OFFSET)), 0x20), mul(0x20, idx)))
            }

            // rot_idx is temporary unused
            function get_constant_i_by_rotation_idx(idx, rot_idx, ptr) -> result {
                result := mload(add(add(mload(add(ptr, CONSTANT_EVALUATIONS_OFFSET)), 0x20), mul(0x20, idx)))
            }

			//Gate1
			mstore(add(gate_params, GATE_EVAL_OFFSET), 0)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff81
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffc0001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(0,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffec51
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x13b0
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x9d8
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffff629
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x690
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffff971
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffcb9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x348
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x4ec
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffb15
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffd8b
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x276
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffe5d
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1a4
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xd2
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff2f
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x3f0
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffc11
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffe09
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1f8
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffeb1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x150
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xa8
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff59
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff05
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xfc
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x7e
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff83
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x54
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffad
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffd7
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x2a
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x348
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffcb9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffe5d
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1a4
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffee9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x118
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x8c
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff75
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff2f
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xd2
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x69
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff98
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x46
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffbb
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffde
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x23
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff59
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xa8
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x54
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffad
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x38
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffc9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1c
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x2a
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffd7
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffec
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x15
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff3
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xe
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x7
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffa
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x2d0
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffd31
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffe99
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x168
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff11
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xf0
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x78
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff89
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff4d
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xb4
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x5a
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffa7
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x3c
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffc5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe3
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1e
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff71
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x90
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x48
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffb9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x30
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffd1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x18
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x24
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffdd
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffef
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x12
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xc
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x6
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffb
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffff89
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x78
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x3c
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffc5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x28
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffd9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffed
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x14
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1e
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe3
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff2
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xf
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff7
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xa
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffc
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x18
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffe9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff5
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0xc
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffff9
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x8
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x4
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffd
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffb
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x6
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x3
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffe
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x2
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffff
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(1,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET), 0)
			terms:=0x10000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(6,0, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(5,0, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x100000000000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,0, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x1000000000000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(8,2, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b982d30e900000000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(2,0, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d2cecffffff00
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(3,0, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992d30ecbfc00000
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(4,0, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			terms:=0x40000000000000000000000000000000224698fc094cf91b992930ecf0000001
			terms:=mulmod(terms, get_witness_i_by_rotation_idx(7,1, gate_params), modulus)
			mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),terms,modulus))
			mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
			theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
			mstore(add(gate_params, GATE_EVAL_OFFSET),mulmod(mload(add(gate_params, GATE_EVAL_OFFSET)),get_selector_i(1,gate_params),modulus))
			gates_evaluation := addmod(gates_evaluation,mload(add(gate_params, GATE_EVAL_OFFSET)),modulus)

        }
    }
}
