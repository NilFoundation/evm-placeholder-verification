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
        // 0x0
        uint256 modulus;
        // 0x20
        uint256 r;
        // 0x40
        uint256 max_degree;
        // 0x60
        uint256 lambda;
        // 0x80
        uint256 omega;
        // 0xa0
        uint256[] D_omegas;
        // 0xc0
        uint256[] correct_order_idx;       // Ordered indices to pack ys to check merkle proof
        // 0xe0
        uint256[] step_list;
        // 0x100
        uint256[] q;

        // 0x120
        uint256[] s_indices;
        uint256[] s;                    // Coset indices
        uint256 max_step;       // variable for memory  initializing
        uint256 max_batch;      // variable for memory  initializing

        // These are local variables for FRI. But it's useful to allocate memory once
        uint256[]    tmp_arr;
        uint256[][]  evaluation_points;
        uint256      z_offset;

        // New fields
        uint256       max_coset;
        uint256       batches_num;
        uint256[]     batches_sizes;
        uint256       fri_proof_offset;         // fri_roots offset equals to fri_proof_offset + 0x20
        uint256       fri_final_poly_offset;
        uint256       fri_cur_query_offset;     // It'll be changed during verification process.
                                                // It's set at the begining of the first query proof after parse functions running.
        uint256       theta;
        uint256       poly_num;
        uint256[][]   combined_U;                // U polynomials for different evaluation points
        uint256[][]   denominators;              // V polynomials for different evaluation points
        uint256[]     factors;
        uint256[]     eval_map;
        uint256[][]   unique_eval_points;
        uint256       different_points;
        uint256[]     ys;
        uint256[]     final_polynomial;         // It's loaded once while parsing fri proof
        uint256[]     fri_roots;                // It should be bytes32
    }

    struct fri_state_type {
        bytes   b;
        //0x0
        uint256 x_index;
        //0x20
        uint256 x;
        //0x40
        uint256 domain_size;
        //0x60
        uint256 domain_size_mod;
        //0x80
        uint256 newind;
        //0xa0
        uint256 p_ind;
        //0xc0
        uint256 y_ind;
        //0xe0
        uint256 indices_size;
        //0x100
        uint256 b_length;
        //0x120
        uint256 query_id;
        //0x140
        uint256[]     alphas;
        uint256[] values;
        uint256[] tmp_values;
        uint256 coset_size;
        uint256 offset;
        uint256 root;
        uint256 fri_root;
        uint256 s;
        uint256 step;
        uint256 round;
        uint256[] point;
        uint256 cur;
        uint256 interpolant;
        uint256 f0;
        uint256 f1;
        uint256 factor;
    }

    struct placeholder_proof_map {
        // 0x0
        uint256 variable_values_commitment_offset;
        // 0x20
        uint256 v_perm_commitment_offset;
        // 0x40
        uint256 T_commitment_offset;
        // 0x60
        uint256 fixed_values_commitment_offset;
        // 0x80
        uint256 eval_proof_offset;
        // 0xa0
        uint256 eval_proof_lagrange_0_offset;
        // 0xc0
        uint256 eval_proof_combined_value_offset;
    }

    struct placeholder_common_data {
        uint256 rows_amount;
        // 0x20
        uint256 omega;
        int256[][] columns_rotations; 
    }

    struct placeholder_state_type {
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
        uint256[][][] evaluation_points;
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
        uint256[] roots;
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
        // 0x3a0
        uint256 inversed_omega;
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

    // parameters are sent to gate argument
    struct gate_argument_params {
        // 0x0
        uint256 modulus;
        // 0x20
        uint256 theta;
    }
}
