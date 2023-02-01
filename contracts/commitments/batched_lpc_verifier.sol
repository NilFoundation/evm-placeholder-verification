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
import "./batched_fri_verifier.sol";
import "../algebra/polynomial.sol";
import "../basic_marshalling.sol";
import "../profiling.sol";

library batched_lpc_verifier {

    uint256 constant m = 2;

    function skip_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        uint256 i;
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, offset);
        // z
        result_offset = basic_marshalling.skip_length(result_offset);
        for (i = 0; i < 4;) {
            result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be_check(blob, result_offset);
            unchecked{i++;}
        }
        // fri_proof
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length_check(blob, result_offset);

        for (i = 0; i < value_len;) {
            // TODO realized FRI::skip_proof_be checked better
            result_offset = batched_fri_verifier.skip_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_vector_of_proofs_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset){
        uint256 value_len;
        uint256 i;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        for (i = 0; i < value_len;) {
            result_offset = skip_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_n_proofs_in_vector_be(bytes calldata blob, uint256 offset, uint256 n)
    internal pure returns (uint256 result_offset) {
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        for (uint256 i = 0; i < n; ) {
            result_offset = skip_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_to_first_fri_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        // z
        result_offset = basic_marshalling.skip_length(result_offset);
        result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, result_offset);
        result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, result_offset);
        result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, result_offset);
        result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, result_offset);

        // fri_proof
        result_offset = basic_marshalling.skip_length(result_offset);
    }

    // Input is proof_map.eval_proof_combined_value_offset
    function get_variable_values_z_i_j_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j) 
    internal pure returns (uint256 z_i_j){
        uint256 vv_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        vv_offset = basic_marshalling.skip_length(vv_offset);

        z_i_j = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(
            blob, vv_offset, i, j
        );
    }

    function get_permutation_z_i_j_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j) 
    internal pure returns (uint256 z_i_j){
        uint256 p_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        p_offset = basic_marshalling.skip_length(p_offset);
        
        p_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, p_offset);
        z_i_j = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(
            blob, p_offset, i, j
        );
    }

    function get_quotient_z_i_j_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j) 
    internal pure returns (uint256 z_i_j){
        uint256 q_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        q_offset = basic_marshalling.skip_length(q_offset);
        
        q_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, q_offset);
        q_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, q_offset);
        z_i_j = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(
            blob, q_offset, i, j
        );
    }

    // TODO add starting offsets of eval arrays to some kind of proof map
    function get_fixed_values_z_i_j_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j) 
    internal pure returns (uint256 z_i_j){
        uint256 fv_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        fv_offset = basic_marshalling.skip_length(fv_offset);
        
        fv_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, fv_offset);
        fv_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, fv_offset);
        fv_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, fv_offset);
        z_i_j = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(
            blob, fv_offset, i, j
        );
    }
/*    function get_z_i_j_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j)
    internal pure returns (uint256 z_i_j) {
        // 0x28 (skip T_root)
        z_i_j = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(
            blob,
            basic_marshalling.skip_octet_vector_32_be(offset),
            i,
            j);
    }*/
/*
    function get_z_i_j_ptr_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j)
    internal pure returns (uint256 z_i_j_ptr) {
        // 0x28 (skip T_root)
        z_i_j_ptr = basic_marshalling.get_i_j_uint256_ptr_from_vector_of_vectors(blob, basic_marshalling.skip_octet_vector_32_be(offset), i, j);
    }
*/
/*
    function get_z_n_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 n) {
        // T_root
        uint256 result_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        // z
        n = basic_marshalling.get_length(blob, result_offset);
    }
*/
    function get_variable_values_n_be(bytes calldata blob, uint256 offset)
    internal pure returns(uint256 n){
        uint256 vv_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        vv_offset = basic_marshalling.skip_length(vv_offset);

        n = basic_marshalling.get_length(blob, vv_offset);
    }

    function get_permutation_z_n_be(bytes calldata blob, uint256 offset) 
    internal pure returns (uint256 n){
        uint256 p_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        p_offset = basic_marshalling.skip_length(p_offset);
        
        p_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, p_offset);
        n = basic_marshalling.get_length(blob, p_offset);
    }

    function get_quotient_z_n_be(bytes calldata blob, uint256 offset) 
    internal pure returns (uint256 n){
        uint256 q_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        q_offset = basic_marshalling.skip_length(q_offset);
        
        q_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, q_offset);
        q_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, q_offset);
        n = basic_marshalling.get_length(blob, q_offset);
    }

    function get_fixed_values_z_n_be(bytes calldata blob, uint256 offset) 
    internal pure returns (uint256 n){
        uint256 fv_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        fv_offset = basic_marshalling.skip_length(fv_offset);
        
        fv_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, fv_offset);
        fv_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, fv_offset);
        fv_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, fv_offset);
        n = basic_marshalling.get_length(blob, fv_offset);
    }
    function get_fri_proof_n_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 n) {
        uint256 i;
        // T_root
        offset = basic_marshalling.skip_octet_vector_32_be_check(blob, offset);
        // z
        offset = basic_marshalling.skip_length(offset);
        for (i = 0; i < 4;) {
            offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be_check(blob, offset);
            unchecked{i++;}
        }
        // fri_proof
        n = basic_marshalling.get_length(blob, offset);
    }

    function skip_proof_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        uint256 i;
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, offset);
        // z
        result_offset = basic_marshalling.skip_length(result_offset);
        for (i = 0; i < 4;) {
            result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be_check(blob, result_offset);
            unchecked{i++;}
        }
        // fri_proof
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length_check(blob, result_offset);

        for (i = 0; i < value_len;) {
            // TODO realized FRI::skip_proof_be checked better
            result_offset = batched_fri_verifier.skip_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_vector_of_proofs_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        uint256 value_len;
        uint256 i;
        (value_len, result_offset) = basic_marshalling.get_skip_length_check(blob, offset);
        for ( i = 0; i < value_len;) {
            result_offset = skip_proof_be_check(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_n_proofs_in_vector_be_check(bytes calldata blob, uint256 offset, uint256 n)
    internal pure returns (uint256 result_offset) {
        uint256 value_len;
        uint256 i;
        (value_len, result_offset) = basic_marshalling.get_skip_length_check(blob, offset);
        require(n <= value_len);
        for (i = 0; i < n;) {
            result_offset = skip_proof_be_check(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_to_z(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be(offset);
    }

    function get_z_i_j_from_proof_be_check(bytes calldata blob, uint256 offset, uint256 i, uint256 j)
    internal pure returns (uint256 z_i_j) {
        // 0x28 (skip T_root)
        z_i_j = basic_marshalling
                .get_i_j_uint256_from_vector_of_vectors_check(blob,
                basic_marshalling.skip_octet_vector_32_be_check(blob, offset), i, j);
    }

    function get_z_i_j_ptr_from_proof_be_check(bytes calldata blob, uint256 offset, uint256 i, uint256 j)
    internal pure returns (uint256 z_i_j_ptr) {
        // 0x28 (skip T_root)
        z_i_j_ptr = basic_marshalling
            .get_i_j_uint256_ptr_from_vector_of_vectors_check(blob,
            basic_marshalling.skip_octet_vector_32_be_check(blob, offset), i, j);
    }

    uint256 constant PRECOMPUTE_EVAL3_SIZE = 5;
    function parse_verify_proof_be(bytes calldata blob,
        uint256 offset, 
        types.transcript_data memory tr_state, 
        types.fri_params_type memory fri_params)
    internal returns (bool result) {
        profiling.start_block("LPC::parse_verify_proof_be");
        uint256 ind;
        uint256 combined_alpha = transcript.get_field_challenge(tr_state, fri_params.modulus);

        fri_params.z_offset = basic_marshalling.skip_octet_vector_32_be(offset);

        profiling.start_block("LPC::FRI");
        offset = skip_to_first_fri_proof_be(blob, offset);
        for (ind = 0; ind < fri_params.lambda;) {
            fri_params.i_fri_proof = ind;  // for debug only
            fri_params.prev_xi = 0;
            if (!batched_fri_verifier.parse_verify_proof_be(blob, offset, tr_state, fri_params)) {
                require(false, "FRI verification failed");
                return false;
            }
            offset = batched_fri_verifier.skip_proof_be(blob, offset);
            unchecked{ ind++; }
        }
        result = true;
        profiling.end_block();
   }
}