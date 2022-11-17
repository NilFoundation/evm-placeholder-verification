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
import "../basic_marshalling.sol";
import "../cryptography/transcript.sol";
import "../commitments/batched_lpc_verifier.sol";

library permutation_argument {
    uint256 constant ARGUMENT_SIZE = 3;

    uint256 constant WITNESS_COMMITMENT_OFFSET_OFFSET = 0x0;
    uint256 constant V_PERM_COMMITMENT_OFFSET_OFFSET = 0x20;
    uint256 constant INPUT_PERM_COMMITMENT_OFFSET_OFFSET = 0x40;
    uint256 constant VALUE_PERM_COMMITMENT_OFFSET_OFFSET = 0x60;
    uint256 constant V_L_PERM_COMMITMENT_OFFSET_OFFSET = 0x80;
    uint256 constant T_COMMITMENTS_OFFSET_OFFSET = 0xa0;
    uint256 constant EVAL_PROOF_OFFSET_OFFSET = 0xc0;
    uint256 constant EVAL_PROOF_LAGRANGE_0_OFFSET_OFFSET = 0xe0;
    uint256 constant EVAL_PROOF_WITNESS_OFFSET_OFFSET = 0x100;
    uint256 constant EVAL_PROOF_PERMUTATION_OFFSET_OFFSET = 0x120;
    uint256 constant EVAL_PROOF_QUOTIENT_OFFSET_OFFSET = 0x140;
    uint256 constant EVAL_PROOF_LOOKUPS_OFFSET_OFFSET = 0x160;
    uint256 constant EVAL_PROOF_ID_PERMUTATION_OFFSET_OFFSET = 0x180;
    uint256 constant EVAL_PROOF_SIGMA_PERMUTATION_OFFSET_OFFSET = 0x1a0;
    uint256 constant EVAL_PROOF_PUBLIC_INPUT_OFFSET_OFFSET = 0x1c0;
    uint256 constant EVAL_PROOF_CONSTANT_OFFSET_OFFSET = 0x1e0;
    uint256 constant EVAL_PROOF_SELECTOR_OFFSET_OFFSET = 0x200;
    uint256 constant EVAL_PROOF_SPECIAL_SELECTORS_OFFSET_OFFSET = 0x220;

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
    uint256 constant TMP1_OFFSET = 0x300;
    uint256 constant TMP2_OFFSET = 0x320;
    uint256 constant TMP3_OFFSET = 0x340;
    uint256 constant IDX1_OFFSET = 0x360;
    uint256 constant IDX2_OFFSET = 0x380;
    uint256 constant STATUS_OFFSET = 0x3a0;

    function eval_permutations_at_challenge(
        types.fri_params_type memory fri_params,
        types.placeholder_local_variables memory local_vars,
        uint256 column_polynomials_values_i
    ) internal pure {
        assembly {
            let modulus := mload(fri_params)
            mstore(
                add(local_vars, G_OFFSET),
                mulmod(
                    mload(add(local_vars, G_OFFSET)),
                    // column_polynomials_values[i] + beta * S_id[i].evaluate(challenge) + gamma
                    addmod(
                        // column_polynomials_values[i]
                        column_polynomials_values_i,
                        // beta * S_id[i].evaluate(challenge) + gamma
                        addmod(
                            // beta * S_id[i].evaluate(challenge)
                            mulmod(
                                // beta
                                mload(add(local_vars, BETA_OFFSET)),
                                // S_id[i].evaluate(challenge)
                                mload(add(local_vars, S_ID_I_OFFSET)),
                                modulus
                            ),
                            // gamma
                            mload(add(local_vars, GAMMA_OFFSET)),
                            modulus
                        ),
                        modulus
                    ),
                    modulus
                )
            )
            mstore(
                add(local_vars, H_OFFSET),
                mulmod(
                    mload(add(local_vars, H_OFFSET)),
                    // column_polynomials_values[i] + beta * S_sigma[i].evaluate(challenge) + gamma
                    addmod(
                        // column_polynomials_values[i]
                        column_polynomials_values_i,
                        // beta * S_sigma[i].evaluate(challenge) + gamma
                        addmod(
                            // beta * S_sigma[i].evaluate(challenge)
                            mulmod(
                                // beta
                                mload(add(local_vars, BETA_OFFSET)),
                                // S_sigma[i].evaluate(challenge)
                                mload(add(local_vars, S_SIGMA_I_OFFSET)),
                                modulus
                            ),
                            // gamma
                            mload(add(local_vars, GAMMA_OFFSET)),
                            modulus
                        ),
                        modulus
                    ),
                    modulus
                )
            )
        }
    }

    function verify_eval_be(
        bytes calldata blob,
        types.transcript_data memory tr_state,
        types.placeholder_proof_map memory proof_map,
        types.fri_params_type memory fri_params,
        types.placeholder_common_data memory common_data,
        types.placeholder_local_variables memory local_vars,
        types.arithmetization_params memory ar_params
    ) internal pure returns (uint256[] memory F) {
        local_vars.beta = transcript.get_field_challenge(
            tr_state,
            fri_params.modulus
        );
        local_vars.gamma = transcript.get_field_challenge(
            tr_state,
            fri_params.modulus
        );

        transcript.update_transcript_b32_by_offset_calldata(
            tr_state,
            blob,
            proof_map.v_perm_commitment_offset + basic_marshalling.LENGTH_OCTETS
        );

        // splash
        local_vars.len = ar_params.permutation_columns;
/*        require(
            local_vars.len ==
                batched_lpc_verifier.get_z_n_be(
                    blob,
                    proof_map.eval_proof_sigma_permutation_offset
                ),
            "id_permutation length is not equal to sigma_permutation length!"
        );*/

        require(
            batched_lpc_verifier.get_z_n_be(blob, proof_map.eval_proof_fixed_values_offset) == ar_params.permutation_columns + ar_params.permutation_columns + ar_params.constant_columns + ar_params.selector_columns + 2,
            "Something wrong with number of fixed values polys"
        );
        //local_vars.tmp1 = batched_lpc_verifier.get_z_n_be(blob, proof_map.eval_proof_witness_offset);
        local_vars.tmp1 = ar_params.witness_columns;
        // local_vars.tmp2 = batched_lpc_verifier.get_z_n_be(blob, proof_map.eval_proof_public_input_offset );
        local_vars.tmp2 = ar_params.public_input_columns;
        //local_vars.tmp3 = batched_lpc_verifier.get_z_n_be(blob, proof_map.eval_proof_constant_offset );
        local_vars.tmp3 = ar_params.constant_columns;


        local_vars.g = 1;
        local_vars.h = 1;
        for (
            local_vars.idx1 = 0;
            local_vars.idx1 < local_vars.len;
            local_vars.idx1++
        ) {
            for (
                local_vars.idx2 = 0;
                local_vars.idx2 < common_data.columns_rotations[local_vars.idx1].length;
                local_vars.idx2++
            ) {
                if (common_data.columns_rotations[local_vars.idx1][local_vars.idx2] == 0 ) {
                    local_vars.zero_index = local_vars.idx2;
                }
            }
            
            //local_vars.S_id_i = batched_lpc_verifier.get_z_i_j_from_proof_be(
            //    blob,
            //    proof_map.eval_proof_id_permutation_offset,
            //    local_vars.idx1,
            //    0
            //);
            // id_perm_polys
            local_vars.S_id_i = batched_lpc_verifier.get_z_i_j_from_proof_be(
                blob,
                proof_map.eval_proof_fixed_values_offset,
                local_vars.idx1,
                0
            );

            //local_vars.S_sigma_i = batched_lpc_verifier.get_z_i_j_from_proof_be(
            //    blob,
            //    proof_map.eval_proof_sigma_permutation_offset,
            //    local_vars.idx1,
            //    0
            //);
            local_vars.S_sigma_i = batched_lpc_verifier.get_z_i_j_from_proof_be(
                blob,
                proof_map.eval_proof_fixed_values_offset,
                local_vars.idx1 + ar_params.permutation_columns,
                0
            );

            if (local_vars.idx1 < local_vars.tmp1) {
                eval_permutations_at_challenge(
                    fri_params,
                    local_vars,
                    batched_lpc_verifier.get_z_i_j_from_proof_be(
                        blob,
                        proof_map.eval_proof_variable_values_offset, // witnesses
                        local_vars.idx1,
                        local_vars.zero_index
                    )
                );
            } else if (local_vars.idx1 < local_vars.tmp1 + local_vars.tmp2) {
                eval_permutations_at_challenge(
                    fri_params,
                    local_vars,
                    batched_lpc_verifier.get_z_i_j_from_proof_be(
                        blob,
                        proof_map.eval_proof_variable_values_offset, // public_input
                        local_vars.idx1,
                        local_vars.zero_index
                    )
                );
            } else if ( local_vars.idx1 <  local_vars.tmp1 + local_vars.tmp2 + local_vars.tmp3 ) {
                eval_permutations_at_challenge(
                    fri_params,
                    local_vars,
                    batched_lpc_verifier.get_z_i_j_from_proof_be(
                        blob,
                        proof_map.eval_proof_fixed_values_offset, // constant
                        local_vars.idx1 - local_vars.tmp1 - local_vars.tmp2 + ar_params.permutation_columns + ar_params.permutation_columns,
                        local_vars.zero_index
                    )
                );
            }
        }

        local_vars.perm_polynomial_value = batched_lpc_verifier.get_z_i_j_from_proof_be(
            blob, proof_map.eval_proof_permutation_offset, 0, 0
        );
        local_vars.perm_polynomial_shifted_value = batched_lpc_verifier.get_z_i_j_from_proof_be(
            blob, proof_map.eval_proof_permutation_offset, 0, 1
        );

        local_vars.q_last_eval = batched_lpc_verifier.get_z_i_j_from_proof_be(
            blob, 
            proof_map.eval_proof_fixed_values_offset,       // special selector 0
            ar_params.permutation_columns + ar_params.permutation_columns + ar_params.constant_columns + ar_params.selector_columns,
            0
        );
        local_vars.q_blind_eval = batched_lpc_verifier.get_z_i_j_from_proof_be(
            blob, 
            proof_map.eval_proof_fixed_values_offset,       // special selector 1
            ar_params.permutation_columns + ar_params.permutation_columns + ar_params.constant_columns + ar_params.selector_columns + 1,
            0
        );
        F = new uint256[](ARGUMENT_SIZE);
        local_vars.challenge = basic_marshalling.get_uint256_be(
            blob,
            proof_map.eval_proof_offset
        );
        assembly {
            let modulus := mload(fri_params)

            // F[0]
            mstore(
                add(F, 0x20),
                mulmod(
                    calldataload(
                        add(
                            blob.offset,
                            mload(
                                add(
                                    proof_map,
                                    EVAL_PROOF_LAGRANGE_0_OFFSET_OFFSET
                                )
                            )
                        )
                    ),
                    addmod(
                        1,
                        // one - perm_polynomial_value
                        sub(
                            modulus,
                            mload(add(local_vars, PERM_POLYNOMIAL_VALUE_OFFSET))
                        ),
                        modulus
                    ),
                    modulus
                )
            )

            // F[1]
            mstore(
                add(F, 0x40),
                // (one - preprocessed_data.q_last.evaluate(challenge) -
                //  preprocessed_data.q_blind.evaluate(challenge)) *
                //  (perm_polynomial_shifted_value * h - perm_polynomial_value * g)
                mulmod(
                    // one - preprocessed_data.q_last.evaluate(challenge) -
                    //  preprocessed_data.q_blind.evaluate(challenge)
                    addmod(
                        1,
                        // -preprocessed_data.q_last.evaluate(challenge) - preprocessed_data.q_blind.evaluate(challenge)
                        addmod(
                            // -preprocessed_data.q_last.evaluate(challenge)
                            sub(
                                modulus,
                                mload(add(local_vars, Q_LAST_EVAL_OFFSET))
                            ),
                            // -preprocessed_data.q_blind.evaluate(challenge)
                            sub(
                                modulus,
                                mload(add(local_vars, Q_BLIND_EVAL_OFFSET))
                            ),
                            modulus
                        ),
                        modulus
                    ),
                    // perm_polynomial_shifted_value * h - perm_polynomial_value * g
                    addmod(
                        // perm_polynomial_shifted_value * h
                        mulmod(
                            // perm_polynomial_shifted_value
                            mload(
                                add(
                                    local_vars,
                                    PERM_POLYNOMIAL_SHIFTED_VALUE_OFFSET
                                )
                            ),
                            // h
                            mload(add(local_vars, H_OFFSET)),
                            modulus
                        ),
                        // - perm_polynomial_value * g
                        sub(
                            modulus,
                            mulmod(
                                // perm_polynomial_value
                                mload(
                                    add(
                                        local_vars,
                                        PERM_POLYNOMIAL_VALUE_OFFSET
                                    )
                                ),
                                // g
                                mload(add(local_vars, G_OFFSET)),
                                modulus
                            )
                        ),
                        modulus
                    ),
                    modulus
                )
            )

            // F[2]
            mstore(
                add(F, 0x60),
                // preprocessed_data.q_last.evaluate(challenge) *
                //  (perm_polynomial_value.squared() - perm_polynomial_value)
                mulmod(
                    // preprocessed_data.q_last.evaluate(challenge)
                    mload(add(local_vars, Q_LAST_EVAL_OFFSET)),
                    // perm_polynomial_value.squared() - perm_polynomial_value
                    addmod(
                        // perm_polynomial_value.squared()
                        mulmod(
                            // perm_polynomial_value
                            mload(
                                add(local_vars, PERM_POLYNOMIAL_VALUE_OFFSET)
                            ),
                            // perm_polynomial_value
                            mload(
                                add(local_vars, PERM_POLYNOMIAL_VALUE_OFFSET)
                            ),
                            modulus
                        ),
                        // -perm_polynomial_value
                        sub(
                            modulus,
                            mload(add(local_vars, PERM_POLYNOMIAL_VALUE_OFFSET))
                        ),
                        modulus
                    ),
                    modulus
                )
            )
        }
    }
}
