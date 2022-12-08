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
import "./batched_fri_verifier.sol";
import "../algebra/polynomial.sol";
import "../basic_marshalling.sol";
import "../profiling.sol";

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

    function parse_verify_proof_be(bytes calldata blob,
        uint256 offset, uint256[][] memory evaluation_points,
        types.transcript_data memory tr_state, types.fri_params_type memory fri_params)
    internal returns (bool result) {
        profiling.start_block("batched_lpc_verifier::parse_verify_proof_be");
        profiling.start_block("batched_lpc_verifier::prepare U and V");
        result = false;
        uint256 ind;

        fri_params.leaf_size = get_z_n_be(blob, offset);

        // If there is only one point for multiple polynomials;
        if (fri_params.leaf_size != evaluation_points.length && evaluation_points.length == 1){
            uint256[] memory eval;
            eval = evaluation_points[0];
            evaluation_points = new uint256[][](fri_params.leaf_size);
            for(ind = 0; ind < fri_params.leaf_size;){
                evaluation_points[ind] = eval;
                unchecked{ ind++; }
            }
        }
        require(fri_params.leaf_size == evaluation_points.length, "Array of evaluation points size is not equal to leaf_size!");
        require(fri_params.lambda == get_fri_proof_n_be(blob, offset), "Fri proofs number is not equal to lambda!");

        uint256 z_offset;
        uint256 polynom_index;
        uint256 point_index;
        uint256 round_id;

        z_offset = basic_marshalling.skip_length(skip_to_z(blob, offset));
        for (polynom_index = 0; polynom_index < fri_params.leaf_size;) {
            fri_params.batched_U[polynom_index] = polynomial.interpolate(
                blob,
                evaluation_points[polynom_index],
                z_offset,
                fri_params.modulus
            );
            z_offset = basic_marshalling.skip_vector_of_uint256_be(blob, z_offset);

            unchecked{ polynom_index++; }
        }

        for (polynom_index = 0; polynom_index < fri_params.leaf_size;) {
            fri_params.batched_V[polynom_index] = new uint256[](1);
            fri_params.batched_V[polynom_index][0] = 1;
            for (point_index = 0; point_index < evaluation_points[polynom_index].length;) {
                fri_params.lpc_z[0] = fri_params.modulus - evaluation_points[polynom_index][point_index];
                fri_params.batched_V[polynom_index] = polynomial.mul_poly(
                    fri_params.batched_V[polynom_index],
                    fri_params.lpc_z,
                    fri_params.modulus
                );
                unchecked{ point_index++; }
            }
            unchecked{ polynom_index++; }
        }

        profiling.end_block();
        profiling.start_block("batched_lpc_verifier::FRI_checks");
        offset = skip_to_first_fri_proof_be(blob, offset);
        for (round_id = 0; round_id < fri_params.lambda;) {
            fri_params.i_fri_proof = round_id;  // for debug only
            if (!batched_fri_verifier.parse_verify_proof_be(blob, offset, tr_state, fri_params)) {
                require(false, "FRI-proof problem");
                return false;
            }
            offset = batched_fri_verifier.skip_proof_be(blob, offset);
            unchecked{ round_id++; }
        }
        result = true;
        profiling.end_block();
        profiling.end_block();
   }
}