

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

import "../../types.sol";
import "../../cryptography/transcript.sol";
import "../proof_map_parser.sol";
import "../placeholder_verifier.sol";
import "../../logging.sol";
import "../../profiling.sol";
import "../../components/unified_addition_gen.sol";
import "../verifier_state.sol";

contract TestPlaceholderVerifierUnifiedAddition {
    event gas_usage_emit(uint8 command, string function_name, uint256 gas_usage);

    function verify(
        bytes calldata blob,
    // 0) modulus
    // 1) r
    // 2) max_degree
    // 3) lambda = 1
    // 4) rows_amount
    // 5) omega
    // 6) max_leaf_size
    // 7) D_omegas_size
    //  [..., D_omegas_i, ...]
    // 8 + D_omegas_size) q_size
    //  [..., q_i, ...]
        uint256[] calldata init_params,
        int256[][] calldata columns_rotations
    ) public {
        profiling.start_block("public_api_placeholder_unified_addition::component verify");
        verifier_config.config_type memory vars;
        verifier_config.init(blob, init_params, columns_rotations, vars);

        types.placeholder_state_type memory local_vars;

        // 3. append witness commitments to transcript
        transcript.update_transcript_b32_by_offset_calldata(vars.tr_state, blob, basic_marshalling.skip_length(vars.proof_map.variable_values_commitment_offset));

        // 4. prepare evaluaitons of the polynomials that are copy-constrained
        // 5. permutation argument
        profiling.start_block("public_api_placeholder_unified_addition::component permutation argument");
        local_vars.permutation_argument = permutation_argument.verify_eval_be(blob, vars.tr_state,
            vars.proof_map, vars.fri_params,
            vars.common_data, local_vars, vars.arithmetization_params);
        profiling.end_block();

        // 7. gate argument specific for circuit
        profiling.start_block("public_api_placeholder_unified_addition::component gate argument");
        types.gate_argument_state_type memory gate_params;
        gate_params.modulus = vars.fri_params.modulus;
        gate_params.theta = transcript.get_field_challenge(vars.tr_state, vars.fri_params.modulus);
        gate_params.eval_proof_witness_offset = vars.proof_map.eval_proof_variable_values_offset;
        gate_params.eval_proof_selector_offset = vars.proof_map.eval_proof_fixed_values_offset;
        gate_params.eval_proof_constant_offset = vars.proof_map.eval_proof_fixed_values_offset;

        local_vars.gate_argument = unified_addition_component_gen.evaluate_gates_be(
            blob, gate_params, vars.arithmetization_params
        );
        profiling.end_block();

        require(
            placeholder_verifier.verify_proof_be(
                blob,
                vars.tr_state,
                vars.proof_map,
                vars.fri_params,
                vars.common_data,
                local_vars,
                vars.arithmetization_params
            ),
            "Proof is not correct!"
        );
        profiling.end_block();
    }
}