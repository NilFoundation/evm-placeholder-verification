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
import "../cryptography/transcript.sol";
import "../commitments/batched_lpc_verifier.sol";
import "./permutation_argument.sol";
import "../basic_marshalling.sol";
import "../algebra/field.sol";
import "../logging.sol";
import "../profiling.sol";


library placeholder_verifier {
    // TODO: check correctness all this const
    uint256 constant f_parts = 9;

    uint256 constant OMEGA_OFFSET = 0x20;

    uint256 constant LEN_OFFSET = 0x0;
    uint256 constant OFFSET_OFFSET = 0x20;
    uint256 constant ZERO_INDEX_OFFSET = 0x40;
    uint256 constant PERMUTATION_ARGUMENT_OFFSET = 0x60;
    uint256 constant GATE_ARGUMENT_OFFSET = 0x80;
    uint256 constant ALPHAS_OFFSET = 0xa0;
    uint256 constant CHALLENGE_OFFSET = 0xc0;
    uint256 constant E_OFFSET = 0xe0;
    uint256 constant EVALUATION_POINTS_OFFSET = 0x100;
    uint256 constant F_OFFSET = 0x120;
    uint256 constant F_CONSOLIDATED_OFFSET = 0x140;
    uint256 constant T_CONSOLIDATED_OFFSET = 0x160;
    uint256 constant Z_AT_CHALLENGE_OFFSET = 0x180;
    uint256 constant BETA_OFFSET = 0x1a0;
    uint256 constant GAMMA_OFFSET = 0x1c0;
    uint256 constant G_OFFSET = 0x1e0;
    uint256 constant H_OFFSET = 0x200;
    uint256 constant PERM_POLYNOMIAL_VALUE_OFFSET = 0x220;
    uint256 constant PERM_POLYNOMIAL_SHIFTED_VALUE_OFFSET = 0x240;
    uint256 constant Q_BLIND_EVAL_OFFSET = 0x260;
    uint256 constant Q_LAST_EVAL_OFFSET = 0x280;
    uint256 constant S_ID_I_OFFSET = 0x2a0;
    uint256 constant S_SIGMA_I_OFFSET = 0x2c0;
    uint256 constant WITNESS_EVALUATION_POINTS_OFFSET = 0x2e0;
    uint256 constant STATUS_OFFSET = 0x3a0;

    function verify_proof_be(
        bytes calldata blob,
        types.transcript_data memory tr_state,
        types.placeholder_proof_map memory proof_map,
        types.fri_params_type memory fri_params,
        types.placeholder_common_data memory common_data,
        types.placeholder_local_variables memory local_vars,
        types.arithmetization_params memory ar_params
    ) external returns (bool result) {
        profiling.start_block("PV::verify_proof_be");
        // 8. alphas computations
        local_vars.alphas = new uint256[](f_parts);
        transcript.get_field_challenges(tr_state, local_vars.alphas, fri_params.modulus);

        // 9. Evaluation proof check
        transcript.update_transcript_b32_by_offset_calldata(tr_state, blob, basic_marshalling.skip_length(proof_map.T_commitments_offset));
        local_vars.challenge = transcript.get_field_challenge(tr_state, fri_params.modulus);
        if (local_vars.challenge != basic_marshalling.get_uint256_be(blob, proof_map.eval_proof_offset)) {
            require(false, "Wrong challenge");
            return false;
        }

        // variable values
        profiling.start_block("PV::variable_values");
        profiling.start_block("PV::prepare points");

        uint256 inversed_omega = field.inverse_static(common_data.omega, fri_params.modulus);
        uint256 challenge_omega = field.fmul(local_vars.challenge, common_data.omega, fri_params.modulus);
        uint256 challenge_inversed_omega = field.fmul(local_vars.challenge, inversed_omega, fri_params.modulus);
        uint256[] memory challenge_point = new uint256[](1);
        challenge_point[0] = local_vars.challenge;

        fri_params.leaf_size = batched_lpc_verifier.get_variable_values_n_be(blob, proof_map.eval_proof_combined_value_offset);
        local_vars.variable_values_evaluation_points = new uint256[][](fri_params.leaf_size);

        for (uint256 i = 0; i < ar_params.witness_columns;) {
            local_vars.variable_values_evaluation_points[i] = new uint256[](common_data.columns_rotations[i].length);
            for (uint256 j = 0; j < common_data.columns_rotations[i].length;) {
                if(common_data.columns_rotations[i][j] == 0){
                    local_vars.variable_values_evaluation_points[i][j] = local_vars.challenge;
                } else if(common_data.columns_rotations[i][j] == 1){
                    local_vars.variable_values_evaluation_points[i][j] = challenge_omega;
                } else if(common_data.columns_rotations[i][j] == -1) {
                    local_vars.variable_values_evaluation_points[i][j] = challenge_inversed_omega;
                } else {
                    // TODO: check properly if column_rotations will be not one of 0, +-1
                    // local_vars.variable_values_evaluation_points[i][j] = local_vars.challenge * omega ^ column_rotations[i][j]
                    uint256 omega;
                    uint256 e;

                    if (common_data.columns_rotations[i][j] < 0) {
                        omega = inversed_omega;
                        e = uint256(-common_data.columns_rotations[i][j]);
                    } else {
                        omega = common_data.omega;
                        e = uint256(common_data.columns_rotations[i][j]);
                    }
                    assembly{
                        for{mstore(add(local_vars, E_OFFSET), mload(add(local_vars, CHALLENGE_OFFSET)))} gt(e,0) {e := shr(e, 1)} {
                            if not(eq(and(e,1), 0)){
                                mstore(add(local_vars, E_OFFSET),mulmod(mload(add(local_vars, E_OFFSET)), omega, mload(fri_params)))
                            }
                            if not(eq(e, 1)){
                                omega := mulmod(omega,omega, mload(fri_params))
                            }
                        }
                    }
                    local_vars.variable_values_evaluation_points[i][j] = local_vars.e;
                }
            unchecked{j++;}
            }
        unchecked{i++;}
        }

        for (uint256 i = ar_params.witness_columns; i < ar_params.witness_columns + ar_params.public_input_columns;) {
            local_vars.variable_values_evaluation_points[i] = challenge_point;
            unchecked{i++;}
        }
        profiling.end_block();
        fri_params.leaf_size = 1;
        if (!batched_lpc_verifier.parse_verify_proof_be(blob, proof_map.eval_proof_combined_value_offset, tr_state, fri_params)) {
         //   require(false, "Wrong permutation LPC proof");
            return false;
        }
        profiling.end_block();

        // quotient
        // 10. final check
        profiling.start_block("PV::final check");
        local_vars.F = new uint256[](f_parts);
        local_vars.F[0] = local_vars.permutation_argument[0];
        local_vars.F[1] = local_vars.permutation_argument[1];
        local_vars.F[2] = local_vars.permutation_argument[2];
        // lookup argument is not used in unified addition component
        for (uint256 i = 3; i < 8;) {
            local_vars.F[i] = 0;
            unchecked{i++;}
        }
        local_vars.F[8] = local_vars.gate_argument;

        local_vars.F_consolidated = 0;
        for (uint256 i = 0; i < f_parts;) {
            assembly {
                mstore(add(local_vars, F_CONSOLIDATED_OFFSET),
                        addmod(mload(add(local_vars, F_CONSOLIDATED_OFFSET)),
                            mulmod(
                                // alphas[i]
                                mload(add(add(mload(add(local_vars, ALPHAS_OFFSET)), 0x20), mul(0x20, i))),
                                // F[i]
                                mload(add(add(mload(add(local_vars, F_OFFSET)), 0x20), mul(0x20, i))),
                                // modulus
                                mload(fri_params)
                            ),
                            // modulus
                            mload(fri_params)))
            }
            unchecked{ i++; }
        }
        local_vars.T_consolidated = 0;
        local_vars.len = batched_lpc_verifier.get_quotient_z_n_be(blob, proof_map.eval_proof_combined_value_offset);

        for (uint256 i = 0; i < local_vars.len; i++) {
            local_vars.zero_index = batched_lpc_verifier.get_quotient_z_i_j_from_proof_be(blob, proof_map.eval_proof_combined_value_offset, i, 0);
            local_vars.e = field.expmod_static(local_vars.challenge, (fri_params.max_degree + 1) * i, fri_params.modulus);
            //local_vars.zero_index = field.fmul(local_vars.zero_index, local_vars.e, fri_params.modulus);
            //local_vars.T_consolidated  = field.fadd(local_vars.T_consolidated, local_vars.zero_index, fri_params.modulus);
            assembly {
                mstore(
                    // local_vars.zero_index
                    add(local_vars, ZERO_INDEX_OFFSET),
                    // local_vars.zero_index * local_vars.e
                    mulmod(
                        // local_vars.zero_index
                        mload(add(local_vars, ZERO_INDEX_OFFSET)),
                        // local_vars.e
                        mload(add(local_vars, E_OFFSET)),
                        // modulus
                        mload(fri_params)
                    )
                )
                mstore(
                    // local_vars.T_consolidated
                    add(local_vars, T_CONSOLIDATED_OFFSET),
                    // local_vars.T_consolidated + local_vars.zero_index
                    addmod(
                        // local_vars.T_consolidated
                        mload(add(local_vars, T_CONSOLIDATED_OFFSET)),
                        // local_vars.zero_index
                        mload(add(local_vars, ZERO_INDEX_OFFSET)),
                        // modulus
                        mload(fri_params)
                    )
                )
            }
        }
        local_vars.Z_at_challenge = field.expmod_static(local_vars.challenge, common_data.rows_amount, fri_params.modulus);
        //local_vars.Z_at_challenge = field.fsub(local_vars.Z_at_challenge, 1, fri_params.modulus);
        //local_vars.Z_at_challenge = field.fmul(local_vars.Z_at_challenge, local_vars.T_consolidated, fri_params.modulus);
        assembly {
            mstore(
                // local_vars.Z_at_challenge
                add(local_vars, Z_AT_CHALLENGE_OFFSET),
                // local_vars.Z_at_challenge - 1
                addmod(
                    // Z_at_challenge
                    mload(add(local_vars, Z_AT_CHALLENGE_OFFSET)),
                    // -1
                    sub(mload(fri_params), 1),
                    // modulus
                    mload(fri_params)
                )
            )
            mstore(
                // local_vars.Z_at_challenge
                add(local_vars, Z_AT_CHALLENGE_OFFSET),
                // Z_at_challenge * T_consolidated
                mulmod(
                    // Z_at_challenge
                    mload(add(local_vars, Z_AT_CHALLENGE_OFFSET)),
                    // T_consolidated
                    mload(add(local_vars, T_CONSOLIDATED_OFFSET)),
                    // modulus
                    mload(fri_params)
                )
            )
        }
        if (local_vars.F_consolidated != local_vars.Z_at_challenge) {
            require(false, "Final check is not correct");
            return false;
        }
        profiling.end_block();
        profiling.end_block();
        return true;
    }
}