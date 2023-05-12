// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2021 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2021 Ilias Khairullin <ilias@nil.foundation>
// Copyright (c) 2022 Aleksei Moskvin <alalmoskvin@nil.foundation>
// Copyright (c) 2022 Elena Tatuzova <e.tatuzova@nil.foundation>
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
import "../algebra/polynomial.sol";
import "../basic_marshalling.sol";


library batched_fri_verifier {
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

    function skip_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // fri_roots
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        for (uint256 i = 0; i < value_len;) {
            result_offset = basic_marshalling.skip_octet_vector_32_be(result_offset);
            unchecked{ i++; }
        }
        // final_polynomial
        result_offset = basic_marshalling.skip_vector_of_uint256_be(blob, result_offset);
        // query_proofs
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        for (uint256 i = 0; i < value_len;) {
            result_offset = skip_query_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function parse_proof_be(types.fri_params_type memory fri_params, bytes calldata blob, uint256 offset)
    internal pure returns (bool success, uint256 result_offset) {
        success = true;
        // fri_roots
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        if( value_len != fri_params.step_list.length ){
            success = false;
            return(success, result_offset);
        }
        fri_params.fri_roots = new uint256[](value_len);
        for (uint256 i = 0; i < value_len;) {
            fri_params.fri_roots[i] = basic_marshalling.get_uint256_be(blob, basic_marshalling.skip_length(result_offset));
            result_offset = basic_marshalling.skip_octet_vector_32_be(result_offset);
            unchecked{ i++; }
        }
        // final_polynomial
        fri_params.fri_final_poly_offset = result_offset;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);

        if( value_len > (( 1 << (field.log2(fri_params.max_degree + 1) - fri_params.r + 1) ) ) ){
            success = false;
            return(success, result_offset);
        }

        fri_params.final_polynomial = new uint256[](value_len);
        for (uint256 i = 0; i < value_len;) {
            fri_params.final_polynomial[i] = basic_marshalling.get_uint256_be(blob, result_offset);
            result_offset = basic_marshalling.skip_uint256_be(result_offset);
            unchecked{ i++; }
        }

        // query_proofs
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        fri_params.fri_cur_query_offset = result_offset;
        if( value_len != fri_params.lambda ) {
            success = false;
            return(success, result_offset);
        }

        for (uint256 i = 0; i < value_len;) {
            (success, result_offset) = parse_query_proof_be(fri_params, blob, result_offset);
            if(!success) return(success, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_query_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset){
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        for(uint256 i = 0; i < value_len;){
            result_offset = skip_initial_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        for(uint256 i = 0; i < value_len;){
            result_offset = skip_round_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function parse_query_proof_be(types.fri_params_type memory fri_params, bytes calldata blob, uint256 offset)
    internal pure returns (bool success, uint256 result_offset){
        success = true;
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        if( value_len != fri_params.batches_sizes.length ){
            success = false;
            return( success, result_offset);
        }

        for(uint256 i = 0; i < value_len;){
            (success, result_offset) = parse_initial_proof_be(fri_params, i, blob, result_offset);
            if( !success ) return(success, result_offset );
            unchecked{ i++; }
        }
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        if( value_len != fri_params.step_list.length){
            success = false;
            return( success, result_offset);
        }
        for(uint256 i = 0; i < value_len;){
            (success, result_offset) = parse_round_proof_be(fri_params, i, blob, result_offset);
            if( !success ) return(success, result_offset );
            unchecked{ i++; }
        }
    }

    function skip_initial_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns(uint256 result_offset){
        // p;
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // polynomials num
        result_offset = basic_marshalling.skip_length(result_offset);
        // coset_size
        result_offset = basic_marshalling.skip_length(result_offset);
        result_offset = basic_marshalling.skip_vector_of_uint256_be(blob, result_offset);
    }

    function parse_initial_proof_be(types.fri_params_type memory fri_params, uint256 i, bytes calldata blob, uint256 offset)
    internal pure returns(bool success, uint256 result_offset){
        success = true;
        // p;
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // polynomials num
        uint256 len;
        (len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        if( len != fri_params.batches_sizes[i] ) {
            success = false;
            return(success, result_offset);
        }
        // coset_size
        (len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        if( len != (1 << fri_params.step_list[0]) ) {
            success = false;
            return(success, result_offset);
        }
        // values
        len = basic_marshalling.get_length(blob, result_offset);
        result_offset = basic_marshalling.skip_vector_of_uint256_be(blob, result_offset);
        if(len != fri_params.batches_sizes[i] * (1 << fri_params.step_list[0])){
            success = false;
            return(success, result_offset);
        }
    }

    function skip_round_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns(uint256 result_offset){
        // p;
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // y;
        result_offset = basic_marshalling.skip_vector_of_uint256_be(blob, result_offset);
    }

    function parse_round_proof_be(types.fri_params_type memory fri_params, uint256 i, bytes calldata blob, uint256 offset)
    internal pure returns(bool success, uint256 result_offset){
        success = true;
        // p;
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // y;
        if( i < fri_params.step_list.length - 1){
            if( basic_marshalling.get_length(blob, result_offset) != (1 << fri_params.step_list[i+1]) ){
                success = false;
                return(success, result_offset);
            }
        }else{
            if( basic_marshalling.get_length(blob, result_offset) != 2 ){
                success = false;
                return( success, result_offset);
            }
        }
        result_offset = basic_marshalling.skip_vector_of_uint256_be(blob, result_offset);
    }

    // Use this hack only for lpc test(!)
    // Call this function only after fri_params is completely initialized by parse* functions.
    function extract_merkle_roots(bytes calldata blob, types.fri_params_type memory fri_params) 
    internal pure returns(uint256[] memory roots){
        roots = new uint256[](fri_params.batches_num);
        uint256 offset = fri_params.fri_cur_query_offset;
        offset = basic_marshalling.skip_length(offset);
        for( uint256 i = 0; i < fri_params.batches_num;){
            roots[i] = merkle_verifier.get_merkle_root_from_proof(blob, offset);
            offset = skip_initial_proof_be(blob, offset);
            unchecked{ i++; }
        }
    }

    // if x_index is index of x, then paired_index is index of -x
    function get_paired_index(uint256 x_index, uint256 domain_size)
    internal pure returns(uint256 result ){
        unchecked{ result = (x_index + (domain_size >> 1)) & (domain_size - 1); }
    }

    // calculate indices for coset S = {s\in D| s^(2^fri_step) == x_next}
    function get_folded_index(uint256 x_index, uint256 fri_step, uint256 domain_size_mod) 
    internal pure returns(uint256 result){
        unchecked{result = x_index & (domain_size_mod >> fri_step);}
    }
  
    function calculate_s(
        types.fri_params_type memory fri_params,
        types.fri_state_type memory local_vars) internal pure{

        fri_params.s[0] = local_vars.x;
        if( local_vars.coset_size > 1){
            uint256 base_index = local_vars.domain_size >> 2; 
            uint256 prev_half_size = 1;
            uint256 i = 1;
            uint256 j;
            local_vars.newind = fri_params.D_omegas.length - 1;
            while( i < local_vars.coset_size ){
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

    function prepare_initial_leaf_data(
        bytes calldata blob,
        uint256 offset,
        uint256 k,                                              // current batch index
        types.fri_params_type memory fri_params,
        types.fri_state_type memory local_vars
    ) internal pure {
        uint256 base_index;
        uint256 prev_half_size;
        uint256 i;
        uint256 j;

        local_vars.indices_size = 1 << (fri_params.step_list[0] - 1);
        
        fri_params.s_indices[0] = local_vars.x_index;
        fri_params.s[0] = local_vars.x;
        fri_params.tmp_arr[0] = get_folded_index(local_vars.x_index, fri_params.step_list[0], local_vars.domain_size_mod);

        // Fill s and s_indices
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
                        fri_params.tmp_arr[i]   = (base_index + fri_params.tmp_arr[j]) & local_vars.domain_size_mod;
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

        // Fill correct_order_idx
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

        offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        offset = basic_marshalling.skip_length(offset);             // Skip polynomial number
        offset = basic_marshalling.skip_length(offset);             // Skip coset size
        offset = basic_marshalling.skip_length(offset);             // Skip y length
        for (local_vars.p_ind = 0; local_vars.p_ind < fri_params.batches_sizes[k];) {
            for(local_vars.y_ind = 0; local_vars.y_ind < local_vars.indices_size;){
                local_vars.newind = fri_params.correct_order_idx[local_vars.y_ind];
                // Check leaf size
                // Prepare y-s
                unchecked{ y_offset = offset + ( local_vars.newind << 6 ); }

                // push y
                if(fri_params.s_indices[local_vars.newind] == fri_params.tmp_arr[local_vars.y_ind]){
                    assembly{
                        mstore(
                            add(mload(local_vars),first_offset), 
                            calldataload(add(blob.offset, y_offset))
                        )
                        mstore(
                            add(mload(local_vars),add(first_offset, 0x20)), 
                            calldataload(add(blob.offset, add(y_offset, 0x20)))
                        )
                    }
                } else {
                    assembly{
                        mstore(
                            add(mload(local_vars),first_offset), 
                            calldataload(add(blob.offset, add(y_offset, 0x20)))
                        )
                        mstore(
                            add(mload(local_vars),add(first_offset, 0x20)), 
                            calldataload(add(blob.offset, y_offset))
                        )
                    }
                }
                unchecked{ 
                    local_vars.y_ind++; 
                    first_offset += 0x40;
                }
            }
            unchecked{ offset += (1<<(fri_params.step_list[0]+5)); local_vars.p_ind++; }
        }
    }

    // For round proofs
    //     Reorder local_vars.values and push to local_vars.b
    function prepare_leaf_data(
        bytes calldata blob,
        uint256 offset,                                         // round proof offset
        types.fri_params_type memory fri_params,
        types.fri_state_type memory local_vars
    ) internal pure {
        uint256 base_index;
        uint256 prev_half_size;
        uint256 i;
        uint256 j;

        local_vars.indices_size = 1 << (fri_params.step_list[local_vars.step] - 1);
        
        fri_params.s_indices[0] = local_vars.x_index;
        fri_params.s[0] = local_vars.x;
        fri_params.tmp_arr[0] = get_folded_index(local_vars.x_index, fri_params.step_list[local_vars.step], local_vars.domain_size_mod);

        // Fill s and s_indices
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
                        fri_params.tmp_arr[i]   = (base_index + fri_params.tmp_arr[j]) & local_vars.domain_size_mod;
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

        // Fill correct_order_idx
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

        uint256 y;
        offset = 0x20;
        for(local_vars.y_ind = 0; local_vars.y_ind < local_vars.indices_size;){
            local_vars.newind = fri_params.correct_order_idx[local_vars.y_ind];
            // Check leaf size
            // Prepare y-s

            // push y
            if(fri_params.s_indices[local_vars.newind] == fri_params.tmp_arr[local_vars.y_ind]){
                y = local_vars.values[local_vars.newind<<1];
                assembly{
                    mstore(
                        add(mload(local_vars), offset), y
                    )
                }
                y = local_vars.values[(local_vars.newind<<1)+1];
                assembly{
                    mstore(
                        add(mload(local_vars),add(offset, 0x20)), y
                    )
                }
            } else {
                y = local_vars.values[(local_vars.newind<<1)+1];
                assembly{
                    mstore(
                        add(mload(local_vars), offset), y
                    )
                }
                y = local_vars.values[local_vars.newind<<1];
                assembly{
                    mstore(
                        add(mload(local_vars),add(offset, 0x20)), y
                    )
                }
            }
            unchecked{ 
                local_vars.y_ind++; 
                offset += 0x40;
            }
        }
    }

    function clear_values( uint256[] memory values )
    internal pure{
        for( uint256 i = 0; i < values.length;){
            values[i] = 0;
            unchecked{ i++; }
        }
    }

    function load_values( bytes calldata blob, uint256 offset, types.fri_state_type memory local_vars )
    internal pure{
        uint256 len;
        (len, offset) = basic_marshalling.get_skip_length(blob, offset);
        for( uint256 i = 0; i < len;){
            local_vars.values[i] = basic_marshalling.get_uint256_be(blob, offset);
            offset = basic_marshalling.skip_uint256_be(offset);
            unchecked{i++;}
        }
    }

    function verify_proof_be(
        bytes calldata blob, 
        uint256[] memory roots,
        types.transcript_data memory tr_state,
        types.fri_params_type memory fri_params
    ) internal view returns (bool result) {
        types.fri_state_type memory local_vars;

        // TODO strange bug. If we we exchange two next lines, then it will not work.
        local_vars.alphas = new uint256[](fri_params.r);
        local_vars.b = new bytes(0x40 * fri_params.max_batch * fri_params.max_coset);

        uint256 offset;
        uint256 ind;
        uint256 k;
        uint256 i;

        offset = basic_marshalling.skip_length(fri_params.fri_proof_offset);
        offset = basic_marshalling.skip_length(offset);
        for( ind = 0; ind < fri_params.step_list.length;){
            transcript.update_transcript_b32_by_offset_calldata(tr_state, blob, offset);
            for( uint256 round = 0; round < fri_params.step_list[ind];){
                local_vars.alphas[local_vars.cur] = transcript.get_field_challenge(tr_state, fri_params.modulus);
                unchecked{ round++; local_vars.cur++;}
            }
            offset = basic_marshalling.skip_octet_vector_32_be(offset);
            unchecked{ind++;}
        }

        for( local_vars.query_id = 0; local_vars.query_id < fri_params.lambda;){
            // It'll be init_vars function next
            unchecked{ local_vars.domain_size = 1 << (fri_params.D_omegas.length + 1); }
            unchecked{ local_vars.domain_size_mod = local_vars.domain_size - 1; }
            local_vars.x_index = transcript.get_integral_challenge_be(tr_state, 8) & local_vars.domain_size_mod;
            local_vars.x = field.expmod_static(
                fri_params.D_omegas[0],
                local_vars.x_index,
                fri_params.modulus
            );

            // Check initial proofs
            offset = basic_marshalling.skip_length(fri_params.fri_cur_query_offset);
            for( k = 0; k < fri_params.batches_num;){
                // Check merkle local_vars.roots
                local_vars.root = merkle_verifier.get_merkle_root_from_proof(blob, offset);
                if( local_vars.root != roots[k] ){
                    return false;
                }
                prepare_initial_leaf_data(blob, offset, k, fri_params, local_vars);
                local_vars.b_length = (fri_params.batches_sizes[k] << (fri_params.step_list[0] +5));
                if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                    blob, offset, local_vars.b, local_vars.b_length
                )) {
                    return false;
                }
                offset = skip_initial_proof_be(blob, offset);
                // Check merkle proofs
                unchecked{k++;}
            }

            // Construct ys for the first round
            local_vars.coset_size = 1 << fri_params.step_list[0];
            local_vars.values = new uint256[](1 << fri_params.max_step);
            local_vars.tmp_values = new uint256[](1 << fri_params.max_step);

            for( ind = 0; ind < fri_params.different_points;){                
                offset = basic_marshalling.skip_length(fri_params.fri_cur_query_offset);
                offset = merkle_verifier.skip_merkle_proof_be(blob,offset);
                offset = basic_marshalling.skip_length(offset);
                offset = basic_marshalling.skip_length(offset);
                offset = basic_marshalling.skip_length(offset);
                clear_values(local_vars.tmp_values);
                local_vars.cur = 0;
                for( k = 0; k < fri_params.batches_num;){
                    for( i = 0; i < fri_params.batches_sizes[k];){
                        polynomial.multiply_poly_on_coeff(local_vars.tmp_values,fri_params.theta, fri_params.modulus);
                        if( fri_params.eval_map[local_vars.cur] == ind ){
                            for( uint256 j = 0; j < local_vars.coset_size;){
                                local_vars.tmp_values[j] = addmod(
                                    local_vars.tmp_values[j], 
                                    basic_marshalling.get_uint256_be(blob, offset),
                                    fri_params.modulus
                                );
                                offset = basic_marshalling.skip_uint256_be(offset);
                                unchecked{ j++; }
                            }
                        } else {
                            offset += (local_vars.coset_size << 5);
                        }
                        unchecked{ i++; local_vars.cur++;} 
                    }
                    offset = merkle_verifier.skip_merkle_proof_be(blob,offset);
                    offset = basic_marshalling.skip_length(offset);
                    offset = basic_marshalling.skip_length(offset);
                    offset = basic_marshalling.skip_length(offset);
                    unchecked{ k++; }
                }

                for( uint256 j = 0; j < local_vars.coset_size; j++){
                    if( j & 1 == 0 )
                        { local_vars.s = fri_params.s[j>>1];}
                    else
                        { local_vars.s = fri_params.modulus - fri_params.s[j>>1];}
                    local_vars.tmp_values[j] = addmod(
                        mulmod( local_vars.tmp_values[j], fri_params.factors[ind], fri_params.modulus),
                        fri_params.modulus - polynomial.evaluate(fri_params.combined_U[ind], local_vars.s, fri_params.modulus),
                        fri_params.modulus
                    );
                    // TODO Denominators for all s can be precomputed. It doesn't depend on polynomial.
                    local_vars.tmp_values[j] = mulmod(
                        local_vars.tmp_values[j],
                        field.inverse_static(
                            polynomial.evaluate(fri_params.denominators[ind], local_vars.s, fri_params.modulus),
                            fri_params.modulus
                        ),
                        fri_params.modulus
                    );
                    local_vars.values[j] = addmod(local_vars.values[j], local_vars.tmp_values[j], fri_params.modulus);
                }
                unchecked{ind++;}
            }

            offset = basic_marshalling.skip_length(fri_params.fri_cur_query_offset);
            for( k = 0; k < fri_params.batches_num; ){
                offset = skip_initial_proof_be(blob, offset);
                unchecked{k++;}
            }

            // Round proofs check
            local_vars.cur = 0;
            offset = basic_marshalling.skip_length(offset);

            for( local_vars.step = 0; local_vars.step < fri_params.step_list.length;){
                // Merkle check;
                local_vars.fri_root = basic_marshalling.get_uint256_be(blob, basic_marshalling.skip_length(offset) + 0x8);
                if( local_vars.fri_root != fri_params.fri_roots[local_vars.step]) {
                    return false;
                }

                local_vars.coset_size = 1 << fri_params.step_list[local_vars.step];
                prepare_leaf_data(blob, offset, fri_params, local_vars);
                local_vars.b_length = (1 << (fri_params.step_list[local_vars.step] + 5));
                if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                    blob, offset, local_vars.b, local_vars.b_length
                )) {
                    return false;
                }

                // Colinear check;
                local_vars.factor = 1;
                for( local_vars.round = 0; local_vars.round < fri_params.step_list[local_vars.step];){
                    local_vars.coset_size >>= 1;
                    calculate_s(fri_params, local_vars);
                    local_vars.domain_size >>= 1;
                    local_vars.domain_size_mod >>= 1;
                    local_vars.x_index &= local_vars.domain_size_mod;
                    local_vars.x = mulmod(local_vars.x, local_vars.x, fri_params.modulus);
                    if( local_vars.round == 0){
                        for( uint256 j = 0; j < local_vars.coset_size;){
                            local_vars.f0 = local_vars.values[j<<1];
                            local_vars.f1 = local_vars.values[(j<<1) + 1];
                            local_vars.values[j] = addmod(local_vars.f0, local_vars.f1, fri_params.modulus);
                            local_vars.values[j] = mulmod(local_vars.values[j], fri_params.s[j], fri_params.modulus);
                            local_vars.values[j] = addmod(
                                local_vars.values[j], 
                                mulmod(
                                    local_vars.alphas[local_vars.cur],
                                    addmod(local_vars.f0, fri_params.modulus-local_vars.f1, fri_params.modulus), 
                                    fri_params.modulus
                                ),
                                fri_params.modulus
                            );
                            local_vars.values[j] = mulmod(
                                local_vars.values[j], 
                                fri_params.s[j],
                                fri_params.modulus
                            );
                            unchecked{ j++; }
                        }
                        local_vars.factor = mulmod(local_vars.factor, 2, fri_params.modulus);
                    } else {
                        for( uint256 j = 0; j < local_vars.coset_size;){
                            local_vars.f0 = local_vars.values[j<<1];
                            local_vars.f1 = local_vars.values[(j<<1) + 1];
                            local_vars.values[j] = addmod(local_vars.f0, fri_params.modulus - local_vars.f1, fri_params.modulus);
                            local_vars.values[j] = mulmod(local_vars.values[j], fri_params.s[j], fri_params.modulus);
                            local_vars.values[j] = addmod(
                                local_vars.values[j], 
                                mulmod(
                                    local_vars.alphas[local_vars.cur],
                                    addmod(local_vars.f0, local_vars.f1, fri_params.modulus), 
                                    fri_params.modulus
                                ),
                                fri_params.modulus
                            );
                            unchecked{ j++; }
                        }
                        local_vars.factor = mulmod(local_vars.factor, 2, fri_params.modulus);
                    }
                    unchecked{local_vars.round++; local_vars.cur++;}
                }
                local_vars.factor = mulmod(local_vars.factor, fri_params.s[0], fri_params.modulus);
                local_vars.factor = mulmod(local_vars.factor, fri_params.s[0], fri_params.modulus);
                local_vars.interpolant = local_vars.values[0];

                offset = merkle_verifier.skip_merkle_proof_be(blob,offset);
                load_values(blob, offset, local_vars);
                if( local_vars.interpolant != mulmod(local_vars.factor, local_vars.values[0], fri_params.modulus) ){
                    return false;
                }
                offset = basic_marshalling.skip_vector_of_uint256_be(blob, offset);
                unchecked{local_vars.step++;}
            }

            // Final polynomial check. Final polynomial degree is already checked while parsing process
            if( polynomial.evaluate(fri_params.final_polynomial, local_vars.x, fri_params.modulus) != local_vars.values[0]){
                return false;
            }
            if( polynomial.evaluate(fri_params.final_polynomial, fri_params.modulus-local_vars.x, fri_params.modulus) != local_vars.values[1]){
                return false;
            }
            
            fri_params.fri_cur_query_offset = skip_query_proof_be(blob, fri_params.fri_cur_query_offset);
            unchecked{local_vars.query_id++;}
        }
        return true;
    }
}