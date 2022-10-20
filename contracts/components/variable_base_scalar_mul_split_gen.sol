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

import "../types.sol";
import "../basic_marshalling.sol";
import "../commitments/batched_lpc_verifier.sol";
import "./variable_base_scalar_mul/gate0.sol";
import "./variable_base_scalar_mul/gate1.sol";

// TODO: name component
library variable_base_scalar_mul_split_gen {
    // TODO: specify constants
    uint256 constant WITNESSES_N = 15;
    uint256 constant GATES_N = 2;

    // TODO: columns_rotations could be hard-coded
    function evaluate_gates_be(
        bytes calldata blob,
        types.gate_argument_local_vars memory gate_params,
        int256[][] memory columns_rotations
    ) internal pure returns (uint256 gates_evaluation) {
        // TODO: check witnesses number in proof

        gate_params.witness_evaluations = new uint256[][](WITNESSES_N);
        for (uint256 i = 0; i < WITNESSES_N; i++) {
            gate_params.witness_evaluations[i] = new uint256[](columns_rotations[i].length);
            for (uint256 j = 0; j < columns_rotations[i].length; j++) {
                gate_params.witness_evaluations[i][j] = batched_lpc_verifier
                    .get_z_i_j_from_proof_be(blob, gate_params.eval_proof_witness_offset, i, j);
            }
        }
        gate_params.selector_evaluations = new uint256[](GATES_N);
        for (uint256 i = 0; i < GATES_N; i++) {
            gate_params.selector_evaluations[i] = batched_lpc_verifier
                .get_z_i_j_from_proof_be(blob, gate_params.eval_proof_selector_offset, i, 0);
        }

        gate_params.theta_acc = 1;
        (gate_params.gates_evaluation, gate_params.theta_acc) = variable_base_scalar_mul_gate0.evaluate_gate_be(gate_params);

        (gate_params.gates_evaluation, gate_params.theta_acc) = variable_base_scalar_mul_gate1.evaluate_gate_be(gate_params);
        // require(false, logging.uint2decstr(gate_params.gates_evaluation));

        gates_evaluation = gate_params.gates_evaluation;
    }
}
