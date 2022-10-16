// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2022 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2022 Ilias Khairullin <ilias@nil.foundation>
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

import "../../types.sol";
import "../../logging.sol";

// TODO: name component
library kimchi_base_field_gate14 {

    uint256 constant THETA_OFFSET = 0x20;
    uint256 constant CONSTRAINT_EVAL_OFFSET = 0x40;
    uint256 constant GATE_EVAL_OFFSET = 0x60;
    uint256 constant SELECTOR_EVALUATIONS_OFFSET = 0xa0;
    uint256 constant WITNESS_EVALUATIONS_OFFSET = 0x180;

    // TODO: columns_rotations could be hard-coded
    function evaluate_gate_be(
        types.gate_argument_local_vars memory gate_params
    ) external pure returns (uint256 gates_evaluation, uint256 theta_acc) {
        gates_evaluation = gate_params.gates_evaluation;
        theta_acc = gate_params.theta_acc;
        assembly {
            let modulus := mload(gate_params)
            let witness_evaluations_ptr := mload(add(gate_params, WITNESS_EVALUATIONS_OFFSET))
            mstore(add(gate_params, GATE_EVAL_OFFSET), 0)

            function get_W_i_by_rotation_idx(idx, rot_idx, ptr) -> result {
                result := mload(
                    add(
                        add(mload(add(add(ptr, 0x20), mul(0x20, idx))), 0x20),
                        mul(0x20, rot_idx)
                    )
                )
            }

            function get_selector_i(idx, ptr) -> result {
                result := mload(add(add(ptr, 0x20), mul(0x20, idx)))
            }

mstore(add(gate_params, GATE_EVAL_OFFSET), 0)
mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET), 0)
mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),mulmod(0x10000000000000000,get_W_i_by_rotation_idx(1,0,mload(add(gate_params, WITNESS_EVALUATIONS_OFFSET))),modulus),modulus))
mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),get_W_i_by_rotation_idx(0,0,mload(add(gate_params, WITNESS_EVALUATIONS_OFFSET))),modulus))
mstore(add(gate_params, CONSTRAINT_EVAL_OFFSET),addmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),mulmod(0x40000000000000000000000000000000224698fc0994a8dd8c46eb2100000000,get_W_i_by_rotation_idx(2,0,mload(add(gate_params, WITNESS_EVALUATIONS_OFFSET))),modulus),modulus))
mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(add(gate_params, CONSTRAINT_EVAL_OFFSET)),theta_acc,modulus),modulus))
theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
mstore(add(gate_params, GATE_EVAL_OFFSET),mulmod(mload(add(gate_params, GATE_EVAL_OFFSET)),get_selector_i(14,mload(add(gate_params, SELECTOR_EVALUATIONS_OFFSET))),modulus))
gates_evaluation := addmod(gates_evaluation,mload(add(gate_params, GATE_EVAL_OFFSET)),modulus)
        }
    }
}
