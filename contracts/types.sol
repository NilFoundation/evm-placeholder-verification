// SPDX-License-Identifier: MIT OR Apache-2.0
//---------------------------------------------------------------------------//
// Copyright (c) 2018-2021 Mikhail Komarov <nemo@nil.foundation>
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

/**
 * @title Bn254Crypto library used for the fr, g1 and g2 point types
 * @dev Used to manipulate fr, g1, g2 types, perform modular arithmetic on them and call
 * the precompiles add, scalar mul and pairing
 *
 * Notes on optimisations
 * 1) Perform addmod, mulmod etc. in assembly - removes the check that Solidity performs to confirm that
 * the supplied modulus is not 0. This is safe as the modulus's used (r_mod, q_mod) are hard coded
 * inside the contract and not supplied by the user
 */
library types {
    uint256 constant PROGRAM_WIDTH = 4;
    uint256 constant NUM_NU_CHALLENGES = 11;

    uint256 constant coset_generator0 = 0x0000000000000000000000000000000000000000000000000000000000000005;
    uint256 constant coset_generator1 = 0x0000000000000000000000000000000000000000000000000000000000000006;
    uint256 constant coset_generator2 = 0x0000000000000000000000000000000000000000000000000000000000000007;

    // TODO: add external_coset_generator() method to compute this
    uint256 constant coset_generator7 = 0x000000000000000000000000000000000000000000000000000000000000000c;

    struct g1_point {
        uint256 x;
        uint256 y;
    }

    // G2 group element where x \in Fq2 = x0 * z + x1
    struct g2_point {
        uint256 x0;
        uint256 x1;
        uint256 y0;
        uint256 y1;
    }

    // N>B. Do not re-order these fields! They must appear in the same order as they
    // appear in the proof data
    struct proof {
        g1_point W1;
        g1_point W2;
        g1_point W3;
        g1_point W4;
        g1_point Z;
        g1_point T1;
        g1_point T2;
        g1_point T3;
        g1_point T4;
        uint256 w1;
        uint256 w2;
        uint256 w3;
        uint256 w4;
        uint256 sigma1;
        uint256 sigma2;
        uint256 sigma3;
        uint256 q_arith;
        uint256 q_ecc;
        uint256 q_c;
        uint256 linearization_polynomial;
        uint256 grand_product_at_z_omega;
        uint256 w1_omega;
        uint256 w2_omega;
        uint256 w3_omega;
        uint256 w4_omega;
        g1_point PI_Z;
        g1_point PI_Z_OMEGA;
        g1_point recursive_P1;
        g1_point recursive_P2;
        uint256 quotient_polynomial_eval;
    }

    struct challenge_transcript {
        uint256 alpha_base;
        uint256 alpha;
        uint256 zeta;
        uint256 beta;
        uint256 gamma;
        uint256 u;
        uint256 v0;
        uint256 v1;
        uint256 v2;
        uint256 v3;
        uint256 v4;
        uint256 v5;
        uint256 v6;
        uint256 v7;
        uint256 v8;
        uint256 v9;
        uint256 v10;
    }

    struct verification_key {
        uint256 circuit_size;
        uint256 num_inputs;
        uint256 work_root;
        uint256 domain_inverse;
        uint256 work_root_inverse;
        g1_point Q1;
        g1_point Q2;
        g1_point Q3;
        g1_point Q4;
        g1_point Q5;
        g1_point QM;
        g1_point QC;
        g1_point QARITH;
        g1_point QECC;
        g1_point QRANGE;
        g1_point QLOGIC;
        g1_point SIGMA1;
        g1_point SIGMA2;
        g1_point SIGMA3;
        g1_point SIGMA4;
        bool contains_recursive_proof;
        uint256 recursive_proof_indices;
        g2_point g2_x;

        // zeta challenge raised to the power of the circuit size.
        // Not actually part of the verification key, but we put it here to prevent stack depth errors
        uint256 zeta_pow_n;
    }
    
    struct transcript_data {
        bytes32 current_challenge;
    }

    struct fri_params_type {
        //0x00
        uint256 modulus;
        //0x20
        uint256 r;
        //0x40
        uint256 max_degree;
        //0x60
        uint256 lambda;
        //0x80
        uint256 leaf_size;

        //0xa0
        uint256[] D_omegas;
        //0xc0
        uint256[] q;

        //0xe0
        uint256[]    s_indices;
        //0x100
        uint256[]    correct_order_idx;       // Ordered indices to pack ys to check merkle proofs
        //0x120
        uint256[][] batched_U;
        //0x140
        uint256[][] batched_V;

        //0x160
        bytes batched_fri_verified_data;
        //0x180
        uint256[] lpc_z;
        //0x1a0
        uint256 batched_U_len;

        //0x1c0
        uint256[] step_list;
        //0x1e0
        uint256[]    s;                    // Coset indices
        //0x200
        uint256 i_fri_proof;    // It is useful for debugging
        //0x220
        uint256 max_step;       // variable for memory  initializing
        //0x240
        uint256 max_batch;      // variable for memory  initializing

        // These are local variables for FRI. But it's useful to allocate memory once
        //0x260
        bytes        b;
        //0x280
        uint256[]    coeffs;                  // coeffs -- ancestor of ys
        uint256[]    tmp_arr;
        uint256[][]  evaluation_points;
        uint256      z_offset;
        uint256      prev_xi;
        uint256[]    precomputed_eval1;
        uint256[][]   precomputed_eval3_points;
        uint256[9][]  precomputed_eval3_data;
        uint256[]     precomputed_indices;
    }

    struct fri_local_vars_type {
        // some internal variables used in assemblys
        // 0x0
        uint256     s1;                                     // It's extremely important, it's the first field.
        //0x20
        uint256     x;                                      // challenge x value
        //0x40
        uint256     alpha;                                   // alpha challenge
        //0x60
        uint256     coeffs_offset;                           // address of current coeffs array(fri_params.coeffs)
        //0x80 
        uint256     y_offset;                                // address of current y (offset in blob)
        //0xa0     
        uint256     colinear_offset;                         // colinear_value_offset. Used only in colinear check
        //0xc0     
        uint256     c1;                                      // fs1 coefficient.
        //0xe0     
        uint256     c2;                                      // fs2 coefficient.
        //0x100
        uint256     interpolant;                             // interpolant
        //0x120
        uint256     prev_coeffs_len;

        // Fri proof fields
        uint256 final_poly_offset;                           // one for all rounds
        uint256 values_offset;                               // one for all rounds

        // Fri round proof fields (for step)
        uint256 round_proof_offset;                      // current round proof offset. It's round_proof.p offset too.
        uint256 round_proof_T_root_offset;               // prepared for transcript.
        uint256 round_proof_colinear_path_offset;        // current round proof colinear_path offset.
        uint256 round_proof_colinear_path_T_root_offset; // current round proof colinear_path offset.
        uint256 round_proof_values_offset;               // offset item in fri_proof.values structure for current round proof
        uint256 round_proof_colinear_value;              // It is the value. Not offset
        uint256 i_step;                                  // current step
        uint256 r_step;                                  // rounds in step                                     
        uint256 b_length;                                // length of bytes for merkle verifier input

        // Fri params for one round (in step)
        uint256 x_index;
        uint256 domain_size;                             // domain size
        uint256 domain_size_mod;
        uint256 omega;                                   // domain generator
        uint256 global_round_index;                      // current FRI round
        uint256 i_round;                                 // current round in step

        // Some internal variables
        uint256 p_ind;          // ??
        uint256 y_ind;                   // ?
        uint256 p_offset;
        uint256 polynomial_vector_size;
        uint256 y_size;
        uint256 colinear_path_offset;
        // Variables for colinear check. Sorry! There are a so many of them.
        uint256 indices_size;
        uint256 ind;
        uint256 newind;
        uint256 mul;
        // Useful previous round values.
        // uint256 prev_p_offset;
        uint256 prev_polynomial_vector_size;
        uint256 prev_step;
        uint256 coeffs_len;
    }

    struct placeholder_proof_map {
        // 0x0
        uint256 variable_values_commitment_offset;
        // 0x20
        uint256 v_perm_commitment_offset;
        // 0x40
        uint256 input_perm_commitment_offset;
        // 0x60
        uint256 value_perm_commitment_offset;
        // 0x80
        uint256 v_l_perm_commitment_offset;
        // 0xa0
        uint256 T_commitments_offset;
        // 0xc0
        uint256 eval_proof_offset;
        // 0xe0
        uint256 eval_proof_lagrange_0_offset;
        // 0x100
        uint256 eval_proof_fixed_values_offset;
        // 0x120
        uint256 eval_proof_variable_values_offset;
        // 0x140
        uint256 eval_proof_permutation_offset;
        // 0x160
        uint256 eval_proof_quotient_offset;
        // 0x180
        uint256 eval_proof_lookups_offset;
    }

    struct placeholder_common_data {
        uint256 rows_amount;
        // 0x20
        uint256 omega;
        int256[][] columns_rotations; 
    }

    struct placeholder_local_variables{
        // 0x0
        uint256 len;
        // 0x20
        uint256 offset;
        // 0x40
        uint256 zero_index;
        // 0x60
        uint256[] permutation_argument;
        // 0x80
        uint256 gate_argument;
        // 0xa0
        uint256[] alphas;
        // 0xc0
        uint256 challenge;
        // 0xe0
        uint256 e;
        // 0x100
        uint256[][] evaluation_points;
        // 0x120
        uint256[] F;
        // 0x140
        uint256 F_consolidated;
        // 0x160
        uint256 T_consolidated;
        // 0x180
        uint256 Z_at_challenge;
        // 0x1a0
        uint256 beta;
        // 0x1c0
        uint256 gamma;
        // 0x1e0
        uint256 g;
        // 0x200
        uint256 h;
        // 0x220
        uint256 perm_polynomial_value;
        // 0x240
        uint256 perm_polynomial_shifted_value;
        // 0x260
        uint256 q_blind_eval;
        // 0x280
        uint256 q_last_eval;
        // 0x2a0
        uint256 S_id_i;
        // 0x2c0
        uint256 S_sigma_i;
        // 0x2e0
        uint256[][] variable_values_evaluation_points;
        // 0x300
        uint256 tmp1;
        // 0x320
        uint256 tmp2;
        // 0x340
        uint256 tmp3;
        // 0x360
        uint256 idx1;
        // 0x380
        uint256 idx2;
    }

    struct arithmetization_params{
        uint256 witness_columns;
        uint256 public_input_columns;
        uint256 constant_columns;
        uint256 selector_columns;
        uint256 lookup_table_size;

        // computed from other params
        uint256 permutation_columns;
    }

    struct gate_argument_local_vars {
        // 0x0
        uint256 modulus;
        // 0x20
        uint256 theta;
        // 0x40
        uint256 constraint_eval;
        // 0x60
        uint256 gate_eval;
        // 0x80
        uint256[] witness_evaluations_offsets;
        // 0xa0
        uint256[] selector_evaluations;
        // 0xe0
        uint256 eval_proof_witness_offset;
        // 0xc0
        uint256 eval_proof_selector_offset;
        // 0x100
        uint256 gates_evaluation;
        // 0x120
        uint256 theta_acc;
        // 0x140
        uint256 selector_evaluations_offset;
        // 0x160
        uint256 offset;
        // 0x180
        uint256[][] witness_evaluations;
        // 0x1a0
        uint256[][] constant_evaluations;
        // 0x1c0
        uint256[][] public_input_evaluations;
        // 0x1e0
        uint256 eval_proof_constant_offset;
    }

    struct gate_argument_local_vars_updated{
        // 0x0
        uint256 modulus;
        // 0x20
        uint256 theta;
        // 0x40
        uint256 constraint_eval;
        // 0x60
        uint256 gate_eval;
        // 0x80
        uint256[] witness_evaluations_offsets;
        // 0xa0
        uint256[] selector_evaluations;
        // 0xc0
        uint256 eval_proof_witness_offset;
        // 0xe0
        uint256 eval_proof_selector_offset;
        // 0x100
        uint256 gates_evaluation;
        // 0x120
        uint256 theta_acc;
        // 0x140
        uint256 selector_evaluations_offset;
        // 0x160
        uint256 offset;
        // 0x180
        uint256[][] witness_evaluations;
        // 0x1a0
        uint256[][] constant_evaluations;
        // 0x1c0
        uint256[][] public_input_evaluations;
        // 0x1e0
        uint256 eval_proof_constant_offset;
    }
}
