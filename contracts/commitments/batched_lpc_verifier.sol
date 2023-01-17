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
import "./commitment_calc.sol";


library batched_lpc_verifier {

    uint256 constant m = 2;

    function skip_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        // z
        result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, result_offset);
        
        // fri_proof
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        for (uint256 i = 0; i < value_len;) {
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
        result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, result_offset);
        // fri_proof
        result_offset = basic_marshalling.skip_length(result_offset);
    }

    function get_z_i_j_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j)
    internal pure returns (uint256 z_i_j) {
        // 0x28 (skip T_root)
        z_i_j = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(
            blob,
            basic_marshalling.skip_octet_vector_32_be(offset),
            i,
            j);
    }

    function get_z_i_j_ptr_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j)
    internal pure returns (uint256 z_i_j_ptr) {
        // 0x28 (skip T_root)
        z_i_j_ptr = basic_marshalling.get_i_j_uint256_ptr_from_vector_of_vectors(blob, basic_marshalling.skip_octet_vector_32_be(offset), i, j);
    }

    function get_z_n_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 n) {
        // T_root
        uint256 result_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        // z
        n = basic_marshalling.get_length(blob, result_offset);
    }

    function get_fri_proof_n_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 n) {
        // T_root
        uint256 result_offset = basic_marshalling.skip_octet_vector_32_be(offset);
        // z
        result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, result_offset);
        // fri_proof
        n = basic_marshalling.get_length(blob, result_offset);
    }

    function skip_proof_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, offset);
        // z
        result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be_check(blob, result_offset);
        // fri_proof
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length_check(blob, result_offset);
        uint256 i;

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

    function eval4_to_eval(uint256[4] memory eval4) internal pure returns (uint256[] memory result){
        result = new uint256[](eval4[0]);
        for( uint256 i = 0; i < eval4[0];){
            result[i] = eval4[i+1];
            unchecked{ i++; }
        }
    }

    uint256 constant PRECOMPUTE_EVAL3_SIZE = 5;
    function parse_verify_proof_be(bytes calldata blob,
        uint256 offset, uint256[4][] memory evaluation_points,
        types.transcript_data memory tr_state, types.fri_params_type memory fri_params)
    internal returns (bool result) {
        profiling.start_block("LPC::parse_verify_proof_be");
        profiling.start_block("LPC::prepare U and V");
        result = false;

        fri_params.leaf_size = get_z_n_be(blob, offset);

        require(evaluation_points.length == 1 || fri_params.leaf_size == evaluation_points.length, "Array of evaluation points size is not equal to leaf_size!");
        require(fri_params.lambda == get_fri_proof_n_be(blob, offset), "Fri proofs number is not equal to lambda!");

        uint256 z_offset;
        uint256 polynom_index;
        uint256 point_index;
        uint256 ind;

        z_offset = basic_marshalling.skip_length(skip_to_z(blob, offset));
        if( fri_params.step_list[0] != 1){
            uint256[4] memory eval4;

            for (polynom_index = 0; polynom_index < fri_params.leaf_size;) {
                eval4 = evaluation_points.length == 1? evaluation_points[0]: evaluation_points[polynom_index];
                fri_params.batched_U[polynom_index] = polynomial.interpolate(
                    blob,
                    eval4_to_eval(eval4),
                    z_offset,
                    fri_params.modulus
                );
                z_offset = basic_marshalling.skip_vector_of_uint256_be(blob, z_offset);

                unchecked{ polynom_index++; }
            }

            // If there are similar points for all polynomials, don't recompute V
            for (polynom_index = 0; polynom_index < fri_params.leaf_size;) {
                if( evaluation_points.length == 1  && polynom_index !=0 )
                    fri_params.batched_V[polynom_index] = fri_params.batched_V[0];
                else{
                    eval4 = evaluation_points[polynom_index];
                    fri_params.batched_V[polynom_index] = new uint256[](1);
                    fri_params.batched_V[polynom_index][0] = 1;
                    for (point_index = 0; point_index < eval4[0];) {
                        fri_params.lpc_z[0] = fri_params.modulus - eval4[point_index+1];
                        fri_params.batched_V[polynom_index] = polynomial.mul_poly(
                            fri_params.batched_V[polynom_index],
                            fri_params.lpc_z,
                            fri_params.modulus
                        );
                        unchecked{ point_index++; }
                    }
                }
            unchecked{ polynom_index++; }
            }
        }  else {
            // Compute number of polynomials with 2 and 3 evaluation points
            uint256 eval3 = 1;
            uint256 eval2 = 1;
            bool found;

            for(point_index = 0; point_index < evaluation_points.length;){
                if( evaluation_points[point_index][0] == 3){
                    unchecked{eval3++;}
                } 
                if (evaluation_points[point_index][0] == 2){
                    unchecked{eval2++;}
                }
            unchecked{point_index++;}
            }
            fri_params.precomputed_indices = new uint256[](eval3+eval2);

            // Compute number of different sets of evaluation points
            if( eval3 != 0 ){
                for(point_index = 0; point_index < evaluation_points.length;){
                    if( evaluation_points[point_index][0] == 3){
                        found = false;
                        for(ind = 1; ind < fri_params.precomputed_indices[0] + 1;){
                            if( evaluation_points[fri_params.precomputed_indices[ind]][1] == evaluation_points[point_index][1] &&
                                evaluation_points[fri_params.precomputed_indices[ind]][2] == evaluation_points[point_index][2] &&
                                evaluation_points[fri_params.precomputed_indices[ind]][3] == evaluation_points[point_index][3] ){
                                found = true;
                                break;
                            }
                        unchecked{ind++;}
                        }
                        if( !found ){
                            unchecked{fri_params.precomputed_indices[0]++;}
                            fri_params.precomputed_indices[fri_params.precomputed_indices[0]] = point_index;
                        }
                    } 
                unchecked{point_index++;}
                }
                fri_params.precomputed_points = new uint256[5][](fri_params.precomputed_indices[0]);
                fri_params.precomputed_eval3_data = new uint256[9][](fri_params.precomputed_indices[0]);
                for(ind = 1; ind < fri_params.precomputed_indices[0] + 1;){
                    point_index = fri_params.precomputed_indices[ind];
                    fri_params.precomputed_points[point_index][0] = evaluation_points[point_index][0];
                    fri_params.precomputed_points[point_index][1] = evaluation_points[point_index][1];
                    fri_params.precomputed_points[point_index][2] = evaluation_points[point_index][2];
                    fri_params.precomputed_points[point_index][3] = evaluation_points[point_index][3];
                    fri_params.precomputed_points[point_index][4] = 0;
                unchecked{ind++;}
                }
            }
        }

        fri_params.evaluation_points = evaluation_points;
        fri_params.z_offset = basic_marshalling.skip_octet_vector_32_be(offset);

        profiling.end_block();
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
        profiling.end_block();
   }
}