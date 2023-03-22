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
import "../logging.sol";
import "../cryptography/transcript.sol";

import "../placeholder/proof_map_parser.sol";
import "../placeholder/placeholder_verifier.sol";
import "../placeholder/init_vars.sol";

import "../interfaces/verifier.sol";
import "../interfaces/gate_argument.sol";

contract PlaceholderVerifier is IVerifier {
    // event renamed to prevent conflicts with logging system
    event gas_usage_emit(uint256 gas_usage);

    struct gas_usage {
        uint256 start;
        uint256 end;
    }

    struct verifier_state {
        uint256 proofs_num;
        uint256 proof_offset;
        uint256 proof_size;
        uint256 ind;

        types.fri_params_type fri_params;
        types.placeholder_proof_map proof_map;
        types.transcript_data tr_state;
        types.placeholder_common_data common_data;
        types.arithmetization_params arithmetization_params;
    }

    function init_vars(verifier_state memory vars, uint256[] memory init_params, int256[][] memory columns_rotations) internal view {
        uint256 idx = 0;
        vars.fri_params.modulus = init_params[idx++];
        vars.fri_params.r = init_params[idx++];
        vars.fri_params.max_degree = init_params[idx++];
        vars.fri_params.lambda = init_params[idx++];

        vars.common_data.rows_amount = init_params[idx++];
        vars.common_data.omega = init_params[idx++];
        vars.fri_params.max_batch = init_params[idx++];
        placeholder_proof_map_parser.init(vars.fri_params, vars.fri_params.max_batch);

        vars.common_data.columns_rotations = columns_rotations;

        vars.fri_params.D_omegas = new uint256[](init_params[idx++]);
        for (uint256 i = 0; i < vars.fri_params.D_omegas.length;) {
            vars.fri_params.D_omegas[i] = init_params[idx];
        unchecked{i++;
            idx++;}
        }
        vars.fri_params.q = new uint256[](init_params[idx++]);
        for (uint256 i = 0; i < vars.fri_params.q.length;) {
            vars.fri_params.q[i] = init_params[idx];
        unchecked{i++;
            idx++;}
        }

        vars.fri_params.step_list = new uint256[](init_params[idx++]);
        vars.fri_params.max_step = 0;
        for (uint256 i = 0; i < vars.fri_params.step_list.length;) {
            vars.fri_params.step_list[i] = init_params[idx];
            if (vars.fri_params.step_list[i] > vars.fri_params.max_step)
                vars.fri_params.max_step = vars.fri_params.step_list[i];
        unchecked{i++;
            idx++;}
        }

    unchecked{
        idx++;
        // arithmetization_params length;
        vars.arithmetization_params.witness_columns = init_params[idx++];
        vars.arithmetization_params.public_input_columns = init_params[idx++];
        vars.arithmetization_params.constant_columns = init_params[idx++];
        vars.arithmetization_params.selector_columns = init_params[idx++];
        vars.arithmetization_params.permutation_columns = vars.arithmetization_params.witness_columns
        + vars.arithmetization_params.public_input_columns
        + vars.arithmetization_params.constant_columns;
    }
    }

    function allocate_all(verifier_state memory vars, uint256 max_step, uint256 max_batch) internal view {
        uint256 max_coset = 1 << (vars.fri_params.max_step - 1);

        vars.fri_params.s_indices = new uint256[](max_coset);
        vars.fri_params.correct_order_idx = new uint256[](max_coset);
        vars.fri_params.tmp_arr = new uint256[](max_coset << 1);
        vars.fri_params.s = new uint256[](max_coset);
        vars.fri_params.coeffs = new uint256[](max_coset << 1);
        vars.fri_params.b = new bytes(vars.fri_params.max_batch << (vars.fri_params.max_step + 5));
        vars.fri_params.precomputed_eval1 = new uint256[](5);
    }

    function verify(bytes calldata blob, uint256[][] calldata init_params,
        int256[][][] calldata columns_rotations, address gate_argument) public returns (bool) {
        gas_usage memory gas_usage;
        gas_usage.start = gasleft();

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
        gate_params.eval_proof_witness_offset = vars.proof_map.eval_proof_variable_values_offset;
        gate_params.eval_proof_selector_offset = vars.proof_map.eval_proof_fixed_values_offset;
        gate_params.eval_proof_constant_offset = vars.proof_map.eval_proof_fixed_values_offset;

        IGateArgument gate_argument_component = IGateArgument(gate_argument);
        local_vars.gate_argument = gate_argument_component.evaluate_gates_be(blob, gate_params,
            vars.arithmetization_params, vars.common_data.columns_rotations);

        bool ret = placeholder_verifier.verify_proof_be(blob, vars.tr_state,
            vars.proof_map, vars.fri_params, vars.common_data, local_vars,
            vars.arithmetization_params);
        require(ret, "Proof is not correct!");

        gas_usage.end = gasleft();
        emit gas_usage_emit(gas_usage.start - gas_usage.end);

        return ret;
    }
}
