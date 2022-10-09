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
        bytes       b;
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
        uint256 alpha;                                   // alpha challenge
        uint256 domain_size;                             // domain size
        uint256 omega;                                   // domain generator
        uint256 global_round_index;                      // current FRI round
        uint256 i_round;                                 // current round in step

        // Some internal variables
        uint256 y_polynom_index_j;          // ??
        uint256 y_j_size;                   // ??
        uint256 verified_data_offset;       // ??
        uint256 polynom_index;              // ??
        uint256 p_offset;
        uint256 y_offset;
        uint256[][] s_indices;              // ??
        uint256[][] s;                      // ??
        uint256[][] correct_order_idx;      // ??
        uint256[][] ys;                     // ??
    }

    uint256 constant BYTES_B_OFFSET = 0x0;
    uint256 constant COLINEAR_VALUE_OFFSET = 0x0;
    uint256 constant T_ROOT_OFFSET_OFFSET = 0x20;
    uint256 constant FINAL_POLY_OFFSET_OFFSET = 0x40;
    uint256 constant X_OFFSET = 0x60;
    uint256 constant X_NEXT_OFFSET = 0x80;
    uint256 constant ALPHA_OFFSET = 0xa0;
    uint256 constant ROUND_PROOF_OFFSET_OFFSET = 0xc0;
    uint256 constant ROUND_PROOF_Y_OFFSET_OFFSET = 0xe0;
    uint256 constant ROUND_PROOF_P_OFFSET_OFFSET = 0x100;
    uint256 constant Y_POLYNOM_INDEX_J_OFFSET = 0x120;
    uint256 constant Y_J_OFFSET_OFFSET = 0x140;
    uint256 constant Y_J_SIZE_OFFSET = 0x160;
    uint256 constant STATUS_OFFSET = 0x180;
    uint256 constant VALUES_OFFSET = 0x240;

    uint256 constant BATCHED_FRI_VERIFIED_DATA_OFFSET = 0x160;
    uint256 constant VERIFIED_DATA_OFFSET = 0x300;

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

    // Attention
    function store_i_chunk_in_verified_data(types.fri_params_type memory fri_params, uint256 chunk, uint256 i)
    internal pure {
        assembly {
            mstore(
                add(
                    add(
                        mload(
                            add(fri_params, BATCHED_FRI_VERIFIED_DATA_OFFSET)
                        ),
                        0x20
                    ),
                    mul(0x20, i)
                ),
                chunk
            )
        }
    }

    function get_domain_element(types.fri_params_type memory fri_params, uint256 s_index)
    internal pure returns (uint256 s){
        require(false, "Get domain element");
        s = fri_params.D_omegas[s_index];
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
    internal pure  {
        local_vars.s = new uint256[][](local_vars.s_indices.length);
        get_domain_element(fri_params, 0);
        for( uint256 i = 0; i < local_vars.s_indices.length; i++ ){
            local_vars.s[i] = new uint256[](2);
            local_vars.s[i][0] = 0;
//            local_vars.s[i][0] = get_domain_element(fri_params, local_vars.s_indices[i][0]);
//            local_vars.s[i][1] = get_domain_element(fri_params, local_vars.s_indices[1][1]);
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
    function prepare_leaf_data(
        bytes calldata blob, 
        types.fri_params_type memory fri_params,
        local_vars_type memory local_vars )
    internal  view
    {
        // Check length parameters correctness
        uint256 size = basic_marshalling.get_length(blob, local_vars.round_proof_values_offset);
        //require(size == fri_params.leaf_size, "Invalid polynomial number in proof.values");

        calculate_s_indices(local_vars);
        //calculate_s(fri_params, local_vars);
        calculate_correct_order_idx(local_vars);

        local_vars.p_offset = basic_marshalling.skip_length(local_vars.round_proof_values_offset);
        local_vars.b = new bytes(0x40 * fri_params.leaf_size * local_vars.correct_order_idx.length);
        uint256 polynomial_vector_size = 0x8 + 0x40 * local_vars.correct_order_idx.length;

        for (local_vars.y_polynom_index_j = 0; local_vars.y_polynom_index_j < fri_params.leaf_size;) {
            size = basic_marshalling.get_length(blob, local_vars.p_offset);
            if(size != (1 << local_vars.r_step)){
                //require(false, logging.uint2hexstr(local_vars.round_proof_values_offset));
            }
            //require(size == (1 << local_vars.r_step), "Wrong round proof values size");

            for(uint256 ind = 0; ind < local_vars.correct_order_idx.length; ind++ ){
                // Check leaf size
                // Prepare y-s
                local_vars.y_offset = basic_marshalling.skip_length(local_vars.p_offset) 
                    + local_vars.correct_order_idx[ind][0] * 0x40;

                uint256 y0 = basic_marshalling.get_uint256_be(blob, local_vars.y_offset);
                uint256 y1 = basic_marshalling.get_uint256_be(blob, local_vars.y_offset + 0x20);
                //require(local_vars.y_polynom_index_j!=1, logging.uint2hexstr(y0));
                // push y
                uint256 first_offset = 0x20 + 0x40*ind+0x40*local_vars.y_polynom_index_j*local_vars.correct_order_idx.length;
                uint256 second_offset = first_offset+ 0x20;
                //require(local_vars.y_polynom_index_j != 1, logging.uint2hexstr(second_offset));
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
            unchecked{ local_vars.y_polynom_index_j++; }
        }
        //require(false, logging.memory_chunk256_to_hexstr(local_vars.b, 0x80));
    }

/*
    function prepare_ys(
        bytes calldata blob, 
        types.fri_params_type memory  fri_params, 
        local_vars_type memory local_vars)
    internal view returns (uint256[][] memory ys){
        uint256 coset_size = 1 << fri_params.step_list[local_vars.i_step];
        ys = new uint256[][](coset_size >> 1);
        for( uint256 i = 0; i < ys.length; i++){
            ys[i] = new uint256[](2);
            ys[i][0] = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(blob, local_vars.values_offset, i, 0);
            ys[i][1] = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(blob, local_vars.values_offset, i, 1);
        }
    }
*/
    // for the first round
    /*function eval_y_from_blob(bytes calldata blob, local_vars_type memory local_vars, uint256 i, uint256 j,
                              types.fri_params_type memory fri_params)
    internal view returns (uint256 result) {
        result = basic_marshalling.get_i_uint256_from_vector(blob, local_vars.y_j_offset, local_vars.y_polynom_index_j);
        if (i == 0) {
            uint256 U_evaluated_neg;
            uint256 V_evaluated_inv;
            if (j == 0) {
                U_evaluated_neg =
                    fri_params.modulus -
                    polynomial.evaluate(
                        fri_params.batched_U[local_vars.y_polynom_index_j],
                        local_vars.x, fri_params.modulus
                    );
                V_evaluated_inv = field.inverse_static(
                    polynomial.evaluate(
                        fri_params.batched_V[local_vars.y_polynom_index_j],
                        local_vars.x,
                        fri_params.modulus
                    ),
                    fri_params.modulus
                );
            } else if (j == 1) {
                U_evaluated_neg =
                    fri_params.modulus -
                    polynomial.evaluate(
                        fri_params.batched_U[local_vars.y_polynom_index_j],
                        fri_params.modulus - local_vars.x,
                        fri_params.modulus
                    );
                V_evaluated_inv = field.inverse_static(
                    polynomial.evaluate(
                        fri_params.batched_V[local_vars.y_polynom_index_j],
                        fri_params.modulus - local_vars.x,
                        fri_params.modulus
                    ),
                    fri_params.modulus
                );
            }
            assembly {
                result := mulmod(
                    addmod(result, U_evaluated_neg, mload(fri_params)),
                    V_evaluated_inv,
                    mload(fri_params)
                )
            }
        }
        local_vars.y_j_offset = basic_marshalling.skip_vector_of_uint256_be(blob, local_vars.y_j_offset);
    }*/

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
    internal view returns (bool result){
        result = false;
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
        result = true;
    }

    function step_local_vars(bytes calldata blob, uint256 offset, types.fri_params_type memory  fri_params, local_vars_type memory local_vars)
    internal view returns (bool result){
        result = false;
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
        result = true;
    }

    function parse_verify_proof_be(
        bytes calldata blob, 
        uint256 offset, 
        types.transcript_data memory tr_state,
        types.fri_params_type memory fri_params
    )
    internal view returns (bool result) {
        result = false;
        require(m == 2, "m has to be equal to 2!");
        require(fri_params.step_list.length - 1 == get_round_proofs_n_be(blob, offset), "Wrong round proofs number");
        require(fri_params.leaf_size <= fri_params.batched_U.length, "Leaf size is not equal to U length!");
        require(fri_params.leaf_size <= fri_params.batched_V.length, "Leaf size is not equal to V length!");

        local_vars_type memory local_vars;
        init_local_vars(blob, offset, fri_params, local_vars);

        transcript.update_transcript_b32_by_offset_calldata(tr_state, blob, local_vars.round_proof_T_root_offset);
        local_vars.x_index = transcript.get_integral_challenge_be(tr_state, 8) % local_vars.domain_size;
        // TODO target commitment have to be one of the inputs

        // Prepare values.
        // 1.Check values length.
        require(
            basic_marshalling.get_length(blob, local_vars.values_offset) == 
            fri_params.step_list.length, "Unsufficient polynomial values data in proofs"
        );

        prepare_leaf_data(blob, fri_params, local_vars);
        
        // TODO: calculate y_0 from U and V.Prepare for the first step.
        //local_vars.ys = prepare_ys(blob, fri_params, local_vars);
        //require(false, "We are here");
        /*for( uint256 ind = 0; ind < local_vars.ys.length; ind++){
            for (uint256 jind = 1; jind < local_vars.ys[ind].length; jind++){
                local_vars.ys[ind][jind] = eval_y_from_blob(blob, local_vars, ind, jind, fri_params);
            }
        }
        */
        while ( local_vars.i_step < fri_params.step_list.length - 1 ) {
            // Check p. Data for it is prepared before cycle or at the end of it.
            // We don't calculate indices twice.
            if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                blob, local_vars.round_proof_offset, local_vars.b, local_vars.b.length)
            ) {
                //require(false, logging.uint2decstr(fri_params.i_fri_proof));
                //require(false, logging.uint2hexstr(local_vars.b.length));
                //require(false, logging.calldata_chunk256_to_hexstr(blob, local_vars.round_proof_offset));
                //require(false, logging.uint2decstr(local_vars.x_index));
                require(false, "Merkle proof failed");
                //require(false, logging.memory_chunk256_to_hexstr(local_vars.b, 0x80));
                //require(false, logging.uint2hexstr(local_vars.i_step));
                return false;
            }
            //require(false, "One merkle proof is right");

            //if(fri_params.i_fri_proof == 0 && local_vars.i_step == 1) require(false, logging.uint2hexstr(local_vars.alpha));


            for( local_vars.i_round = 0; local_vars.i_round < local_vars.r_step - 1; local_vars.i_round++){
                local_vars.domain_size >>=1;
                local_vars.x_index %= local_vars.domain_size;
                local_vars.global_round_index++;
                local_vars.alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);
            }

            local_vars.alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);
            
            transcript.update_transcript_b32_by_offset_calldata(
                tr_state, 
                blob, 
                local_vars.round_proof_colinear_path_T_root_offset
            );
            //if (fri_params.i_fri_proof == 0 && local_vars.i_step == 1) 
            //    require(false, logging.calldata_chunk256_to_hexstr(blob, local_vars.round_proof_colinear_path_T_root_offset));
            uint256 colinear_path_offset = local_vars.round_proof_colinear_path_offset;

            local_vars.domain_size >>= 1;
            local_vars.x_index %= local_vars.domain_size;
            local_vars.global_round_index++;
            step_local_vars(blob, offset, fri_params, local_vars);
            prepare_leaf_data(blob, fri_params, local_vars);
            if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                blob, 
                colinear_path_offset, 
                local_vars.b, local_vars.b.length)
            ) {
                require(false, "Colinear path check failed");
                //return false;
            }
            //require(false, "First colinear check is well");
        }
        //require(false, "All Merkle checks are well");
        return true;
            //require(false, logging.uint2decstr(local_vars.i_step));
        /*    local_vars.alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);

            // TODO: check merkle roots for i-th round proof
            // TODO: prepare first y: from y_0 or from y
            // TODO: make first reduction step manually
            for( local_vars.i_round = 1; local_vars.i_round < fri_params.step_list[local_vars.i_step] - 1;){
                require(false, "TODO: realize skipping layers");
                // only for skipped layers.
                // TODO: reduce points in step with interpolation
                // TODO: get alpha from transcript
                // TODO: for all polynomials interpolate pairs and get new y-s until S reduces in only two dots.
                unchecked { local_vars.i_round++; }
            }

            //TODO: Prepare data for colinear checks and values for next round.
            unchecked{ local_vars.global_round_index++; }
            domain_size = domain_size >> 1;                                 //
            uint256 x_index_next = (local_vars.x_index << 1) % domain_size; // x_index_next = (2*x_index)%domain_size;
            uint256 fri_next_step = fri_params.step_list[local_vars.i_step + 1];
            s_indices = calculate_s_indices(x_index_next, fri_next_step, domain_size);

            //TODO: Colinear check

            //TODO։ push round proof.colinear_path.T_root to transcript
            local_vars.T_root_offset = skip_to_round_proof_colinear_path_T_root_be(blob, local_vars.round_proof_offset);
            transcript.update_transcript_b32_by_offset_calldata(tr_state, blob, local_vars.T_root_offset);
            require(false, logging.uint2hexstr(basic_marshalling.get_uint256_be(blob, local_vars.T_root_offset)));
            

            local_vars.round_proof_colinear_path_offset = skip_to_round_proof_colinear_path(blob, local_vars.round_proof_offset);

            // Check round_proof.colinear_path
            b = prepare_leaf_data(blob, fri_params, local_vars);
            if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                blob, local_vars.round_proof_colinear_path_offset, b, b.length)) {

                uint256 logvar;
                assembly {
                    logvar:=mload(add(b, 0x40))
                }
                require(false, logging.uint2hexstr(local_vars.x_index));

                require(false, "Colinear path check failed");
                return false;
            }
//            local_vars.ys = prepare_ys(blob, fri_params, local_vars);*/
        }
        // TODO: final checks.
        /*    // TODO: for all rounds in step reduce points set
            // TODO: get alpha challenge
            local_vars.alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);
            local_vars.x_next = mulmod(
                local_vars.x,
                local_vars.x,
                fri_params.modulus
            );

            // TODO: verify one round proof, values have to be one of parameters
            if (!parse_verify_round_proof_be(blob, local_vars.round_proof_offset, fri_params, local_vars)) {
                return false;
            }

            // TODO: for each polynomial do colinear check
            for (local_vars.y_polynom_index_j = 0; loc_vars.y_polynom_index_j < fri_params.leaf_size;) {

                local_vars.colinear_value = basic_marshalling
                    .get_i_uint256_from_vector(blob, local_vars.round_proof_offset, local_vars.y_polynom_index_j);
                store_i_chunk_in_verified_data(fri_params, local_vars.colinear_value, local_vars.y_polynom_index_j);
                local_vars.y_j_offset = skip_to_first_round_proof_y_be(blob, local_vars.round_proof_offset);

                if (polynomial.interpolate_evaluate_by_2_points_neg_x(
                        local_vars.x,
                        field.inverse_static(field.double(local_vars.x, fri_params.modulus), fri_params.modulus),
                        eval_y_from_blob(blob, local_vars, i, 0, fri_params),
                        eval_y_from_blob(blob, local_vars, i, 1, fri_params),
                        local_vars.alpha,
                        fri_params.modulus
                    ) != local_vars.colinear_value
                ) {
                    return false;
                }

                unchecked{ local_vars.y_polynom_index_j++; }
            }

            // get round_proofs[i].colinear_path.root
             }
            local_vars.round_proof_offset = skip_round_proof_be(blob, local_vars.round_proof_offset);

            local_vars.x = local_vars.x_next;
            unchecked{ i++; }
        /*
        require(fri_params.leaf_size == basic_marshalling.get_length(blob, offset),
                "Final poly array size is not equal to params.leaf_size!");
        local_vars.final_poly_offset = offset + basic_marshalling.LENGTH_OCTETS;
        for (uint256 polynom_index = 0; polynom_index < fri_params.leaf_size;) {
            if (basic_marshalling.get_length(blob, local_vars.final_poly_offset) - 1 >
                uint256(2) ** (field.log2(fri_params.max_degree + 1) - fri_params.r + 1) - 1) {
                return false;
            }

            local_vars.final_poly_offset = basic_marshalling.skip_vector_of_uint256_be(blob, local_vars.final_poly_offset);
            unchecked{ polynom_index++; }
        }*/
}