// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2021 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2021 Ilias Khairullin <ilias@nil.foundation>
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
import "../containers/merkle_verifier.sol";
import "../cryptography/transcript.sol";
//import "../algebra/field.sol";
import "../algebra/polynomial.sol";
import "../basic_marshalling.sol";
import "../logging.sol";

library batched_fri_verifier {
    struct local_vars_type {
        // some internal variables used in assemblys
        // 0x0
        bytes       b;
        //0x20
        uint256     s1;                                      
        //0x40
        uint256     alpha;                                   // alpha challenge
        //0x60
        uint256     fs1;
        //0x80 
        uint256     fs2;
        //0x100     
        uint256     c;                                      // colinear_value_offset

        // Fri proof fields
        uint256 final_poly_offset;                      // one for all rounds
        uint256 values_offset;

        // Fri round proof fields (for step)
        uint256 round_proof_offset;                      // current round proof offset. It's round_proof.p offset too.
        uint256 round_proof_T_root_offset;               // prepared for transcript.
        uint256 round_proof_colinear_path_offset;        // current round proof colinear_path offset.
        uint256 round_proof_colinear_path_T_root_offset; // current round proof colinear_path offset.
        uint256 round_proof_values_offset;               // offset item in fri_proof.values structure for current round proof
        uint256 round_proof_colinear_value;              // It is the value. Not offset
        uint256 i_step;                                  // current step
        uint256 r_step;                                  // rounds in step                                     

        // Fri params for one round (in step)
        uint256 x_index;
        uint256 x;
        uint256 x_next;
        uint256 domain_size;                             // domain size
        uint256 omega;                                   // domain generator
        uint256 global_round_index;                      // current FRI round
        uint256 i_round;                                 // current round in step

        // Some internal variables
        uint256 p_ind;          // ??
        uint256 y_ind;                   // ??
        uint256 polynom_index;              // ??
        uint256 p_offset;
        uint256 y_offset;
        uint256[][] s_indices;              // ??
        uint256[][] s;                      // ??
        uint256[][] correct_order_idx;      // ??
        uint256[][][] ys;                   // ??
        uint256[][][] ys_next;                   // ??
        uint256[][][] ys_previous;
        // Variables for colinear check. Sorry! There are a so many of them.
        uint256 cc_s1;
        uint256 cc_s2;
        uint256[] cc_fs1;
        uint256[] cc_fs2;
        uint256 cc_value;
        bool cc_one_round_step;
    }

    uint256 constant BYTES_B_OFFSET = 0x0;
    uint256 constant S1_OFFSET = 0x20;                                      
    uint256 constant ALPHA_OFFSET = 0x40;                                   // alpha challenge
    uint256 constant FS1_OFFSET = 0x60;
    uint256 constant FS2_OFFSET = 0x80;
    uint256 constant C_OFFSET = 0x100;                                      // colinear_value_offset

    uint256 constant COLINEAR_VALUE_OFFSET = 0x0;
    uint256 constant T_ROOT_OFFSET_OFFSET = 0x20;
    uint256 constant FINAL_POLY_OFFSET_OFFSET = 0x40;
    uint256 constant X_OFFSET = 0x60;
    uint256 constant X_NEXT_OFFSET = 0x80;
    uint256 constant ROUND_PROOF_OFFSET_OFFSET = 0xc0;
    uint256 constant ROUND_PROOF_Y_OFFSET_OFFSET = 0xe0;
    uint256 constant ROUND_PROOF_P_OFFSET_OFFSET = 0x100;
    uint256 constant Y_POLYNOM_INDEX_J_OFFSET = 0x120;
    uint256 constant Y_J_OFFSET_OFFSET = 0x140;
    uint256 constant Y_J_SIZE_OFFSET = 0x160;
    uint256 constant STATUS_OFFSET = 0x180;
    uint256 constant VALUES_OFFSET = 0x240;

//    uint256 constant BATCHED_FRI_VERIFIED_DATA_OFFSET = 0x160;
//    uint256 constant VERIFIED_DATA_OFFSET = 0x300;
    uint256 constant CONSTANT_1_2_OFFSET = 0x1e0;

    uint256 constant m = 2;

    // Offset is set at the begining of round proof.
    // Returns offset of the first byte after round proof/
    function skip_round_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // p
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be(result_offset);
        // colinear_path
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, result_offset);
    }

    function skip_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // round_proofs
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        for (uint256 i = 0; i < value_len;) {
            result_offset = skip_round_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
        // values
        result_offset = basic_marshalling.skip_v_of_vectors_of_vectors_of_uint256_be(blob, result_offset);
        // final_polynomial
        result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, result_offset);
    }

    function skip_to_first_round_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // number of round proofs
        result_offset = basic_marshalling.skip_length(offset);
    }

    // Input offset is the beginning of FRI proof
    // Returns offset of the begining of vector of vectors of vectors of values
    function skip_to_values_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // number of round proofs
        // round_proofs
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length_check(blob, offset);
        for (uint256 i = 0; i < value_len;) {
            result_offset = skip_round_proof_be_check(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_to_round_proof_colinear_path(bytes calldata blob, uint256 offset)
    internal pure returns( uint256 result_offset ){
        // round_proof.p
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // round_proof.T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be(result_offset);
    }    

    //use this function only for preparing data for transcript
    function skip_to_round_proof_T_root_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // p
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // T_root length
        result_offset = basic_marshalling.skip_length(result_offset);
    }

    //use this function only for preparing data for transcript
    function skip_to_round_proof_colinear_path_T_root_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // p
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // T_root length
        result_offset = basic_marshalling.skip_octet_vector_32_be(result_offset);
        // merkle proof internal lengths
        result_offset = basic_marshalling.skip_length(result_offset);
        result_offset = basic_marshalling.skip_length(result_offset);
    }

    function skip_round_proof_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // p
        result_offset = merkle_verifier.skip_merkle_proof_be_check(blob, offset);
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, result_offset);
        // colinear_path
        result_offset = merkle_verifier.skip_merkle_proof_be_check(blob, result_offset);
    }

    function skip_proof_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // round_proofs
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length_check(blob, offset);
        for (uint256 i = 0; i < value_len;) {
            result_offset = skip_round_proof_be_check(blob, result_offset);
            unchecked{ i++; }
        }

        // values
        result_offset = basic_marshalling.skip_v_of_vectors_of_vectors_of_uint256_be(blob, result_offset);
        // final_polynomial
        result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be_check(blob, result_offset);
    }

    // Get number of round proofs in FRI-proof. 
    // Offset is set at the begining of FRI-proof.
    function get_round_proofs_n_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 n){
        // round_proofs
        n = basic_marshalling.get_length(blob, offset);
    }

    // offset is offest to current step values offset
    // return y_ij
    function get_y_i_j(bytes calldata blob, uint256 offset, uint256 i, uint256 j)
    internal pure returns (uint256 y_ij){
        // round_proofs
        y_ij = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(blob, offset, i, j);
    }

    function y_to_y0_for_first_step(uint256 x, uint256 y, uint256[] memory batched_U, uint256[] memory batched_V, uint256 modulus)
    internal view returns(uint256 result){
        uint256 U_evaluated_neg;
        uint256 V_evaluated_inv;
        U_evaluated_neg = modulus - polynomial.evaluate(
            batched_U,
            x,
            modulus
        );
        V_evaluated_inv = field.inverse_static(
            polynomial.evaluate(
                batched_V,
                x,
                modulus
            ),
            modulus
        );
        assembly{
            result := mulmod(addmod(y, U_evaluated_neg, modulus), V_evaluated_inv, modulus)
        }
    }

    // if x_index is index of x, then paired_index is index of -x
    function get_paired_index(uint256 x_index, uint256 domain_size)
    internal view returns(uint256 result ){
        result = (x_index + domain_size / 2) % domain_size;
    }

    // calculate indices for coset S = {s\in D| s^(2^fri_step) == x_next}
    function calculate_s_indices(local_vars_type memory local_vars)
    internal view
    {
        uint256 coset_size = 1 << local_vars.r_step;

        local_vars.s_indices = new uint256[][](coset_size >> 1);
        for( uint256 ind = 0; ind < local_vars.s_indices.length; ind++){
            local_vars.s_indices[ind] = new uint256[](2);
            local_vars.s_indices[ind][0] = 10;
            local_vars.s_indices[ind][1] = 11;
            //require(fri_step != 4 || ind != 1, logging.uint2decstr(local_vars.s_indices[1][1]));
        }
        //require(fri_step != 4, logging.uint2decstr(s_inds[1][0]));
        local_vars.s_indices[0][0] = local_vars.x_index;
        local_vars.s_indices[0][1] = get_paired_index(local_vars.x_index, local_vars.domain_size);

        uint256 base_index = local_vars.domain_size >> 2;
        uint256 prev_half_size = 1;
        uint256 i = 1;
        while( i < (coset_size >> 1) ){
            for( uint256 j = 0; j < prev_half_size; j++){
                local_vars.s_indices[i][0] = (base_index + local_vars.s_indices[j][0]) %local_vars.domain_size;
                local_vars.s_indices[i][1] = get_paired_index(local_vars.s_indices[i][0], local_vars.domain_size);
                i++;
            }
            base_index >>=1;
            prev_half_size <<=1;
        }
    }

    function calculate_s(types.fri_params_type memory fri_params, local_vars_type memory local_vars)
    internal view  {
        local_vars.s = new uint256[][](local_vars.s_indices.length);
        for( uint256 i = 0; i < local_vars.s_indices.length; i++ ){
            local_vars.s[i] = new uint256[](2);
            local_vars.s[i][0] = field.expmod_static(local_vars.omega, local_vars.s_indices[i][0], fri_params.modulus);
            local_vars.s[i][1] = field.expmod_static(local_vars.omega, local_vars.s_indices[i][1], fri_params.modulus);
        }
    }

    function get_folded_index(uint256 x_index, uint256 fri_step, uint256 domain_size) 
    internal view returns(uint256 result){
        result = x_index;
        for (uint256 i = 0; i < fri_step; i++) {
            domain_size >>= 1;
            result %= domain_size;
        }
    }

    function calculate_correct_order_idx(local_vars_type memory local_vars)
    internal view 
    {
        uint256 coset_size = (1 << local_vars.r_step);
        require((coset_size >> 1) == local_vars.s_indices.length, "Invalid s_indices.length");
        uint256[] memory correctly_ordered_s_indices = new uint256[](coset_size >> 1);
        correctly_ordered_s_indices[0] = get_folded_index(local_vars.x_index, local_vars.r_step, local_vars.domain_size);

        uint256 base_index = local_vars.domain_size >> 2;
        uint256 prev_half_size = 1;
        uint256 i = 1;
        uint256 j = 0;
        while (i < coset_size >> 1 ){
            for (j = 0; j < prev_half_size; j++) {
                correctly_ordered_s_indices[i] =
                    (base_index + correctly_ordered_s_indices[j]) % local_vars.domain_size;
                i++;
            }
            base_index >>= 1;
            prev_half_size <<= 1;
        }

        local_vars.correct_order_idx = new uint256[][](local_vars.s_indices.length);
        for ( i = 0; i < coset_size >> 1; i++) {
            bool found = false;
            uint256 found_ind;
            local_vars.correct_order_idx[i] = new uint256[](2);

            for(j = 0; j < local_vars.s_indices.length; j++){
                if(local_vars.s_indices[j][0] == correctly_ordered_s_indices[i] && local_vars.s_indices[j][1] == get_paired_index(correctly_ordered_s_indices[i], local_vars.domain_size)){
                    found = true;
                    found_ind = j;
                    local_vars.correct_order_idx[i][1] = 0; 
                    break;
                }
                if(local_vars.s_indices[j][1] == correctly_ordered_s_indices[i] && local_vars.s_indices[j][0] == get_paired_index(correctly_ordered_s_indices[i], local_vars.domain_size)){
                    found = true;
                    found_ind = j;
                    local_vars.correct_order_idx[i][1] = 1; 
                    break;
                }
            }
            //require(found, "Invalid indices");
            local_vars.correct_order_idx[i][0] = found_ind;
        }
    }

    // Reorder data from values. 
    // local_vars: values_offset, fri_step, domain_size, i_step, y_j_offset,
    function prepare_leaf_data_and_ys(
        bytes calldata blob, 
        types.fri_params_type memory fri_params,
        local_vars_type memory local_vars )
    internal  view
    {
        // Check length parameters correctness
        uint256 size = basic_marshalling.get_length(blob, local_vars.round_proof_values_offset);
        //require(size == fri_params.leaf_size, "Invalid polynomial number in proof.values");

        calculate_s_indices(local_vars);
        calculate_correct_order_idx(local_vars);
        calculate_s(fri_params, local_vars);

        local_vars.p_offset = basic_marshalling.skip_length(local_vars.round_proof_values_offset);
        local_vars.b = new bytes(0x40 * fri_params.leaf_size * local_vars.correct_order_idx.length);
        uint256 polynomial_vector_size = 0x8 + 0x40 * local_vars.correct_order_idx.length;
        local_vars.ys = new uint256[][][](fri_params.leaf_size);


        for (local_vars.p_ind = 0; local_vars.p_ind < fri_params.leaf_size;) {

            size = basic_marshalling.get_length(blob, local_vars.p_offset);
            local_vars.ys[local_vars.p_ind] = new uint256[][](local_vars.correct_order_idx.length);
            require(size == (1 << local_vars.r_step), "Wrong round proof values size");

            for(uint256 ind = 0; ind < local_vars.correct_order_idx.length; ind++ ){
                local_vars.ys[local_vars.p_ind][ind] = new uint256[](2);
            }

            for(uint256 ind = 0; ind < local_vars.correct_order_idx.length; ind++ ){
                uint256 y_ind = local_vars.correct_order_idx[ind][0];
            //require(local_vars.i_step != 4 || ind == 0, "We are here");
                // Check leaf size
                // Prepare y-s
                local_vars.y_offset = basic_marshalling.skip_length(local_vars.p_offset) 
                    + local_vars.correct_order_idx[ind][0] * 0x40;

                uint256 y0 = basic_marshalling.get_uint256_be(blob, local_vars.y_offset);
                uint256 y1 = basic_marshalling.get_uint256_be(blob, local_vars.y_offset + 0x20);
                local_vars.ys[local_vars.p_ind][y_ind][0] = y0;
                local_vars.ys[local_vars.p_ind][y_ind][1] = y1;
                //require(local_vars.r_step < 3, logging.uint2hexstr(y_ind));            
                //require(local_vars.r_step < 3 || y_ind != 6, logging.uint2hexstr(y_ind));            
             //require(local_vars.i_step!=4, local_vars.ys[local_vars.p_ind][ind][0]);
                // push y
                uint256 first_offset = 0x20 + 0x40*ind+0x40*local_vars.p_ind*local_vars.correct_order_idx.length;
                uint256 second_offset = first_offset+ 0x20;
                //require(local_vars.p_ind != 1, logging.uint2hexstr(second_offset));
                if(local_vars.correct_order_idx[ind][1] == 0){
                    assembly{
                        mstore(add(mload(add(local_vars, BYTES_B_OFFSET)),first_offset), y0)
                        mstore(add(mload(add(local_vars, BYTES_B_OFFSET)),second_offset), y1)
                    }
                } else {
                    assembly{
                        mstore(add(mload(add(local_vars, BYTES_B_OFFSET)),first_offset), y1)
                        mstore(add(mload(add(local_vars, BYTES_B_OFFSET)),second_offset), y0)
                    }
                }
            }
            local_vars.p_offset += polynomial_vector_size;
            unchecked{ local_vars.p_ind++; }
        }
        evaluate_first_round_ys(fri_params, local_vars);
            //require(false, logging.memory_chunk256_to_hexstr(local_vars.b, 0x80));
    }

    // It's called from prepare_leafs_and_ys because it is a part of y-s preparation
    function evaluate_first_round_ys(types.fri_params_type memory fri_params, local_vars_type memory local_vars)
    internal view{
        uint256 U_evaluated_neg;
        uint256 V_evaluated_inv;
        uint256 result;

        if(local_vars.global_round_index == 0){
            for(local_vars.p_ind = 0; local_vars.p_ind < local_vars.ys.length; local_vars.p_ind++){
                for(uint256 i1 = 0; i1 < local_vars.ys[local_vars.p_ind].length; i1++){
                    for(uint256 i2 = 0; i2 < local_vars.ys[local_vars.p_ind][i1].length; i2++){
                        result = y_to_y0_for_first_step(
                            local_vars.s[i1][i2], 
                            local_vars.ys[local_vars.p_ind][i1][i2], 
                            fri_params.batched_U[local_vars.p_ind], 
                            fri_params.batched_V[local_vars.p_ind], 
                            fri_params.modulus
                        );
                        local_vars.ys[local_vars.p_ind][i1][i2] = result;
                    }
                }
            }
        }
    }

    function skip_to_final_poly(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset){
        // round_proofs
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        for (uint256 i = 0; i < value_len;) {
            result_offset = skip_round_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
        // values
        result_offset = basic_marshalling.skip_v_of_vectors_of_vectors_of_uint256_be(blob, result_offset);        
    }

    function init_local_vars(bytes calldata blob, uint256 offset, types.fri_params_type memory  fri_params, local_vars_type memory local_vars)
    internal view {
        // Fri proof fields
        local_vars.final_poly_offset = skip_to_final_poly(blob, offset);  // one for all rounds
        local_vars.values_offset = skip_to_values_be(blob, offset);  // one for all rounds

        // Fri round proof fields (for step)
        local_vars.round_proof_offset = skip_to_first_round_proof_be(blob, offset); // current round proof offset. It's round_proof.p offset too.
        local_vars.round_proof_T_root_offset = skip_to_round_proof_T_root_be(blob, local_vars.round_proof_offset);   // prepared for transcript.
        local_vars.round_proof_colinear_path_offset = skip_to_round_proof_colinear_path(blob, local_vars.round_proof_offset);  // current round proof colinear_path offset.
        local_vars.round_proof_colinear_path_T_root_offset = skip_to_round_proof_colinear_path_T_root_be(blob, local_vars.round_proof_offset);  // current round proof colinear_path offset.
        local_vars.round_proof_values_offset = basic_marshalling.skip_length(local_vars.values_offset);               // offset item in fri_proof.values structure for current round proof
        //round_proof_colinear_value;  // It is the value. Not offset. Have to be computed
        // 0x120
        local_vars.i_step = 0;                                                 // current step
        local_vars.r_step = fri_params.step_list[local_vars.i_step];           // current step

        // Fri params for one round (in step)
        // 0x60
        // local_vars.x;                // have to be computed
        // 0x80
        // local_vars.x_next;           // computed later
        // 0xa0
        // local_vars. alpha;           // computed later
        // 0x320
        local_vars.domain_size = 1 << fri_params.D_omegas.length; // domain size TODO change domain representation
        local_vars.omega = fri_params.D_omegas[0];           // domain generator
        local_vars.global_round_index = 0;                   // current FRI round
        local_vars.i_round = 0;                              // current round in step
    }

    function step_local_vars(bytes calldata blob, uint256 offset, types.fri_params_type memory  fri_params, local_vars_type memory local_vars)
    internal view {
        // Fri round proof fields (for step)
        // move to next round proof
        local_vars.round_proof_offset = skip_round_proof_be(blob, local_vars.round_proof_offset); 
        // move to next T_root
        local_vars.round_proof_T_root_offset = skip_to_round_proof_T_root_be(blob, local_vars.round_proof_offset); 
        // move to next colinear path
        local_vars.round_proof_colinear_path_offset = skip_to_round_proof_colinear_path(blob, local_vars.round_proof_offset);  
        // current round proof colinear_path root offset for transcript
        local_vars.round_proof_colinear_path_T_root_offset = skip_to_round_proof_colinear_path_T_root_be(blob, local_vars.round_proof_offset);  
        // offset item in fri_proof.values structure for current round proof
        local_vars.round_proof_values_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, local_vars.round_proof_values_offset);    
        //round_proof_colinear_value;  // It is the value. Not offset. Have to be computed
        // 0x120
        local_vars.i_step++;                                                 // current step
        local_vars.r_step = fri_params.step_list[local_vars.i_step];           // current step
        //local_vars.domain_size >>= local_vars.r_step;
        //local_vars.x_index %= local_vars.domain_size;

        // Fri params for one round (in step)
        // 0x60
        // local_vars.x;                // have to be computed
        // 0x80
        // local_vars.x_next;           // computed later
        // 0xa0
        // local_vars. alpha;           // computed later

        // TODO domain work
        // 0x320
        /*
        local_vars.domain_size = fri_params.D_omegas.length; // domain size TODO change domain representation
        // 0x340
        local_vars.omega = fri_params.D_omegas[0];           // domain generator
        // 0x200 
        local_vars.global_round_index = 0;                   // current FRI round
        // 0x240 
        local_vars.i_round = 0;                              // current round in step
        */
    }

    function sqr_mod(uint256 x, uint256 modulus)
    internal pure returns(uint256 result){
        assembly{
            result := mulmod(x, x, modulus)
        }
    }

    function round_local_vars(bytes calldata blob, uint256 offset, types.fri_params_type memory  fri_params, local_vars_type memory local_vars)
    internal view {
        local_vars.domain_size >>=1;
        local_vars.x_index %= local_vars.domain_size;
        local_vars.x = sqr_mod(local_vars.x, fri_params.modulus);
        local_vars.global_round_index++;

        local_vars.omega = sqr_mod(local_vars.omega, fri_params.modulus);
    }

    function parse_verify_proof_be(
        bytes calldata blob, 
        uint256 offset, 
        types.transcript_data memory tr_state,
        types.fri_params_type memory fri_params
    )
    internal view returns (bool result) {
        // TODO: offsets in local vars should be better
        // But it needs assembly work

        result = false;
        //require(m == 2, "m has to be equal to 2!");
        //require(fri_params.step_list.length - 1 == get_round_proofs_n_be(blob, offset), "Wrong round proofs number");
        //require(fri_params.leaf_size <= fri_params.batched_U.length, "Leaf size is not equal to U length!");
        //require(fri_params.leaf_size <= fri_params.batched_V.length, "Leaf size is not equal to V length!");

        local_vars_type memory local_vars;
        init_local_vars(blob, offset, fri_params, local_vars);

        transcript.update_transcript_b32_by_offset_calldata(tr_state, blob, local_vars.round_proof_T_root_offset);
        local_vars.x_index = transcript.get_integral_challenge_be(tr_state, 8) % local_vars.domain_size;
        local_vars.x = field.expmod_static(
            fri_params.D_omegas[0],
            local_vars.x_index,
            fri_params.modulus
        );
        // TODO target commitment have to be one of the inputs

        // Prepare values.
        // 1.Check values length.
        /*require(
            basic_marshalling.get_length(blob, local_vars.values_offset) == 
            fri_params.step_list.length, "Unsufficient polynomial values data in proofs"
        );*/

        prepare_leaf_data_and_ys(blob, fri_params, local_vars);
        while ( local_vars.i_step < fri_params.step_list.length - 1 ) {
            // Check p. Data for it is prepared before cycle or at the end of it.
            // We don't calculate indices twice.
            if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                blob, local_vars.round_proof_offset, local_vars.b, local_vars.b.length)
            ) {
                require(false, "Merkle proof failed");
                return false;
            }


            //  Reduce ys. Local variables:
            //  c;
            //  modulus;
            //  alpha;
            //  s1;
            //  fs1;
            //  fs2;
            //  res;
        
            for( local_vars.i_round = 0; local_vars.i_round < local_vars.r_step - 1; local_vars.i_round++){
                local_vars.alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);
                local_vars.ys_next = new uint256[][][](fri_params.leaf_size);
                for( local_vars.p_ind = 0; local_vars.p_ind < fri_params.leaf_size; local_vars.p_ind++){
                    local_vars.ys_next[local_vars.p_ind] = new uint256[][](local_vars.ys[local_vars.p_ind].length >> 1);
                    for( local_vars.y_ind = 0; local_vars.y_ind < local_vars.ys_next[local_vars.p_ind].length; local_vars.y_ind++){
                        local_vars.ys_next[local_vars.p_ind][local_vars.y_ind] = new uint256[](2);
                        for ( uint256 ind = 0; ind < local_vars.ys_next[local_vars.p_ind][local_vars.y_ind].length; ind++){
                            uint256 newind = (local_vars.y_ind << 1) + ind;
                            uint256 res;
                            local_vars.s1 = local_vars.s[newind][0];
                            local_vars.fs1 = local_vars.ys[local_vars.p_ind][newind][0];
                            local_vars.fs2 = local_vars.ys[local_vars.p_ind][newind][1];
                            if(local_vars.i_round == 0){
                                assembly{
                                    res:= mulmod(
                                        mload(add(local_vars,S1_OFFSET)),
                                        mulmod(
                                            mload(add(fri_params, CONSTANT_1_2_OFFSET)),
                                            addmod(
                                                mulmod(
                                                    mload(add(local_vars,ALPHA_OFFSET)), 
                                                    addmod(
                                                        sub(mload(fri_params), mload(add(local_vars,FS2_OFFSET))), 
                                                        mload(add(local_vars, FS1_OFFSET)), 
                                                        mload(fri_params)
                                                    ),
                                                    mload(fri_params)
                                                ),
                                                mulmod(
                                                    mload(add(local_vars, S1_OFFSET)), 
                                                    addmod(
                                                        mload(add(local_vars, FS1_OFFSET)),
                                                        mload(add(local_vars, FS2_OFFSET)), 
                                                        mload(fri_params)
                                                    ), 
                                                    mload(fri_params)
                                                ),
                                                mload(fri_params)
                                            ),
                                            mload(fri_params)
                                        ),
                                        mload(fri_params)
                                    )
                                }
                            } else {
                                assembly{
                                    res :=  mulmod(
                                        mload(add(fri_params, CONSTANT_1_2_OFFSET)),
                                        addmod(
                                            mulmod(
                                                mload(add(local_vars, ALPHA_OFFSET)),
                                                addmod(
                                                    mload(add(local_vars, FS1_OFFSET)),
                                                    mload(add(local_vars, FS2_OFFSET)),
                                                    mload(fri_params)
                                                ),
                                                mload(fri_params)
                                            ),
                                            mulmod(
                                                mload(add(local_vars, S1_OFFSET)),
                                                addmod(
                                                    mload(add(local_vars, FS1_OFFSET)),
                                                    sub(mload(fri_params), mload(add(local_vars, FS2_OFFSET))),
                                                    mload(fri_params)
                                                ),
                                                mload(fri_params)
                                            ),
                                            mload(fri_params)
                                        ),
                                        mload(fri_params)
                                    )
                                }
                            }
                            local_vars.ys_next[local_vars.p_ind][local_vars.y_ind][ind] = res;
                        }
                    }
                }
                local_vars.ys = local_vars.ys_next;
                round_local_vars(blob, offset, fri_params, local_vars);
                calculate_s_indices(local_vars);
                calculate_s(fri_params, local_vars);
            }

            local_vars.alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);
            
            transcript.update_transcript_b32_by_offset_calldata(
                tr_state, 
                blob, 
                local_vars.round_proof_colinear_path_T_root_offset
            );
            uint256 colinear_path_offset = local_vars.round_proof_colinear_path_offset;

            local_vars.s1 = local_vars.x;
            local_vars.cc_one_round_step = (local_vars.r_step == 1);
            local_vars.ys_previous = local_vars.ys;

            round_local_vars(blob, offset, fri_params, local_vars);
            step_local_vars(blob, offset, fri_params, local_vars);
            prepare_leaf_data_and_ys(blob, fri_params, local_vars);

            uint256 res;
            uint256 c;
            for( local_vars.p_ind = 0; local_vars.p_ind < fri_params.leaf_size;){
                c = local_vars.ys[local_vars.p_ind][0][0];
                // prepare vars for colinear check
                local_vars.fs1 = local_vars.ys_previous[local_vars.p_ind][0][0];
                local_vars.fs2 = local_vars.ys_previous[local_vars.p_ind][0][1];
                
                if(local_vars.cc_one_round_step){
                    assembly {
                        c := mulmod(mload(add(local_vars, S1_OFFSET)), c, mload(fri_params))
                        c := addmod(c, c, mload(fri_params))
                        res:= addmod(
                            mulmod(
                                mload(add(local_vars,ALPHA_OFFSET)), 
                                addmod(sub(mload(fri_params), mload(add(local_vars,FS2_OFFSET))), mload(add(local_vars,FS1_OFFSET)), mload(fri_params)), 
                                mload(fri_params)
                            ),
                            mulmod(mload(add(local_vars, S1_OFFSET)), addmod(mload(add(local_vars,FS1_OFFSET)), mload(add(local_vars,FS2_OFFSET)), mload(fri_params)), mload(fri_params)), 
                            mload(fri_params)
                        )
                    }
                } else {
                    assembly{
                        c := mulmod(
                            mload(add(local_vars, S1_OFFSET)), 
                            mulmod(
                                mload(add(local_vars, S1_OFFSET)), 
                                c,
                                mload(fri_params)
                            ),
                            mload(fri_params)
                        )              
                        c:=addmod(c, c, mload(fri_params))
                        res := addmod(
                            mulmod(
                                mload(add(local_vars, ALPHA_OFFSET)),
                                addmod(
                                    mload(add(local_vars, FS1_OFFSET)),
                                    mload(add(local_vars, FS2_OFFSET)),
                                    mload(fri_params)
                                ),
                                mload(fri_params)
                            ),
                            mulmod(
                                mload(add(local_vars, S1_OFFSET)),
                                addmod(
                                    mload(add(local_vars, FS1_OFFSET)),
                                    sub(mload(fri_params), mload(add(local_vars, FS2_OFFSET))),
                                    mload(fri_params)
                                ),
                                mload(fri_params)
                            ),
                            mload(fri_params)
                        )
                    }
                }
                if( c != res ){
                    require( false, "Colinear check failed" );
                    return false;
                }
                unchecked {local_vars.p_ind++;}
            }
            
            if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                blob, 
                colinear_path_offset, 
                local_vars.b, local_vars.b.length)
            ) {
                require(false, "Round_proof.colinear_path verifier failes");
                return false;
            }
        }
        require(fri_params.leaf_size == basic_marshalling.get_length(blob, local_vars.final_poly_offset),
            "Final poly array size is not equal to params.leaf_size!");
        local_vars.final_poly_offset = basic_marshalling.skip_length(local_vars.final_poly_offset);
        for (local_vars.p_ind = 0; local_vars.p_ind < fri_params.leaf_size; local_vars.p_ind++) {
             if (basic_marshalling.get_length(blob, local_vars.final_poly_offset) - 1 >
                uint256(2) ** (field.log2(fri_params.max_degree + 1) - fri_params.r + 1) - 1) {
                require(false, "Max degree problem");
                return false;
            }
            if( polynomial.evaluate_by_ptr(
                blob,
                local_vars.final_poly_offset + basic_marshalling.LENGTH_OCTETS,
                basic_marshalling.get_length(blob, local_vars.final_poly_offset),
                local_vars.x,
                fri_params.modulus
            ) != local_vars.ys[local_vars.p_ind][0][0]){
                require(false, "Final polynomial check failed");
                return false;
            }
            local_vars.final_poly_offset = basic_marshalling.skip_vector_of_uint256_be(blob, local_vars.final_poly_offset);
        }
        return true;
    }
}