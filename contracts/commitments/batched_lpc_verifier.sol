// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2021 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2021 Ilias Khairullin <ilias@nil.foundation>
// Copyright (c) 2022 Aleksei Moskvin <alalmoskvin@nil.foundation>
// Copyright (c) 2022-2023 Elena Tatuzova <e.tatuzova@nil.foundation>
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

library batched_lpc_verifier {

    uint256 constant m = 2;

    function skip_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        uint256 i;
        uint256 len;
        // z
        
        (len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        for( i = 0; i < len; ){
            result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be_check(blob, result_offset);
            unchecked{i++;}
        }
        // fri_proof
        result_offset = batched_fri_verifier.skip_proof_be(blob, result_offset);
    }

    // Check proof data carefully.
    // Load necessary offsets to fri params
    function parse_proof_be(types.fri_params_type memory fri_params, bytes calldata blob, uint256 offset)
    internal pure returns (bool success, uint256 result_offset) {
        success = true;
        uint256 len;
        // z
        (len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        if( len != fri_params.batches_sizes.length ){
            success = false;
            return (success, result_offset);
        }
        for( uint256 i = 0; i < len; ){
            if( fri_params.batches_sizes[i] == 0 ){
                fri_params.batches_sizes[i] = basic_marshalling.get_length(blob, result_offset);
            } else {
                if( basic_marshalling.get_length(blob, result_offset) != fri_params.batches_sizes[i]){
                    success = false;
                    return (success, result_offset);
                }
            }
            fri_params.poly_num += fri_params.batches_sizes[i];
            result_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be_check(blob, result_offset);
            unchecked{i++;}
        }
        // fri_proof
        fri_params.fri_proof_offset = result_offset;
        (success, result_offset) = batched_fri_verifier.parse_proof_be(fri_params, blob, result_offset);
    }

    // Input is proof_map.eval_proof_combined_value_offset
    function get_variable_values_z_i_j_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j) 
    internal pure returns (uint256 z_i_j){
        uint256 vv_offset = basic_marshalling.skip_length(offset);

        z_i_j = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(
            blob, vv_offset, i, j
        );
    }

    function get_permutation_z_i_j_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j) 
    internal pure returns (uint256 z_i_j){
        uint256 p_offset = basic_marshalling.skip_length(offset);
        
        p_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, p_offset);
        z_i_j = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(
            blob, p_offset, i, j
        );
    }

    function get_quotient_z_i_j_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j) 
    internal pure returns (uint256 z_i_j){
        uint256 q_offset = basic_marshalling.skip_length(offset);
        
        q_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, q_offset);
        q_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, q_offset);
        z_i_j = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(
            blob, q_offset, i, j
        );
    }

    // TODO add starting offsets of eval arrays to some kind of proof map
    function get_fixed_values_z_i_j_from_proof_be(bytes calldata blob, uint256 offset, uint256 i, uint256 j) 
    internal pure returns (uint256 z_i_j){
        uint256 fv_offset = basic_marshalling.skip_length(offset);
        
        fv_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, fv_offset);
        fv_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, fv_offset);
        fv_offset = basic_marshalling.skip_vector_of_vectors_of_uint256_be(blob, fv_offset);
        z_i_j = basic_marshalling.get_i_j_uint256_from_vector_of_vectors(
            blob, fv_offset, i, j
        );
    }

    function eval_points_eq(uint256[] memory p1, uint256[] memory p2 )
    internal pure returns(bool eq){
        eq = true;
        if (p1.length != p2.length) return false;
        for(uint256 i = 0; i < p1.length;){
            if(p1[i] != p2[i]) return false;
            unchecked{i++;}
        }
    }

    // Use this hack only for lpc test(!)
    // Call this function only after fri_params is completely initialized by parse* functions.
    function extract_merkle_roots(bytes calldata blob, types.fri_params_type memory fri_params) 
    internal pure returns (uint256[] memory roots){
        return batched_fri_verifier.extract_merkle_roots(blob, fri_params);
    }

    function calculate_2points_interpolation(uint256[] memory xi, uint256[2] memory z, uint256 modulus)
    internal pure returns(uint256[2] memory U){
//        require( xi.length == 2 );
        U[0] = addmod(mulmod(z[0], xi[1], modulus),modulus - mulmod(z[1], xi[0], modulus), modulus);
        U[1] = addmod(z[1], modulus - z[0], modulus);
    }

//  coeffs for zs on each degree can be precomputed if necessary
    function calculate_3points_interpolation(uint256[] memory xi, uint256[3] memory z, uint256 modulus)
    internal pure returns(uint256[3] memory U){
//        require( xi.length == 3 );
        z[0] = mulmod(z[0], addmod(xi[1], modulus - xi[2], modulus), modulus);
        z[1] = mulmod(z[1], addmod(xi[2], modulus - xi[0], modulus), modulus);
        z[2] = mulmod(z[2], addmod(xi[0], modulus - xi[1], modulus), modulus);

        U[0] = mulmod(z[0], mulmod(xi[1], xi[2], modulus), modulus);
        U[0] = addmod(U[0], mulmod(z[1], mulmod(xi[0], xi[2], modulus), modulus), modulus);
        U[0] = addmod(U[0], mulmod(z[2], mulmod(xi[0], xi[1], modulus), modulus), modulus);

        U[1] = modulus - mulmod(z[0], addmod(xi[1], xi[2], modulus), modulus);
        U[1] = addmod(U[1], modulus - mulmod(z[1], addmod(xi[0], xi[2], modulus), modulus), modulus);
        U[1] = addmod(U[1], modulus - mulmod(z[2], addmod(xi[0], xi[1], modulus), modulus), modulus);

        U[2] = addmod(z[0], addmod(z[1], z[2], modulus), modulus);
    }

    function verify_proof_be(
        bytes calldata blob,
        uint256 offset, 
        uint256[] memory roots,
        uint256[][][] memory evaluation_points,
        types.transcript_data memory tr_state, 
        types.fri_params_type memory fri_params)
    internal view returns (bool result) {
        uint256 ind;

        // Push all merkle roots to transcript
        for( ind = 0; ind < fri_params.batches_num;){
            transcript.update_transcript_b32(tr_state, bytes32(roots[ind]));
            unchecked{ind++;}
        }
        fri_params.theta = transcript.get_field_challenge(tr_state, fri_params.modulus);
        fri_params.eval_map = new uint256[](fri_params.poly_num);
        fri_params.unique_eval_points = new uint256[][](fri_params.poly_num);

        uint256 cur = 0;
        fri_params.different_points = 0;
        bool found = false;
        uint256[] memory point;
        uint256 k;
        uint256 i;        

        // Prepare evaluation map;
        for( k = 0; k < fri_params.batches_num;){
            for( i = 0; i < fri_params.batches_sizes[k]; ){
                if( evaluation_points[k].length == 1 && i > 0){
                    fri_params.eval_map[cur] = fri_params.eval_map[cur - 1];
                } else {
                    point = evaluation_points[k][i];
                    // find this point
                    found = false;
                    for( ind = 0; ind < fri_params.different_points;){
                        if( eval_points_eq(point, fri_params.unique_eval_points[ind]) ){
                            found = true;
                            fri_params.eval_map[cur] = ind;
                            break;
                        }
                        unchecked{ind++;}
                    }
                    if(!found) {
                        fri_params.unique_eval_points[fri_params.different_points] = point;
                        fri_params.eval_map[cur] = fri_params.different_points;
                        unchecked{
                            fri_params.different_points++;
                        }
                    }   
                }
                unchecked{i++;cur++;}
            }
            unchecked{k++;}
        }

        fri_params.denominators = new uint256[][](fri_params.different_points);
        fri_params.factors = new uint256[](fri_params.different_points);

        // Prepare denominators
        for( ind = 0; ind < fri_params.different_points;){
            fri_params.denominators[ind] = new uint256[](fri_params.unique_eval_points[ind].length + 1);
            if( fri_params.unique_eval_points[ind].length == 1 ){
                fri_params.factors[ind] = 1;
                fri_params.denominators[ind][0] = fri_params.modulus - fri_params.unique_eval_points[ind][0];
                fri_params.denominators[ind][1] = 1;
            } else 
            if( fri_params.unique_eval_points[ind].length == 2 ){
                // xi1 - xi0
                fri_params.factors[ind] = 
                    addmod(fri_params.unique_eval_points[ind][1], fri_params.modulus - fri_params.unique_eval_points[ind][0], fri_params.modulus);
                fri_params.denominators[ind][2] = 1;

                fri_params.denominators[ind][1] = 
                    fri_params.modulus - addmod(fri_params.unique_eval_points[ind][0], fri_params.unique_eval_points[ind][1], fri_params.modulus);

                fri_params.denominators[ind][0] = 
                    mulmod(fri_params.unique_eval_points[ind][0], fri_params.unique_eval_points[ind][1], fri_params.modulus);
                fri_params.denominators[ind][0] = mulmod(fri_params.denominators[ind][0], fri_params.factors[ind], fri_params.modulus);
                fri_params.denominators[ind][1] = mulmod(fri_params.denominators[ind][1], fri_params.factors[ind], fri_params.modulus);
                fri_params.denominators[ind][2] = mulmod(fri_params.denominators[ind][2], fri_params.factors[ind], fri_params.modulus);
            } else 
            if( fri_params.unique_eval_points[ind].length == 3 ){
                fri_params.factors[ind] = fri_params.modulus - 
                    mulmod(
                        mulmod(
                            addmod(fri_params.unique_eval_points[ind][0], fri_params.modulus - fri_params.unique_eval_points[ind][1], fri_params.modulus),
                            addmod(fri_params.unique_eval_points[ind][1], fri_params.modulus - fri_params.unique_eval_points[ind][2], fri_params.modulus),
                            fri_params.modulus
                        ),
                        addmod(fri_params.unique_eval_points[ind][2], fri_params.modulus - fri_params.unique_eval_points[ind][0], fri_params.modulus),
                        fri_params.modulus
                    );
                fri_params.denominators[ind][3] = 1;
                fri_params.denominators[ind][2] =
                    fri_params.modulus - addmod(
                        fri_params.unique_eval_points[ind][0], 
                        addmod(fri_params.unique_eval_points[ind][1],fri_params.unique_eval_points[ind][2], fri_params.modulus), 
                        fri_params.modulus
                    );
                fri_params.denominators[ind][1] = 
                    addmod(
                        mulmod(fri_params.unique_eval_points[ind][0], fri_params.unique_eval_points[ind][1], fri_params.modulus),
                        addmod(
                            mulmod(fri_params.unique_eval_points[ind][0], fri_params.unique_eval_points[ind][2], fri_params.modulus),
                            mulmod(fri_params.unique_eval_points[ind][1], fri_params.unique_eval_points[ind][2], fri_params.modulus),
                            fri_params.modulus
                        ), 
                        fri_params.modulus
                    );
                fri_params.denominators[ind][0] = 
                    fri_params.modulus - mulmod(
                        fri_params.unique_eval_points[ind][0], 
                        mulmod(fri_params.unique_eval_points[ind][1],fri_params.unique_eval_points[ind][2], fri_params.modulus), 
                        fri_params.modulus
                    );
                fri_params.denominators[ind][0] = mulmod(fri_params.denominators[ind][0], fri_params.factors[ind], fri_params.modulus);
                fri_params.denominators[ind][1] = mulmod(fri_params.denominators[ind][1], fri_params.factors[ind], fri_params.modulus);
                fri_params.denominators[ind][2] = mulmod(fri_params.denominators[ind][2], fri_params.factors[ind], fri_params.modulus);
                fri_params.denominators[ind][3] = mulmod(fri_params.denominators[ind][3], fri_params.factors[ind], fri_params.modulus);
            } else {
                return false;
            }
            unchecked{ind++;}
        }

        // Prepare combined U
        fri_params.combined_U = new uint256[][](fri_params.different_points);
        for( ind = 0; ind < fri_params.different_points;){
            point = fri_params.unique_eval_points[ind];
            fri_params.combined_U[ind] = new uint256[](fri_params.unique_eval_points[ind].length);
            cur = 0;
            fri_params.z_offset = basic_marshalling.skip_length(offset);
            for( k = 0; k < fri_params.batches_num;){
                fri_params.z_offset = basic_marshalling.skip_length(fri_params.z_offset);
                for( i = 0; i < fri_params.batches_sizes[k];){                    
                    polynomial.multiply_poly_on_coeff(
                        fri_params.combined_U[ind], 
                        fri_params.theta, 
                        fri_params.modulus
                    );
                    if( fri_params.eval_map[cur] == ind ){
                        if( point.length == 1 ){
                            fri_params.combined_U[ind][0] = addmod(
                                fri_params.combined_U[ind][0],
                                basic_marshalling.get_i_uint256_from_vector(blob, fri_params.z_offset, 0), 
                                fri_params.modulus
                            );
                        } else 
                        if( point.length == 2 ){
                            uint256[2] memory tmp;
                            tmp[0] = basic_marshalling.get_i_uint256_from_vector(blob, fri_params.z_offset, 0);
                            tmp[1] = basic_marshalling.get_i_uint256_from_vector(blob, fri_params.z_offset, 1);
                            tmp = calculate_2points_interpolation(
                                point, tmp, fri_params.modulus
                            );
                            fri_params.combined_U[ind][0] = addmod(fri_params.combined_U[ind][0], tmp[0], fri_params.modulus);
                            fri_params.combined_U[ind][1] = addmod(fri_params.combined_U[ind][1], tmp[1], fri_params.modulus);
                        } else 
                        if( point.length == 3){
                            uint256[3] memory tmp;
                            tmp[0] = basic_marshalling.get_i_uint256_from_vector(blob, fri_params.z_offset, 0);
                            tmp[1] = basic_marshalling.get_i_uint256_from_vector(blob, fri_params.z_offset, 1);
                            tmp[2] = basic_marshalling.get_i_uint256_from_vector(blob, fri_params.z_offset, 2);
                            tmp = calculate_3points_interpolation(
                                point, tmp, fri_params.modulus
                            );
                            fri_params.combined_U[ind][0] = addmod(fri_params.combined_U[ind][0], tmp[0], fri_params.modulus);
                            fri_params.combined_U[ind][1] = addmod(fri_params.combined_U[ind][1], tmp[1], fri_params.modulus);
                            fri_params.combined_U[ind][2] = addmod(fri_params.combined_U[ind][2], tmp[2], fri_params.modulus);
                        } else {
                            return false;
                        }
                    } 
                    fri_params.z_offset = basic_marshalling.skip_vector_of_uint256_be(blob, fri_params.z_offset);
                    unchecked{i++;cur++;}
                }
                unchecked{k++;}
            }
            unchecked{ind++;}
        }


        if (!batched_fri_verifier.verify_proof_be(blob, roots, tr_state, fri_params)) {
            return false;
        }
        
        return true;
   }
} 