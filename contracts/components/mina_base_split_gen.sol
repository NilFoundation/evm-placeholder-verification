// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2022 Mikhail Komarov <nemo@nil.foundation>
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
import "../profiling.sol";
import "../basic_marshalling.sol";
import "../commitments/batched_lpc_verifier.sol";
import "./mina_base/mina_base_gate0.sol";
import "./mina_base/mina_base_gate4.sol";
import "./mina_base/mina_base_gate7.sol";
import "./mina_base/mina_base_gate10.sol";
import "./mina_base/mina_base_gate13.sol";
import "./mina_base/mina_base_gate15.sol";
import "./mina_base/mina_base_gate16.sol";
import "./mina_base/mina_base_gate16_1.sol";

import "../interfaces/gate_argument.sol";

// TODO: name component
library mina_base_split_gen {
    // TODO: specify constants
    uint256 constant GATES_N = 23;

    // TODO: columns_rotations could be hard-coded
    function evaluate_gates_be(
        bytes calldata blob,
        types.gate_argument_local_vars memory gate_params,
        uint256 eval_proof_combined_value_offset,
        types.arithmetization_params memory ar_params,
        int256[][] memory columns_rotations
    ) internal returns (uint256 gates_evaluation) {
        // TODO: check witnesses number in proof
        profiling.start_block("mina_base_split_gen:evaluate_gates_be");

        gate_params.witness_evaluations = new uint256[][](ar_params.witness_columns);
        for (uint256 i = 0; i < ar_params.witness_columns; i++) {
            gate_params.witness_evaluations[i] = new uint256[](columns_rotations[i].length);
            for (uint256 j = 0; j < columns_rotations[i].length; j++) {
                gate_params.witness_evaluations[i][j] = batched_lpc_verifier.get_variable_values_z_i_j_from_proof_be(
                    blob, eval_proof_combined_value_offset, i, j
                );
            }
        }


        gate_params.selector_evaluations = new uint256[](GATES_N);
        for (uint256 i = 0; i < GATES_N; i++) {
            gate_params.selector_evaluations[i] = batched_lpc_verifier.get_fixed_values_z_i_j_from_proof_be(
                    blob,
                    eval_proof_combined_value_offset,
                    i + ar_params.permutation_columns + ar_params.permutation_columns + ar_params.constant_columns,
                    0
            );
        }

        gate_params.constant_evaluations = new uint256[](ar_params.constant_columns);
        for (uint256 i = 0; i < ar_params.constant_columns; i++) {
            gate_params.constant_evaluations[i] = batched_lpc_verifier.get_fixed_values_z_i_j_from_proof_be(
                    blob,
                    eval_proof_combined_value_offset,
                    i + ar_params.permutation_columns + ar_params.permutation_columns,
                    0
            );
        }


        gate_params.theta_acc = 1;
        gate_params.gates_evaluation = 0;

        (gate_params.gates_evaluation, gate_params.theta_acc) = mina_base_gate0.evaluate_gate_be(gate_params);
        (gate_params.gates_evaluation, gate_params.theta_acc) = mina_base_gate4.evaluate_gate_be(gate_params);
        (gate_params.gates_evaluation, gate_params.theta_acc) = mina_base_gate7.evaluate_gate_be(gate_params);
        (gate_params.gates_evaluation, gate_params.theta_acc) = mina_base_gate10.evaluate_gate_be(gate_params);
        (gate_params.gates_evaluation, gate_params.theta_acc) = mina_base_gate13.evaluate_gate_be(gate_params);
        (gate_params.gates_evaluation, gate_params.theta_acc) = mina_base_gate15.evaluate_gate_be(gate_params);
        (gate_params.gate_eval, gate_params.theta_acc) = mina_base_gate16.evaluate_gate_be(gate_params);
        (gate_params.gates_evaluation, gate_params.theta_acc) = mina_base_gate16_1.evaluate_gate_be(gate_params);
        gates_evaluation = gate_params.gates_evaluation;
        profiling.end_block();
    }
}