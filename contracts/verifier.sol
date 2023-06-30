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

import "./types.sol";
import "./cryptography/transcript.sol";
import "./algebra/field.sol";

import "./placeholder/proof_map_parser.sol";
import "./placeholder/permutation_argument.sol";
import "./commitments/batched_lpc_verifier.sol";

import "./placeholder/placeholder_verifier.sol";
import "./interfaces/verifier.sol";
import "./interfaces/gate_argument.sol";

contract PlaceholderVerifier is IVerifier {
    struct verifier_state {
        uint256 proofs_num;
        uint256 proof_offset;
        uint256 proof_size;
        uint256 ind;

        types.fri_params_type           fri_params;
        types.placeholder_proof_map     proof_map;
        types.transcript_data           tr_state;
        types.placeholder_common_data   common_data;
        types.arithmetization_params    arithmetization_params;
    }

    function init_vars(
        verifier_state memory vars, 
        uint256[] memory init_params, 
        int256[][] memory columns_rotations
    ) internal pure {
        uint256 idx;
        uint256 max_coset;
        uint256 i;

        vars.fri_params.modulus = init_params[idx++];
        vars.fri_params.r = init_params[idx++];
        vars.fri_params.max_degree = init_params[idx++];
        vars.fri_params.lambda = init_params[idx++];

        vars.common_data.rows_amount = init_params[idx++];
        vars.common_data.omega = init_params[idx++];
        vars.common_data.columns_rotations = columns_rotations;

        vars.fri_params.D_omegas = new uint256[](init_params[idx++]);
        for (i = 0; i < vars.fri_params.D_omegas.length;) {
            vars.fri_params.D_omegas[i] = init_params[idx];
        unchecked{ i++; idx++;}
        }

        vars.fri_params.max_step = 0;
        vars.fri_params.step_list = new uint256[](init_params[idx++]);
        for (i = 0; i < vars.fri_params.step_list.length;) {
            vars.fri_params.step_list[i] = init_params[idx];
            if(vars.fri_params.step_list[i] > vars.fri_params.max_step)
                vars.fri_params.max_step = vars.fri_params.step_list[i];
            unchecked{ i++; idx++;}
        }

        unchecked{
            idx++; // arithmetization_params length;
            vars.arithmetization_params.witness_columns = init_params[idx++];
            vars.arithmetization_params.public_input_columns = init_params[idx++];
            vars.arithmetization_params.constant_columns = init_params[idx++];
            vars.arithmetization_params.selector_columns = init_params[idx++];
            vars.arithmetization_params.permutation_columns = vars.arithmetization_params.witness_columns 
                + vars.arithmetization_params.public_input_columns 
                + vars.arithmetization_params.constant_columns;
        }

        unchecked{ max_coset = 1 << (vars.fri_params.max_step - 1);}

        vars.fri_params.max_coset = max_coset;
        vars.fri_params.s_indices = new uint256[](max_coset);
        vars.fri_params.correct_order_idx = new uint256[](max_coset);
        vars.fri_params.tmp_arr = new uint256[](max_coset << 1);
        vars.fri_params.s = new uint256[](max_coset);
        vars.fri_params.batches_num = 4;
        vars.fri_params.batches_sizes = new uint256[](vars.fri_params.batches_num);
        vars.fri_params.batches_sizes[0] = vars.arithmetization_params.witness_columns + vars.arithmetization_params.public_input_columns;        
        vars.fri_params.batches_sizes[1] = 1;
            // TODO We don't know T_polynomials size. 
            // We'll extract it from proof in parse_be function 
            //      and verify fri_proof.query_proof[i].initial_proof[2].values have 
        vars.fri_params.batches_sizes[2] = 0; 
        vars.fri_params.batches_sizes[3] = vars.arithmetization_params.permutation_columns 
            + vars.arithmetization_params.permutation_columns
            + vars.arithmetization_params.constant_columns 
            + vars.arithmetization_params.selector_columns + 2;
    }

    function check_public_input(verifier_state memory vars, uint256[] calldata public_input, bytes calldata blob) internal view {
        uint256 xi = basic_marshalling.get_uint256_be(blob, vars.proof_map.eval_proof_offset);
        uint256 result = 0;
        uint256 Omega = 1;

        for(uint256 i = 0; i < public_input.length;){
            if( public_input[i] != 0){
                uint256 L = mulmod(
                    Omega,
                    field.inverse_static(
                        addmod(xi, vars.fri_params.modulus - Omega, vars.fri_params.modulus),
                        vars.fri_params.modulus
                    ),
                    vars.fri_params.modulus
                );
                    
                result = addmod(
                    result, 
                    mulmod(
                        public_input[i],
                        L,
                        vars.fri_params.modulus
                    ), 
                    vars.fri_params.modulus
                );
            }
            Omega = mulmod(Omega, vars.common_data.omega, vars.fri_params.modulus);
            unchecked{i++;}
        }
        result = mulmod(
            result, 
            addmod(field.pow_small(xi, vars.common_data.rows_amount, vars.fri_params.modulus), vars.fri_params.modulus - 1, vars.fri_params.modulus), 
            vars.fri_params.modulus
        );
        result = mulmod(result, field.inverse_static(vars.common_data.rows_amount, vars.fri_params.modulus), vars.fri_params.modulus);

        // Input is proof_map.eval_proof_combined_value_offset
        require( result == batched_lpc_verifier.get_variable_values_z_i_j_from_proof_be(
            blob, 
            vars.proof_map.eval_proof_combined_value_offset, 
            vars.arithmetization_params.witness_columns, 
            0
        ));
    }

    function verify(
        bytes calldata blob, 
        uint256[] calldata init_params,
        int256[][] calldata columns_rotations, 
        uint256[] calldata public_input,
        address gate_argument
    ) public view returns (bool result) {
        verifier_state memory vars;
        init_vars(vars, init_params, columns_rotations);
        transcript.init_transcript(vars.tr_state, hex"");
        
        (vars.proof_map, vars.proof_size) = placeholder_proof_map_parser.parse_be(blob, 0);
        if(vars.proof_size != blob.length) return false;
        (result, )= batched_lpc_verifier.parse_proof_be(vars.fri_params, blob, vars.proof_map.eval_proof_combined_value_offset);
        if( !result ) return false;

        types.placeholder_state_type memory local_vars;

        // 3. append witness commitments to transcript
        transcript.update_transcript_b32_by_offset_calldata(vars.tr_state, blob, basic_marshalling.skip_length(vars.proof_map.variable_values_commitment_offset));

        // 2. check public input
        //if(public_input.length > 0) check_public_input(vars, public_input, blob);

        // 4. prepare evaluations of the polynomials that are copy-constrained
        // 5. permutation argument
        local_vars.permutation_argument = permutation_argument.verify_eval_be(blob, vars.tr_state,
            vars.proof_map, vars.fri_params,
            vars.common_data, local_vars, vars.arithmetization_params);

        // 7. gate argument specific for circuit
        types.gate_argument_params memory gate_params;
        gate_params.modulus = vars.fri_params.modulus;
        gate_params.theta = transcript.get_field_challenge(vars.tr_state, vars.fri_params.modulus);

        IGateArgument gate_argument_component = IGateArgument(gate_argument);
        local_vars.gate_argument = gate_argument_component.evaluate_gates_be(
            blob, 
            vars.proof_map.eval_proof_combined_value_offset,  
            gate_params,
            vars.arithmetization_params,
            vars.common_data.columns_rotations
        );

        if (!placeholder_verifier.verify_proof_be(
            blob, 
            vars.tr_state,
            vars.proof_map, 
            vars.fri_params, vars.common_data, local_vars,
            vars.arithmetization_params))
            return false;
        return true;
    }
}