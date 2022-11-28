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

    uint256 constant FRI_PARAMS_BYTES_B_OFFSET = 0x260;
    uint256 constant FRI_PARAMS_COEFFS_OFFSET = 0x280;

    uint256 constant S1_OFFSET = 0x00;                                      
    uint256 constant X_OFFSET = 0x20;                                      
    uint256 constant ALPHA_OFFSET = 0x40;                                   // alpha challenge
    uint256 constant COEFFS_OFFSET = 0x60;
    uint256 constant Y_OFFSET = 0x80;
    uint256 constant COLINEAR_OFFSET = 0xa0;                                // colinear_value_offset
    uint256 constant C1_OFFSET = 0xc0;                                      // coefficient1_offset
    uint256 constant C2_OFFSET = 0xe0;                                      // coefficient2_offset
    uint256 constant INTERPOLANT_OFFSET = 0x100;
    uint256 constant PREV_COEFFS_LEN_OFFSET = 0x120;

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
    internal pure returns(uint256 result ){
        unchecked{ result = (x_index + (domain_size >> 1)) & (domain_size - 1); }
    }

    function calculate_s(
        types.fri_params_type memory fri_params,
        local_vars_type memory local_vars) internal view{

        unchecked{ local_vars.indices_size = 1 << (local_vars.r_step - 1); } // TODO to roud_local_vars
        fri_params.s[0] = local_vars.x;
        if( local_vars.indices_size > 1){
            uint256 base_index = local_vars.domain_size >> 2; 
            uint256 prev_half_size = 1;
            uint256 i = 1;
            uint256 j;
            local_vars.newind = fri_params.D_omegas.length - 1;
            while( i < local_vars.indices_size ){
                for( j = 0; j < prev_half_size;) {
                    fri_params.s[i] = field.fmul(fri_params.s[j], fri_params.D_omegas[local_vars.newind], fri_params.modulus);
                    unchecked{ i++; } // TODO: is it really here? Yes, it is))
                    unchecked{ j++; }
                }
                unchecked{
                    base_index >>=1;
                    prev_half_size <<=1;
                    local_vars.newind--;
                }
            }
        }
    }

    // calculate indices for coset S = {s\in D| s^(2^fri_step) == x_next}
    function get_folded_index(uint256 x_index, uint256 fri_step, uint256 domain_size_mod) 
    internal pure returns(uint256 result){
        unchecked{result = x_index & (domain_size_mod >> fri_step);}
    }

    // Reorder data from values. 
    // local_vars: values_offset, fri_step, domain_size, i_step, y_j_offset,
    function prepare_leaf_data(
        bytes calldata blob, 
        types.fri_params_type memory fri_params,
        local_vars_type memory local_vars )
    internal  pure
    {
        // Check length parameters correctness
        require(basic_marshalling.get_length(blob, local_vars.round_proof_values_offset) == fri_params.leaf_size, "Invalid polynomials number in proof.values");

        // Calculate s_indices
        fri_params.s_indices[0] = local_vars.x_index;
        fri_params.s[0] = local_vars.x;
        fri_params.tmp_arr[0] = get_folded_index(local_vars.x_index, local_vars.r_step, local_vars.domain_size_mod);

        uint256 base_index;
        uint256 prev_half_size;
        uint256 i;
        uint256 j;

        if( local_vars.indices_size > 1){
            unchecked{
                base_index = local_vars.domain_size >> 2; 
                prev_half_size = 1;
                i = 1;
                local_vars.newind = fri_params.D_omegas.length - 1;
            }
            while( i < local_vars.indices_size ){
                for( j = 0; j < prev_half_size;) {
                    unchecked{
                        fri_params.s_indices[i] = (base_index + fri_params.s_indices[j]) & local_vars.domain_size_mod;
                        fri_params.tmp_arr[i] =     (base_index + fri_params.tmp_arr[j]) & local_vars.domain_size_mod;
                    }
                    fri_params.s[i] = field.fmul(fri_params.s[j], fri_params.D_omegas[local_vars.newind], fri_params.modulus);
                    unchecked{ i++; } // TODO: is it really here? Yes, it is))
                    unchecked{ j++; }
                }
                unchecked{
                    base_index >>=1;
                    prev_half_size <<=1;
                    local_vars.newind--;
                }
            }
        }

        for ( i = 0; i < local_vars.indices_size;) {
            for(j = 0; j < local_vars.indices_size;){
                if(fri_params.s_indices[j] == fri_params.tmp_arr[i]){
                    local_vars.newind = j;
                    break;
                }
                if(get_paired_index(fri_params.s_indices[j], local_vars.domain_size) == fri_params.tmp_arr[i]){
                    local_vars.newind = j;
                    break;
                }
                unchecked{ j++; }
            }
            fri_params.correct_order_idx[i] = local_vars.newind;
            unchecked{ i++; }
        }


        uint256 first_offset = 0x20;
        uint256 y_offset;

        for (local_vars.p_ind = 0; local_vars.p_ind < fri_params.leaf_size;) {
            for(local_vars.y_ind = 0; local_vars.y_ind < local_vars.indices_size;){
                local_vars.newind = fri_params.correct_order_idx[local_vars.y_ind];
                // Check leaf size
                // Prepare y-s
                unchecked{ y_offset = local_vars.p_offset + ( local_vars.newind << 6 ) + 0x8; }

                // push y
                if(fri_params.s_indices[local_vars.newind] == fri_params.tmp_arr[local_vars.y_ind]){
                    assembly{
                        mstore(
                            add(mload(add(fri_params, FRI_PARAMS_BYTES_B_OFFSET)),first_offset), 
                            calldataload(add(blob.offset, y_offset))
                        )
                        mstore(
                            add(mload(add(fri_params, FRI_PARAMS_BYTES_B_OFFSET)),add(first_offset, 0x20)), 
                            calldataload(add(blob.offset, add(y_offset, 0x20)))
                        )
                    }
                } else {
                    assembly{
                        mstore(
                            add(mload(add(fri_params, FRI_PARAMS_BYTES_B_OFFSET)),first_offset), 
                            calldataload(add(blob.offset, add(y_offset, 0x20)))
                        )
                        mstore(
                            add(mload(add(fri_params, FRI_PARAMS_BYTES_B_OFFSET)),add(first_offset, 0x20)), 
                            calldataload(add(blob.offset, y_offset))
                        )
                    }
                }
                unchecked{ 
                    local_vars.y_ind++; 
                    first_offset += 0x40;
                }
            }
            unchecked{local_vars.p_offset += local_vars.polynomial_vector_size;}
            unchecked{ local_vars.p_ind++; }
//            unchecked{ first_offset += 0x20; }
        }
        local_vars.p_offset = basic_marshalling.skip_length(local_vars.round_proof_values_offset);
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
    internal pure {
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
        local_vars.i_step = 0;                                                 // current step
        local_vars.r_step = fri_params.step_list[local_vars.i_step];           // current step
        unchecked{local_vars.indices_size = 1 << (local_vars.r_step - 1);}
        unchecked{local_vars.polynomial_vector_size = 0x8 + (local_vars.indices_size << 6);}
        unchecked{ local_vars.domain_size = 1 << (fri_params.D_omegas.length + 1); }
        unchecked{ local_vars.domain_size_mod = local_vars.domain_size - 1; }
        local_vars.omega = fri_params.D_omegas[0];               // domain generator
        local_vars.global_round_index = 0;                       // current FRI round
        local_vars.i_round = 0;                                  // current round in step
        local_vars.p_offset = basic_marshalling.skip_length(local_vars.round_proof_values_offset);
        unchecked{ local_vars.b_length = (fri_params.leaf_size << (local_vars.r_step +5)); }
        unchecked{local_vars.y_size = (1 <<(local_vars.r_step - 1));}
        unchecked{local_vars.coeffs_len = 1 << local_vars.r_step;}

        assembly{
            mstore(add(local_vars, COEFFS_OFFSET), add(mload(add(fri_params, FRI_PARAMS_COEFFS_OFFSET)), 0x20))
        }    
    }

    function step_local_vars(bytes calldata blob, uint256 offset, types.fri_params_type memory  fri_params, local_vars_type memory local_vars)
    internal pure {
        // Save useful data from previous step
        local_vars.y_offset = local_vars.round_proof_values_offset + 0x10;
        local_vars.prev_polynomial_vector_size = local_vars.polynomial_vector_size;
        local_vars.prev_coeffs_len = local_vars.coeffs_len;
        local_vars.prev_step = local_vars.r_step;

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
        unchecked{local_vars.i_step++;}                                                 // current step
        local_vars.r_step = fri_params.step_list[local_vars.i_step];           // current step
        local_vars.p_offset = basic_marshalling.skip_length(local_vars.round_proof_values_offset);
        require( basic_marshalling.get_length(blob, local_vars.p_offset) == (1 << local_vars.r_step), "Step list param doesn't according to real values length" );
        unchecked{local_vars.indices_size = 1 << (local_vars.r_step - 1);}
        unchecked{local_vars.polynomial_vector_size = 0x8 + (local_vars.indices_size << 6);}
        unchecked{local_vars.coeffs_len = 1 << local_vars.r_step;}
        unchecked{ local_vars.b_length = (fri_params.leaf_size << (local_vars.r_step +5)); }
        unchecked{local_vars.y_size = (1 <<(local_vars.r_step - 1));}
    }

    function round_local_vars(bytes calldata blob, uint256 offset, types.fri_params_type memory  fri_params, local_vars_type memory local_vars)
    internal view {
        unchecked{
            local_vars.domain_size >>=1;
            local_vars.domain_size_mod >>=1;
            local_vars.x_index &= local_vars.domain_size_mod;
            local_vars.global_round_index++;
            local_vars.y_size >>= 1;
            local_vars.mul <<= 1;
        }

        local_vars.omega = sqr_mod(local_vars.omega, fri_params.modulus);
        local_vars.x = sqr_mod(local_vars.x, fri_params.modulus);
        assembly{
            mstore(add(local_vars, COEFFS_OFFSET), add(mload(add(fri_params, FRI_PARAMS_COEFFS_OFFSET)),0x20))
        }
    }

    function sqr_mod(uint256 x, uint256 modulus)
    internal pure returns(uint256 result){
        assembly{
            result := mulmod(x, x, modulus)
        }
    }

    function get_y_from_blob(bytes calldata blob, uint256 p_offset, uint256 y_ind) 
    internal pure returns( uint256 result ){
        result = basic_marshalling.get_uint256_be(blob, p_offset + (y_ind << 5) + 0x8 );
    }

    function get_evaluated_y_from_blob(
        bytes calldata blob, 
        types.fri_params_type memory fri_params, 
        local_vars_type memory local_vars, 
        uint256 p_offset, 
        uint256 p_ind,
        uint256 y_ind
    )
    internal view returns( uint256 result ){
        if( y_ind&1 == 0){
            result = y_to_y0_for_first_step(
                fri_params.tmp_arr[y_ind>>1], 
                get_y_from_blob(blob, p_offset, y_ind), 
                fri_params.batched_U[p_ind], 
                fri_params.batched_V[p_ind], 
                fri_params.modulus
            );
        } else {
            result = y_to_y0_for_first_step(
                fri_params.modulus - fri_params.tmp_arr[y_ind>>1], 
                get_y_from_blob(blob, p_offset, y_ind), 
                fri_params.batched_U[p_ind], 
                fri_params.batched_V[p_ind], 
                fri_params.modulus
            );
        }
    }

    function parse_verify_proof_be(
        bytes calldata blob, 
        uint256 offset, 
        types.transcript_data memory tr_state,
        types.fri_params_type memory fri_params
    ) internal returns (bool result) {
        // TODO: offsets in local vars should be better
        // But it needs assembly work

        logging.profiling_start_block("batched_fri_verifier::parse_verify_proof_be");
        uint256 c;
        result = false;
        //require(m == 2, "m has to be equal to 2!");
        //require(fri_params.step_list.length - 1 == get_round_proofs_n_be(blob, offset), "Wrong round proofs number");
        //require(fri_params.leaf_size <= fri_params.batched_U.length, "Leaf size is not equal to U length!");
        //require(fri_params.leaf_size <= fri_params.batched_V.length, "Leaf size is not equal to V length!");

        local_vars_type memory local_vars;
        init_local_vars(blob, offset, fri_params, local_vars);

        transcript.update_transcript_b32_by_offset_calldata(tr_state, blob, local_vars.round_proof_T_root_offset);
        local_vars.x_index = transcript.get_integral_challenge_be(tr_state, 8) & local_vars.domain_size_mod;
        local_vars.x = field.expmod_static(
            fri_params.D_omegas[0],
            local_vars.x_index,
            fri_params.modulus
        );

        // TODO target commitment have to be one of the inputs

        // Prepare values.p
        // 1.Check values length.
        require(
            basic_marshalling.get_length(blob, local_vars.values_offset) == 
            fri_params.step_list.length, "Unsufficient polynomial values data in proofs"
        );

        prepare_leaf_data(blob, fri_params, local_vars);
        for( local_vars.y_ind = 0; local_vars.y_ind < local_vars.indices_size; )
        {
            fri_params.tmp_arr[local_vars.y_ind] = fri_params.s[local_vars.y_ind];
            unchecked{local_vars.y_ind++;}
        }


        while ( local_vars.i_step < fri_params.step_list.length - 1 ) {
            // Check p. Data for it is prepared before cycle or at the end of it.
            // We don't calculate indices twice.
            if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                blob, local_vars.round_proof_offset, fri_params.b, local_vars.b_length)
            ) {
                require(false, "Merkle proof failed");
                return false;
            }

            // Calculate coeffs
            if( local_vars.r_step == 1){
                // Hardcode local_vars.r_step == 1.
                local_vars.alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);

                local_vars.s1 = local_vars.x;
                assembly{
                    mstore(
                        add(local_vars, C1_OFFSET),
                        mulmod(
                            addmod(
                                mload(add(local_vars, ALPHA_OFFSET)),
                                mload(local_vars),
                                mload(fri_params)
                            ),
                            mload(local_vars),
                            mload(fri_params)
                        )
                    )
                    mstore(
                        add(local_vars, C2_OFFSET),
                        mulmod(
                            addmod(
                                mload(local_vars),
                                sub(mload(fri_params), mload(add(local_vars, ALPHA_OFFSET))),
                                mload(fri_params)
                            ),
                            mload(local_vars),
                            mload(fri_params)
                        )
                    )
                    mstore(mload(add(local_vars, COEFFS_OFFSET)), mload(add(local_vars,C1_OFFSET)))
                    mstore(add(mload(add(local_vars, COEFFS_OFFSET)), 0x20), mload(add(local_vars,C2_OFFSET)))
                }
            } else {
                //  First-round-specific formulas
                //  Fill fri_params.coeffs array
                local_vars.alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);
                for( local_vars.y_ind = 0; local_vars.y_ind < local_vars.y_size;){
                    local_vars.s1 = fri_params.s[local_vars.y_ind];
                    assembly{
                        mstore(
                            add(local_vars, C1_OFFSET),
                            mulmod(
                                mload(local_vars),
                                addmod(
                                    mload(local_vars),
                                    mload(add(local_vars, ALPHA_OFFSET)),
                                    mload(fri_params)
                                ),
                                mload(fri_params)
                            )
                        )
                        mstore(
                            add(local_vars, C2_OFFSET),
                            mulmod(
                                mload(local_vars),
                                addmod(
                                    mload(local_vars),
                                    sub(mload(fri_params), mload(add(local_vars, ALPHA_OFFSET))),
                                    mload(fri_params)
                                ),
                                mload(fri_params)
                            )
                        )
                        mstore(mload(add(local_vars, COEFFS_OFFSET)), mload(add(local_vars,C1_OFFSET)))
                        mstore(add(mload(add(local_vars, COEFFS_OFFSET)), 0x20), mload(add(local_vars,C2_OFFSET)))
                        mstore(add(local_vars, COEFFS_OFFSET), add(mload(add(local_vars, COEFFS_OFFSET)),0x40))
                    }
                    unchecked{
                        local_vars.y_ind++;
                    }
                }
                round_local_vars(blob, offset, fri_params, local_vars);
                calculate_s(fri_params, local_vars);

                local_vars.mul = 2;
                // Middle-rounds
                for( local_vars.i_round =  1; local_vars.i_round < local_vars.r_step - 1;){
                    local_vars.alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);
                    for( local_vars.y_ind = 0; local_vars.y_ind < local_vars.y_size;){
                        local_vars.s1 = fri_params.s[local_vars.y_ind];
                        assembly{
                            mstore(
                                add(local_vars, C1_OFFSET),
                                addmod(
                                    mload(local_vars),
                                    mload(add(local_vars, ALPHA_OFFSET)),
                                    mload(fri_params)
                                )
                            )
                            mstore(
                                add(local_vars, C2_OFFSET),
                                addmod(
                                    mload(add(local_vars, ALPHA_OFFSET)),
                                    sub(mload(fri_params), mload(local_vars)),
                                    mload(fri_params)
                                )
                            )
                        }

                        // Multiply coeffs.
                        for( local_vars.ind = 0; local_vars.ind < local_vars.mul;){
                            assembly{
                                mstore(mload(add(local_vars, COEFFS_OFFSET)), 
                                    mulmod(
                                        mload(mload(add(local_vars, COEFFS_OFFSET))),
                                        mload(add(local_vars,C1_OFFSET)),
                                        mload(fri_params)
                                    )
                                )
                                mstore(add(local_vars, COEFFS_OFFSET), add(mload(add(local_vars, COEFFS_OFFSET)),0x20))
                            }
                            unchecked{
                                local_vars.ind++; 
                            }
                        }
                        for( local_vars.ind = 0; local_vars.ind < local_vars.mul;){
                            assembly{
                                mstore(mload(add(local_vars, COEFFS_OFFSET)), 
                                    mulmod(
                                        mload(mload(add(local_vars, COEFFS_OFFSET))),
                                        mload(add(local_vars,C2_OFFSET)),
                                        mload(fri_params)
                                    )
                                )
                                mstore(add(local_vars, COEFFS_OFFSET), add(mload(add(local_vars, COEFFS_OFFSET)),0x20))
                            }
                            unchecked{
                                local_vars.ind++; 
                            }
                        }
                        
                        unchecked{
                            local_vars.y_ind++;
                        }
                    }

                    round_local_vars(blob, offset, fri_params, local_vars);
                    calculate_s(fri_params, local_vars);
                    unchecked{  local_vars.i_round++; }
                }

                // Final round
                local_vars.alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);
                local_vars.s1 = local_vars.x;
                assembly{
                    mstore(
                        add(local_vars, C1_OFFSET),
                        addmod(
                            mload(add(local_vars, ALPHA_OFFSET)),
                            mload(local_vars),
                            mload(fri_params)
                        )
                    )
                    mstore(
                        add(local_vars, C2_OFFSET),
                        addmod(
                            mload(add(local_vars, ALPHA_OFFSET)),
                            sub( mload(fri_params), mload(local_vars)),
                            mload(fri_params)
                        )
                    )
                }
                
                // Multiply coeffs
                for( local_vars.ind = 0; local_vars.ind < local_vars.mul;){
                    assembly{
                        mstore(mload(add(local_vars, COEFFS_OFFSET)), 
                            mulmod(
                                mload(mload(add(local_vars, COEFFS_OFFSET))),
                                mload(add(local_vars,C1_OFFSET)),
                                mload(fri_params)
                            )
                        )
                        mstore(add(local_vars, COEFFS_OFFSET), add(mload(add(local_vars, COEFFS_OFFSET)),0x20))
                    }
                    unchecked{local_vars.ind++;}
                }
                for( local_vars.ind = 0; local_vars.ind < local_vars.mul;){
                    assembly{
                        mstore(mload(add(local_vars, COEFFS_OFFSET)), 
                            mulmod(
                                mload(mload(add(local_vars, COEFFS_OFFSET))),
                                mload(add(local_vars,C2_OFFSET)),
                                mload(fri_params)
                            )
                        )
                        mstore(add(local_vars, COEFFS_OFFSET), add(mload(add(local_vars, COEFFS_OFFSET)),0x20))
                    }
                    unchecked{local_vars.ind++;}
                }
            }

            transcript.update_transcript_b32_by_offset_calldata(
                tr_state, 
                blob, 
                local_vars.round_proof_colinear_path_T_root_offset
            );

            // Prepare colinear values
            local_vars.colinear_path_offset = local_vars.round_proof_colinear_path_offset;
            round_local_vars(blob, offset, fri_params, local_vars);
            step_local_vars(blob, offset, fri_params, local_vars);

            // Calculate interpolant
            //local_vars.p_offset = basic_marshalling.skip_length(local_vars.round_proof_values_offset);
            local_vars.colinear_offset = local_vars.round_proof_values_offset + 0x10;
            if(local_vars.prev_step == 1 ){
                if(local_vars.i_step == 1){
                    //local_vars.colinear_offset = local_vars.p_offset + 0x8;
                    local_vars.y_offset -= 0x8;
                    for( local_vars.p_ind = 0; local_vars.p_ind < fri_params.leaf_size;){
                        local_vars.interpolant = field.fadd( 
                            field.fmul(
                                fri_params.coeffs[0], 
                                get_evaluated_y_from_blob(blob, fri_params, local_vars, local_vars.y_offset, local_vars.p_ind, 0),
                                fri_params.modulus
                            ),
                            field.fmul(
                                fri_params.coeffs[1], 
                                get_evaluated_y_from_blob(blob, fri_params, local_vars, local_vars.y_offset, local_vars.p_ind, 1),
                                fri_params.modulus
                            ),
                            fri_params.modulus
                        );
                        assembly{
                            c := calldataload(add(blob.offset, mload(add(local_vars, COLINEAR_OFFSET))))
                            c := mulmod(mload(add(local_vars, X_OFFSET)), c, mload(fri_params))
                            c := addmod(c, c, mload(fri_params))
                        }
                        if( local_vars.interpolant != c ){
                            return false;
                        }
                        //require(false, "First polynomial check is well");
                        unchecked{
                            local_vars.p_ind++;
                            local_vars.y_offset += local_vars.prev_polynomial_vector_size;
                            local_vars.colinear_offset += local_vars.polynomial_vector_size;
                        }
                    }
                } else {
                    //local_vars.y_offset = local_vars.prev_p_offset + 0x8; 
                    for( local_vars.p_ind = 0; local_vars.p_ind < fri_params.leaf_size;){
                        assembly{
                            mstore(add(local_vars,INTERPOLANT_OFFSET), addmod(
                                mulmod(
                                    mload(mload(add(local_vars, COEFFS_OFFSET))),
                                    calldataload(add(blob.offset, mload(add(local_vars,Y_OFFSET)))),
                                    mload(fri_params)
                                ),
                                mulmod(
                                    mload(add(mload(add(local_vars, COEFFS_OFFSET)), 0x20)),
                                    calldataload(add(blob.offset, add(mload(add(local_vars,Y_OFFSET)), 0x20))),
                                    mload(fri_params)
                                ),
                                mload(fri_params)
                            ))
                            c := calldataload(add(blob.offset, mload(add(local_vars, COLINEAR_OFFSET))))
                            c := mulmod(mload(add(local_vars, X_OFFSET)), c, mload(fri_params))
                            c := addmod(c, c, mload(fri_params))
                            mstore(add(local_vars, Y_OFFSET),      add( mload(add(local_vars, Y_OFFSET)), 0x48))
                        }
                        if( local_vars.interpolant != c ){
                            require(false, "Interpolant failes");
                            return false;
                        }
                        unchecked{
                            local_vars.p_ind++;
                            local_vars.colinear_offset += local_vars.polynomial_vector_size;
                        }
                    }
                }
            } else {
                if(local_vars.i_step == 1){
                    //local_vars.y_offset = local_vars.prev_p_offset;
                    local_vars.y_offset -= 0x8;
                    for( local_vars.p_ind = 0; local_vars.p_ind < fri_params.leaf_size;){
                        local_vars.interpolant = 0;
                        for( local_vars.y_ind = 0; local_vars.y_ind < local_vars.prev_coeffs_len; ) {
                            local_vars.interpolant = field.fadd( 
                                local_vars.interpolant, 
                                field.fmul(
                                    fri_params.coeffs[local_vars.y_ind], 
                                    get_evaluated_y_from_blob(blob, fri_params, local_vars, local_vars.y_offset, local_vars.p_ind, local_vars.y_ind),
                                    fri_params.modulus
                                ),
                                fri_params.modulus
                            );
                            unchecked{ local_vars.y_ind++;}
                        } 
                        assembly{
                            c := calldataload(add(blob.offset, mload(add(local_vars, COLINEAR_OFFSET))))
                            c := mulmod(mload(add(local_vars, X_OFFSET)), c, mload(fri_params))
                            c := mulmod(c, mload(add(local_vars,PREV_COEFFS_LEN_OFFSET)), mload(fri_params))
                        }
                        if( local_vars.interpolant != c ){
                            require(false, "Interpolant failes");
                            return false;
                        }
                        unchecked{
                            local_vars.p_ind++;
                            local_vars.y_offset += local_vars.prev_polynomial_vector_size;
                            local_vars.colinear_offset += local_vars.polynomial_vector_size;
                        }
                    }
                } else {
                    //local_vars.y_offset = local_vars.prev_p_offset + 0x8;
                    for( local_vars.p_ind = 0; local_vars.p_ind < fri_params.leaf_size;){
                        local_vars.interpolant = 0;
                        assembly{
                            mstore(add(local_vars, COEFFS_OFFSET), add(mload(add(fri_params, FRI_PARAMS_COEFFS_OFFSET)), 0x20))
                        }    
                        for( local_vars.y_ind = 0; local_vars.y_ind < local_vars.prev_coeffs_len; ) {
                            assembly{
                                mstore(add(local_vars, INTERPOLANT_OFFSET), addmod(
                                    mload(add(local_vars, INTERPOLANT_OFFSET)),
                                    mulmod(
                                        mload(mload(add(local_vars, COEFFS_OFFSET))),
                                        calldataload(add(blob.offset, mload(add(local_vars, Y_OFFSET)))),
                                        mload(fri_params)
                                    ),
                                    mload(fri_params)
                                ))
                                mstore(add(local_vars, COEFFS_OFFSET), add(mload(add(local_vars, COEFFS_OFFSET)),0x20))
                                mstore(add(local_vars, Y_OFFSET),      add( mload(add(local_vars, Y_OFFSET)), 0x20))
                            }
                            unchecked{ local_vars.y_ind++;}
                        }
                        assembly{
                            c := calldataload(add(blob.offset, mload(add(local_vars, COLINEAR_OFFSET))))
                            c := mulmod(mload(add(local_vars, X_OFFSET)), c, mload(fri_params))
                            c := mulmod(c, mload(add(local_vars,PREV_COEFFS_LEN_OFFSET)), mload(fri_params))
                            mstore(add(local_vars, Y_OFFSET),      add( mload(add(local_vars, Y_OFFSET)), 0x8))
                        }
                        if( local_vars.interpolant != c ){
                            require(false, logging.uint2decstr(local_vars.prev_coeffs_len));
                            require(false, "Interpolant failes");
                            return false;
                        }
                        unchecked{
                            local_vars.p_ind++;
                            local_vars.colinear_offset += local_vars.polynomial_vector_size;
                        }
                    }
                    assembly{
                        mstore(add(local_vars, COEFFS_OFFSET), add(mload(add(fri_params, FRI_PARAMS_COEFFS_OFFSET)), 0x20))
                    }    
                }
            }

            prepare_leaf_data(blob, fri_params, local_vars);
            if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                blob, 
                local_vars.colinear_path_offset, 
                fri_params.b, local_vars.b_length)
            ) {
                require(false, "Round_proof.colinear_path verifier failes");
                return false;
            }
        }

        require(fri_params.leaf_size == basic_marshalling.get_length(blob, local_vars.final_poly_offset),
            "Final poly array size is not equal to params.leaf_size!");
        local_vars.final_poly_offset = basic_marshalling.skip_length(local_vars.final_poly_offset);
        local_vars.p_offset = basic_marshalling.skip_length(local_vars.round_proof_values_offset);
        for (local_vars.p_ind = 0; local_vars.p_ind < fri_params.leaf_size;) {
             if (basic_marshalling.get_length(blob, local_vars.final_poly_offset) >
                (( 1 << (field.log2(fri_params.max_degree + 1) - fri_params.r + 1) ) )) {
                require(false, "Max degree problem");
                return false;
            }
            if( polynomial.evaluate_by_ptr(
                blob,
                local_vars.final_poly_offset + basic_marshalling.LENGTH_OCTETS,
                basic_marshalling.get_length(blob, local_vars.final_poly_offset),
                local_vars.x,
                fri_params.modulus
            ) != get_y_from_blob(blob, local_vars.p_offset, 0)){
                require(false, "Final polynomial check failed");
                return false;
            }
            local_vars.final_poly_offset = basic_marshalling.skip_vector_of_uint256_be(blob, local_vars.final_poly_offset);
            unchecked{ local_vars.p_ind++; local_vars.p_offset += local_vars.polynomial_vector_size;}
        }
        logging.profiling_end_block();
        return true;
    }
}