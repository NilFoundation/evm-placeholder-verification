// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2021 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2021 Ilias Khairullin <ilias@nil.foundation>
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
import "./fri_verifier.sol";
import "../algebra/polynomial.sol";
import "../basic_marshalling.sol";

library lpc_verifier {
    struct local_vars_type {
        uint256[] z;
        bool status;
    }

    uint256 constant m = 2;
    uint256 constant PROOF_Z_OFFSET = 0x28;

    function skip_proof_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be(blob, offset);
        // z
        result_offset = basic_marshalling.skip_vector_of_uint256_be(
            blob,
            result_offset
        );
        // fri_proof
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(
            blob,
            result_offset
        );
        for (uint256 i = 0; i < value_len; i++) {
            result_offset = fri_verifier.skip_proof_be(blob, result_offset);
        }
    }

    function skip_vector_of_proofs_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(
            blob,
            offset
        );
        for (uint256 i = 0; i < value_len; i++) {
            result_offset = skip_proof_be(blob, result_offset);
        }
    }

    function skip_n_proofs_in_vector_be(
        bytes calldata blob,
        uint256 offset,
        uint256 n
    ) internal pure returns (uint256 result_offset) {
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(
            blob,
            offset
        );
        for (uint256 i = 0; i < n; i++) {
            result_offset = skip_proof_be(blob, result_offset);
        }
    }

    function skip_to_first_fri_proof_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be(blob, offset);
        // z
        result_offset = basic_marshalling.skip_vector_of_uint256_be(
            blob,
            result_offset
        );
        // fri_proof
        result_offset = basic_marshalling.skip_length(blob, result_offset);
    }

    function get_z_n_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 n)
    {
        // T_root
        offset = basic_marshalling.skip_octet_vector_32_be(blob, offset);
        // z
        n = basic_marshalling.get_length(blob, offset);
    }

    function get_z_i_from_proof_be(
        bytes calldata blob,
        uint256 offset,
        uint256 i
    ) internal pure returns (uint256 z_i) {
        // 0x28 (skip T_root)
        z_i = basic_marshalling.get_i_uint256_from_vector(
            blob,
            basic_marshalling.skip_octet_vector_32_be(blob, offset),
            i
        );
    }

    function get_z_i_ptr_from_proof_be(
        bytes calldata blob,
        uint256 offset,
        uint256 i
    ) internal pure returns (uint256 z_i) {
        // 0x28 (skip T_root)
        z_i = basic_marshalling.get_i_uint256_ptr_from_vector(
            blob,
            basic_marshalling.skip_octet_vector_32_be(blob, offset),
            i
        );
    }

    function get_z_0_ptr_from_proof_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 z_0_ptr)
    {
        // 0x28 (skip T_root) + 8 (lenght)
        assembly {
            z_0_ptr := add(blob.offset, add(offset, 0x30))
        }
    }

    function get_fri_proof_n_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 n)
    {
        // T_root
        offset = basic_marshalling.skip_octet_vector_32_be(blob, offset);
        // z
        offset = basic_marshalling.skip_vector_of_uint256_be(blob, offset);
        // fri_proof
        n = basic_marshalling.get_length(blob, offset);
    }

    function skip_proof_be_check(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // T_root
        result_offset = basic_marshalling.skip_octet_vector_32_be_check(
            blob,
            offset
        );
        // z
        result_offset = basic_marshalling.skip_vector_of_uint256_be_check(
            blob,
            result_offset
        );
        // fri_proof
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length_check(
            blob,
            result_offset
        );
        for (uint256 i = 0; i < value_len; i++) {
            result_offset = fri_verifier.skip_proof_be_check(
                blob,
                result_offset
            );
        }
    }

    function skip_vector_of_proofs_be_check(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length_check(
            blob,
            offset
        );
        for (uint256 i = 0; i < value_len; i++) {
            result_offset = skip_proof_be_check(blob, result_offset);
        }
    }

    function skip_n_proofs_in_vector_be_check(
        bytes calldata blob,
        uint256 offset,
        uint256 n
    ) internal pure returns (uint256 result_offset) {
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length_check(
            blob,
            offset
        );
        require(n <= value_len);
        for (uint256 i = 0; i < n; i++) {
            result_offset = skip_proof_be_check(blob, result_offset);
        }
    }

    function get_z_i_from_proof_be_check(
        bytes calldata blob,
        uint256 offset,
        uint256 i
    ) internal pure returns (uint256 z_i) {
        // 0x28 (skip T_root)
        z_i = basic_marshalling.get_i_uint256_from_vector_check(
            blob,
            offset + 0x28,
            i
        );
    }

    function get_z_i_ptr_from_proof_be_check(
        bytes calldata blob,
        uint256 offset,
        uint256 i
    ) internal pure returns (uint256 z_i) {
        // 0x28 (skip T_root)
        z_i = basic_marshalling.get_i_uint256_ptr_from_vector_check(
            blob,
            offset + 0x28,
            i
        );
    }

    function get_z_0_ptr_from_proof_be_check(
        bytes calldata blob,
        uint256 offset
    ) internal pure returns (uint256 z_0_ptr) {
        // 0x28 (skip T_root) + 8 (lenght)
        assembly {
            z_0_ptr := add(blob.offset, add(offset, 0x30))
        }
    }

    function parse_verify_proof_be(
        bytes calldata blob,
        uint256 offset,
        uint256[] memory evaluation_points,
        types.transcript_data memory tr_state,
        types.fri_params_type memory fri_params
    ) internal view returns (bool result) {
        result = false;

        require(
            fri_params.lambda == get_fri_proof_n_be(blob, offset),
            "Fri proofs number is not equal to lambda!"
        );

        local_vars_type memory local_vars;
        local_vars.z = new uint256[](get_z_n_be(blob, offset));
        for (uint256 i = 0; i < local_vars.z.length; i++) {
            local_vars.z[i] = get_z_i_from_proof_be(blob, offset, i);
        }
        fri_params.U = polynomial.interpolate(
            evaluation_points,
            local_vars.z,
            fri_params.modulus
        );
        fri_params.V = new uint256[](1);
        fri_params.V[0] = 1;
        uint256[] memory a_poly = new uint256[](2);
        a_poly[1] = 1;
        for (uint256 j = 0; j < evaluation_points.length; j++) {
            a_poly[0] = fri_params.modulus - evaluation_points[j];
            fri_params.V = polynomial.mul_poly(
                fri_params.V,
                a_poly,
                fri_params.modulus
            );
        }
        offset = skip_to_first_fri_proof_be(blob, offset);
        for (uint256 round_id = 0; round_id < fri_params.lambda; round_id++) {
            local_vars.status = fri_verifier.parse_verify_proof_be(
                blob,
                offset,
                tr_state,
                fri_params
            );
            if (!local_vars.status) {
                return false;
            }
            offset = fri_verifier.skip_proof_be(blob, offset);
        }
        result = true;
    }
}
