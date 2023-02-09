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
import "../../gate_argument_interface.sol";
import "../init_vars.sol";

contract TestPlaceholderVerifierUniversal {
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
        int256[][] calldata columns_rotations,
        uint160    gate_argument_address
    ) public {
        init_vars.vars_t memory vars;
        init_vars.init(blob, init_params, columns_rotations, vars);

        types.placeholder_local_variables memory local_vars;

        // 3. append witness commitments to transcript
        transcript.update_transcript_b32_by_offset_calldata(vars.tr_state, blob, basic_marshalling.skip_length(vars.proof_map.variable_values_commitment_offset));

        // 4. prepare evaluaitons of the polynomials that are copy-constrained
        // 5. permutation argument
        local_vars.permutation_argument = permutation_argument.verify_eval_be(blob, vars.tr_state,
            vars.proof_map, vars.fri_params,
            vars.common_data, local_vars, vars.arithmetization_params);
        // 7. gate argument specific for circuit
        // Wait for better times.
        types.gate_argument_local_vars memory gate_params;
        gate_params.modulus = vars.fri_params.modulus;
        gate_params.theta = transcript.get_field_challenge(vars.tr_state, vars.fri_params.modulus);

        IGateArgument gate_argument_component = IGateArgument(address(gate_argument_address));
        local_vars.gate_argument = gate_argument_component.evaluate_gates_be(
            blob, 
            gate_params, 
            vars.proof_map.eval_proof_combined_value_offset, 
            vars.arithmetization_params, 
            vars.common_data.columns_rotations
        );
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
    }
}
