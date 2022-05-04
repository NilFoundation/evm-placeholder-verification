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
import "../containers/merkle_verifier.sol";
import "../cryptography/transcript.sol";
import "../algebra/field.sol";
import "../algebra/polynomial.sol";
import "../basic_marshalling.sol";

library fri_verifier {
    struct local_vars_type {
        // 0x0
        uint256 colinear_value;
        // 0x20
        uint256 x;
        // 0x40
        uint256 x_next;
        // 0x60
        uint256 alpha;
        // 0x80
        uint256 round_proof_offset;
        // 0xa0
        uint256 round_proof_y_offset;
        // 0xc0
        uint256 round_proof_p_offset;
        // 0xe0
        uint256 len;
        // 0x100
        bool status;
    }

    uint256 constant COLINEAR_VALUE_OFFSET =  0x0;
    uint256 constant X_OFFSET =  0x20;
    uint256 constant X_NEXT_OFFSET =  0x40;
    uint256 constant ALPHA_OFFSET =  0x60;
    uint256 constant ROUND_PROOF_OFFSET_OFFSET =  0x80;
    uint256 constant ROUND_PROOF_Y_OFFSET_OFFSET =  0xa0;
    uint256 constant ROUND_PROOF_P_OFFSET_OFFSET =  0xc0;
    uint256 constant LEN_OFFSET =  0xe0;
    uint256 constant STATUS_OFFSET =  0x100;

    uint256 constant m = 2;

    function skip_round_proof_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // colinear_value
        result_offset = offset + 32;
        // T_root
        result_offset = result_offset + 40;
        // y
        assembly {result_offset := add(add(result_offset,mul(0x20,shr(0xc0,calldataload(add(blob.offset, result_offset))))),8)}
        // colinear_path
        result_offset = merkle_verifier.skip_merkle_proof_be(
            blob,
            result_offset
        );
        // p
        uint256 value_len;
        assembly {value_len := shr(0xc0,calldataload(add(blob.offset, result_offset)))}result_offset = result_offset + 8;
        for (uint256 i = 0; i < value_len; i++) {
            result_offset = merkle_verifier.skip_merkle_proof_be(
                blob,
                result_offset
            );
        }
    }

    function get_round_proof_y_n_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 n)
    {
        // colinear_value
        offset = offset + 32;
        // T_root
        offset = offset + 40;
        // y
        assembly {n := shr(0xc0,calldataload(add(blob.offset, offset)))}
    }

    function get_round_proof_p_n_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 n)
    {
        // colinear_value
        offset = offset + 32;
        // T_root
        offset = offset + 40;
        // y
        assembly {offset := add(add(offset,mul(0x20,shr(0xc0,calldataload(add(blob.offset, offset))))),8)}
        // colinear_path
        offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // p
        assembly {n := shr(0xc0,calldataload(add(blob.offset, offset)))}
    }

    function skip_to_round_proof_y_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // colinear_value
        result_offset = offset + 32;
        // T_root
        result_offset = result_offset + 40;
    }

    function skip_to_first_round_proof_p_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // colinear_value
        result_offset = offset + 32;
        // T_root
        result_offset = result_offset + 40;
        // y
        assembly {result_offset := add(add(result_offset,mul(0x20,shr(0xc0,calldataload(add(blob.offset, result_offset))))),8)}
        // colinear_path
        result_offset = merkle_verifier.skip_merkle_proof_be(
            blob,
            result_offset
        );
        // p
        result_offset = result_offset + 8;
    }

    function skip_to_round_proof_T_root_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // colinear_value
        result_offset = offset + 32;
        // T_root
        result_offset = result_offset + 8;
    }

    function skip_to_round_proof_colinear_path_be(
        bytes calldata blob,
        uint256 offset
    ) internal pure returns (uint256 result_offset) {
        // colinear_value
        result_offset = offset + 32;
        // T_root
        result_offset = result_offset + 40;
        // y
        assembly {result_offset := add(add(result_offset,mul(0x20,shr(0xc0,calldataload(add(blob.offset, result_offset))))),8)}
    }

    function skip_proof_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // final_polynomial
        assembly {result_offset := add(add(offset,mul(0x20,shr(0xc0,calldataload(add(blob.offset, offset))))),8)}
        // round_proofs
        uint256 value_len;
        assembly {value_len := shr(0xc0,calldataload(add(blob.offset, result_offset)))}result_offset = result_offset + 8;
        for (uint256 i = 0; i < value_len; i++) {
            result_offset = skip_round_proof_be(blob, result_offset);
        }
    }

    function get_round_proofs_n_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 n)
    {
        // final_polynomial
        assembly {offset := add(add(offset,mul(0x20,shr(0xc0,calldataload(add(blob.offset, offset))))),8)}
        // round_proofs
        assembly {n := shr(0xc0,calldataload(add(blob.offset, offset)))}
    }

    function skip_to_first_round_proof_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // final_polynomial
        assembly {result_offset := add(add(offset,mul(0x20,shr(0xc0,calldataload(add(blob.offset, offset))))),8)}
        // round_proofs
        result_offset = result_offset + 8;
    }

    function skip_round_proof_be_check(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // colinear_value
        result_offset = offset + 32;
        // T_root
        result_offset = result_offset + 40;require(result_offset <= blob.length);
        // y
        assembly {result_offset := add(add(result_offset,mul(0x20,shr(0xc0,calldataload(add(blob.offset, result_offset))))),8)}require(result_offset <= blob.length);
        // colinear_path
        result_offset = merkle_verifier.skip_merkle_proof_be_check(
            blob,
            result_offset
        );
        // p
        uint256 value_len;
        require(result_offset + 8 <= blob.length);assembly {value_len := shr(0xc0,calldataload(add(blob.offset, result_offset)))}result_offset = result_offset + 8;
        for (uint256 i = 0; i < value_len; i++) {
            result_offset = merkle_verifier.skip_merkle_proof_be_check(
                blob,
                result_offset
            );
        }
    }

    function skip_proof_be_check(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        // final_polynomial
        assembly {result_offset := add(add(offset,mul(0x20,shr(0xc0,calldataload(add(blob.offset, offset))))),8)}require(result_offset <= blob.length);
        // round_proofs
        uint256 value_len;
        require(result_offset + 8 <= blob.length);assembly {value_len := shr(0xc0,calldataload(add(blob.offset, result_offset)))}result_offset = result_offset + 8;
        for (uint256 i = 0; i < value_len; i++) {
            result_offset = skip_round_proof_be_check(blob, result_offset);
        }
    }

    function eval_y_from_blob(
        bytes calldata blob,
        local_vars_type memory local_vars,
        uint256 i,
        uint256 j,
        types.fri_params_type memory fri_params
    ) internal view returns (uint256 result) {
        result = basic_marshalling.get_i_uint256_from_vector(
            blob,
            local_vars.round_proof_y_offset,
            j
        );
        if (i == 0) {
            uint256 U_evaluated_neg;
            uint256 V_evaluated_inv;
            if (j == 0) {
                U_evaluated_neg =
                    fri_params.modulus -
                    polynomial.evaluate(
                        fri_params.U,
                        local_vars.x,
                        fri_params.modulus
                    );
                V_evaluated_inv = field.inverse_static(
                    polynomial.evaluate(
                        fri_params.V,
                        local_vars.x,
                        fri_params.modulus
                    ),
                    fri_params.modulus
                );
            } else if (j == 1) {
                U_evaluated_neg =
                    fri_params.modulus -
                    polynomial.evaluate(
                        fri_params.U,
                        fri_params.modulus - local_vars.x,
                        fri_params.modulus
                    );
                V_evaluated_inv = field.inverse_static(
                    polynomial.evaluate(
                        fri_params.V,
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
    }

    function parse_verify_round_proof_be(
        bytes calldata blob,
        uint256 round_proof_offset,
        local_vars_type memory local_vars
    ) internal pure returns (bool result) {
        require(
            m == get_round_proof_y_n_be(blob, round_proof_offset),
            "Round proof y size is not equal to m!"
        );
        require(
            m == get_round_proof_p_n_be(blob, round_proof_offset),
            "Round proof p size is not equal to m!"
        );

        local_vars.round_proof_p_offset = skip_to_first_round_proof_p_be(
            blob,
            round_proof_offset
        );
        local_vars.round_proof_y_offset = skip_to_round_proof_y_be(
            blob,
            round_proof_offset
        );
        for (uint256 j = 0; j < m; j++) {
            local_vars.status = merkle_verifier.parse_verify_merkle_proof_be(
                blob,
                local_vars.round_proof_p_offset,
                basic_marshalling.get_i_bytes32_from_vector(
                    blob,
                    local_vars.round_proof_y_offset,
                    j
                )
            );
            if (!local_vars.status) {
                return false;
            }
            local_vars.round_proof_p_offset = merkle_verifier
                .skip_merkle_proof_be(blob, local_vars.round_proof_p_offset);
        }
        result = true;
    }

    function parse_verify_proof_be(
        bytes calldata blob,
        uint256 offset,
        types.transcript_data memory tr_state,
        types.fri_params_type memory fri_params
    ) internal view returns (bool result) {
        result = false;

        require(
            fri_params.r == get_round_proofs_n_be(blob, offset),
            "Round proofs number is not equal to params.r!"
        );

        local_vars_type memory local_vars;
        local_vars.x = field.expmod_static(
            fri_params.D_omegas[0],
            transcript.get_integral_challenge_be(tr_state, 8),
            fri_params.modulus
        );
        local_vars.round_proof_offset = skip_to_first_round_proof_be(
            blob,
            offset
        );

        for (uint256 i = 0; i < fri_params.r; i++) {
            local_vars.alpha = transcript.get_field_challenge(
                tr_state,
                fri_params.modulus
            );
            local_vars.x_next = polynomial.evaluate(
                fri_params.q,
                local_vars.x,
                fri_params.modulus
            );

            local_vars.status = parse_verify_round_proof_be(
                blob,
                local_vars.round_proof_offset,
                local_vars
            );
            if (!local_vars.status) {
                return false;
            }

            // get colinear_value
            local_vars.colinear_value = basic_marshalling.get_uint256_be(
                blob,
                local_vars.round_proof_offset
            );
            if (
                polynomial.interpolate_evaluate_by_2_points_neg_x(
                    local_vars.x,
                    field.inverse_static(
                        field.double(local_vars.x, fri_params.modulus),
                        fri_params.modulus
                    ),
                    eval_y_from_blob(blob, local_vars, i, 0, fri_params),
                    eval_y_from_blob(blob, local_vars, i, 1, fri_params),
                    local_vars.alpha,
                    fri_params.modulus
                ) != local_vars.colinear_value
            ) {
                return false;
            }

            if (i < fri_params.r - 1) {
                // get round_proofs[i + 1].T_root
                transcript.update_transcript_b32_by_offset_calldata(
                    tr_state,
                    blob,
                    skip_to_round_proof_T_root_be(
                        blob,
                        skip_round_proof_be(blob, local_vars.round_proof_offset)
                    )
                );

                local_vars.status = merkle_verifier
                    .parse_verify_merkle_proof_be(
                        blob,
                        skip_to_round_proof_colinear_path_be(
                            blob,
                            local_vars.round_proof_offset
                        ),
                        bytes32(local_vars.colinear_value)
                    );
                if (!local_vars.status) {
                    return false;
                }

                local_vars.round_proof_offset = skip_round_proof_be(
                    blob,
                    local_vars.round_proof_offset
                );
            }

            local_vars.x = local_vars.x_next;
        }

        assembly {mstore(add(local_vars, LEN_OFFSET),shr(0xc0,calldataload(add(blob.offset, offset))))}
        if (
            local_vars.len - 1 >
            uint256(2)**(field.log2(fri_params.max_degree + 1) - fri_params.r) -
                1
        ) {
            return false;
        }

        if (
            polynomial.evaluate_by_ptr(
                blob,
                offset + basic_marshalling.LENGTH_OCTETS,
                local_vars.len,
                local_vars.x,
                fri_params.modulus
            ) != local_vars.colinear_value
        ) {
            return false;
        }

        result = true;
    }
}