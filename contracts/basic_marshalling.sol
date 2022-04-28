// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2022 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2022 Ilias Khairullin <ilias@nil.foundation>
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

//================================================================================================================
// Bounds non-checking macros
//================================================================================================================

// #def get_length(_blob, _offset, _var) assembly {\
//     _var := shr(\
//         $(LENGTH_RESTORING_SHIFT),\
//         calldataload(add(_blob.offset, _offset))\
//     )\
// }

// #def skip_length(_blob, _offset, _result_offset) _result_offset = _offset + $(LENGTH_OCTETS);

// #def get_skip_length(_blob, _offset, _var, _result_offset) $(get_length(_blob, _offset, _var))\
// $(skip_length(_blob, _offset, _result_offset))

// #def mstore_length(_blob, _offset, _var_memory, var_offset) assembly {\
//     mstore(\
//         add(_var_memory, var_offset),\
//         shr(\
//             $(LENGTH_RESTORING_SHIFT),\
//             calldataload(add(_blob.offset, _offset))\
//         )\
//     )\
// }

// #def skip_uint256_be(_blob, _offset, _result_offset) _result_offset = _offset + 32;

// #def skip_octet_vector_32_be(_blob, _offset, _result_offset) _result_offset = _offset + $$(LENGTH_OCTETS + 32);

// #def skip_vector_of_uint256_be(_blob, _offset, _result_offset) assembly {\
//     _result_offset := add(\
//         add(\
//             _offset,\
//             mul(\
//                 0x20,\
//                 shr(\
//                     $(LENGTH_RESTORING_SHIFT),\
//                     calldataload(add(blob.offset, _offset))\
//                 )\
//             )\
//         ),\
//         $(LENGTH_OCTETS)\
//     )\
// }

//================================================================================================================
// Bounds checking macros
//================================================================================================================

// #def get_length_check(_blob, _offset, _var) require(_offset + $(LENGTH_OCTETS) <= _blob.length);\
// assembly {\
//     _var := shr(\
//         $(LENGTH_RESTORING_SHIFT),\
//         calldataload(add(_blob.offset, _offset))\
//     )\
// }

// #def skip_length_check(_blob, _offset, _result_offset) _result_offset = _offset + $(LENGTH_OCTETS);\
// require(_result_offset <= _blob.length);

// #def get_skip_length_check(_blob, _offset, _var, _result_offset) $(get_length_check(_blob, _offset, _var))\
// $(skip_length(_blob, _offset, _result_offset))

// #def skip_uint256_be_check(_blob, _offset, _result_offset) _result_offset = _offset + 32;\
// require(_result_offset <= _blob.length);

// #def skip_octet_vector_32_be_check(_blob, _offset, _result_offset) _result_offset = _offset + $$(LENGTH_OCTETS + 32);\
// require(_result_offset <= _blob.length);

// #def skip_vector_of_uint256_be_check(_blob, _offset, _result_offset) assembly {\
//     _result_offset := add(\
//         add(\
//             _offset,\
//             mul(\
//                 0x20,\
//                 shr(\
//                     $(LENGTH_RESTORING_SHIFT),\
//                     calldataload(add(blob.offset, _offset))\
//                 )\
//             )\
//         ),\
//         $(LENGTH_OCTETS)\
//     )\
// }\
// require(_result_offset <= _blob.length);

library basic_marshalling {
    uint256 constant LENGTH_OCTETS = 8;
    // 256 - 8 * LENGTH_OCTETS
    uint256 constant LENGTH_RESTORING_SHIFT = 0xc0;

    //================================================================================================================
    // Bounds non-checking functions
    //================================================================================================================
    // TODO: general case
    function skip_octet_vector_32_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        result_offset = offset + LENGTH_OCTETS + 32;
    }

    function get_octet_vector_32_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (bytes32 result)
    {
        assembly {
            result := mload(add(add(blob.offset, offset), LENGTH_OCTETS))
        }
    }

    // TODO: general case
    function skip_vector_of_octet_vectors_32_be(
        bytes calldata blob,
        uint256 offset
    ) internal pure returns (uint256 result_offset) {
        result_offset = offset + LENGTH_OCTETS;
        assembly {
            result_offset := add(
                result_offset,
                mul(
                    add(LENGTH_OCTETS, 0x20),
                    shr(
                        LENGTH_RESTORING_SHIFT,
                        calldataload(add(blob.offset, offset))
                    )
                )
            )
        }
    }

    function skip_uint256_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        result_offset = offset + 32;
    }

    function skip_vector_of_uint256_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        assembly {
            result_offset := add(
                add(
                    offset,
                    mul(
                        0x20,
                        shr(
                            LENGTH_RESTORING_SHIFT,
                            calldataload(add(blob.offset, offset))
                        )
                    )
                ),
                LENGTH_OCTETS
            )
        }
    }

    function skip_vector_of_vectors_of_uint256_be(
        bytes calldata blob,
        uint256 offset
    ) internal pure returns (uint256 result_offset) {
        result_offset = offset + LENGTH_OCTETS;
        uint256 n;
        assembly {
            n := shr(
                LENGTH_RESTORING_SHIFT,
                calldataload(add(blob.offset, offset))
            )
        }
        for (uint256 i = 0; i < n; i++) {
            result_offset = skip_vector_of_uint256_be(blob, result_offset);
        }
    }

    function skip_length(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        result_offset = offset + LENGTH_OCTETS;
    }

    function get_length(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_length)
    {
        assembly {
            result_length := shr(
                LENGTH_RESTORING_SHIFT,
                calldataload(add(blob.offset, offset))
            )
        }
    }

    function get_skip_length(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_length, uint256 result_offset)
    {
        assembly {
            result_length := shr(
                LENGTH_RESTORING_SHIFT,
                calldataload(add(blob.offset, offset))
            )
        }
        result_offset = offset + LENGTH_OCTETS;
    }

    function get_i_uint256_from_vector(
        bytes calldata blob,
        uint256 offset,
        uint256 i
    ) internal pure returns (uint256 result) {
        assembly {
            result := calldataload(
                add(blob.offset, add(add(offset, LENGTH_OCTETS), mul(i, 0x20)))
            )
        }
    }

    function get_i_bytes32_from_vector(
        bytes calldata blob,
        uint256 offset,
        uint256 i
    ) internal pure returns (bytes32 result) {
        assembly {
            result := calldataload(
                add(blob.offset, add(add(offset, LENGTH_OCTETS), mul(i, 0x20)))
            )
        }
    }

    function get_i_uint256_ptr_from_vector(
        bytes calldata blob,
        uint256 offset,
        uint256 i
    ) internal pure returns (uint256 result_ptr) {
        assembly {
            result_ptr := add(
                blob.offset,
                add(add(offset, LENGTH_OCTETS), mul(i, 0x20))
            )
        }
    }

    function get_i_j_uint256_from_vector_of_vectors(
        bytes calldata blob,
        uint256 offset,
        uint256 i,
        uint256 j
    ) internal pure returns (uint256 result) {
        offset = skip_length(blob, offset);
        if (i > 0) {
            for (uint256 _i = 0; _i < i; _i++) {
                offset = skip_vector_of_uint256_be(blob, offset);
            }
        }
        result = get_i_uint256_from_vector(blob, offset, j);
    }

    function get_i_j_uint256_ptr_from_vector_of_vectors(
        bytes calldata blob,
        uint256 offset,
        uint256 i,
        uint256 j
    ) internal pure returns (uint256 result_ptr) {
        offset = skip_length(blob, offset);
        if (i > 0) {
            for (uint256 _i = 0; _i < i; _i++) {
                offset = skip_vector_of_uint256_be(blob, offset);
            }
        }
        result_ptr = get_i_uint256_ptr_from_vector(blob, offset, j);
    }

    function get_uint256_be(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result)
    {
        assembly {
            result := calldataload(add(blob.offset, offset))
        }
    }

    //================================================================================================================
    // Bounds checking functions
    //================================================================================================================
    // TODO: general case
    function skip_octet_vector_32_be_check(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        result_offset = offset + LENGTH_OCTETS + 32;
        require(result_offset <= blob.length);
    }

    // TODO: general case
    function skip_vector_of_octet_vectors_32_be_check(
        bytes calldata blob,
        uint256 offset
    ) internal pure returns (uint256 result_offset) {
        result_offset = offset + LENGTH_OCTETS;
        require(result_offset <= blob.length);
        assembly {
            result_offset := add(
                result_offset,
                mul(
                    add(LENGTH_OCTETS, 0x20),
                    shr(
                        LENGTH_RESTORING_SHIFT,
                        calldataload(add(blob.offset, offset))
                    )
                )
            )
        }
        require(result_offset <= blob.length);
    }

    function skip_uint256_be_check(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        result_offset = offset + 32;
        require(result_offset <= blob.length);
    }

    function skip_vector_of_uint256_be_check(
        bytes calldata blob,
        uint256 offset
    ) internal pure returns (uint256 result_offset) {
        assembly {
            result_offset := add(
                add(
                    offset,
                    mul(
                        0x20,
                        shr(
                            LENGTH_RESTORING_SHIFT,
                            calldataload(add(blob.offset, offset))
                        )
                    )
                ),
                LENGTH_OCTETS
            )
        }
        require(result_offset <= blob.length);
    }

    function skip_vector_of_vectors_of_uint256_be_check(
        bytes calldata blob,
        uint256 offset
    ) internal pure returns (uint256 result_offset) {
        result_offset = offset + LENGTH_OCTETS;
        require(result_offset <= blob.length);
        uint256 n;
        assembly {
            n := shr(
                LENGTH_RESTORING_SHIFT,
                calldataload(add(blob.offset, offset))
            )
        }
        for (uint256 i = 0; i < n; i++) {
            result_offset = skip_vector_of_uint256_be_check(
                blob,
                result_offset
            );
        }
    }

    function skip_length_check(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_offset)
    {
        result_offset = offset + LENGTH_OCTETS;
        require(result_offset < blob.length);
    }

    function get_length_check(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_length)
    {
        require(offset + LENGTH_OCTETS <= blob.length);
        assembly {
            result_length := shr(
                LENGTH_RESTORING_SHIFT,
                calldataload(add(blob.offset, offset))
            )
        }
    }

    function get_skip_length_check(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result_length, uint256 result_offset)
    {
        result_offset = offset + LENGTH_OCTETS;
        require(result_offset <= blob.length);
        assembly {
            result_length := shr(
                LENGTH_RESTORING_SHIFT,
                calldataload(add(blob.offset, offset))
            )
        }
    }

    function get_i_uint256_from_vector_check(
        bytes calldata blob,
        uint256 offset,
        uint256 i
    ) internal pure returns (uint256 result) {
        require(offset + LENGTH_OCTETS + (i + 1) * 0x20 <= blob.length);
        assembly {
            result := calldataload(
                add(blob.offset, add(add(offset, LENGTH_OCTETS), mul(i, 0x20)))
            )
        }
    }

    function get_i_uint256_ptr_from_vector_check(
        bytes calldata blob,
        uint256 offset,
        uint256 i
    ) internal pure returns (uint256 result_ptr) {
        require(offset + LENGTH_OCTETS + (i + 1) * 0x20 <= blob.length);
        assembly {
            result_ptr := add(
                blob.offset,
                add(add(offset, LENGTH_OCTETS), mul(i, 0x20))
            )
        }
    }

    function get_i_j_uint256_from_vector_of_vectors_check(
        bytes calldata blob,
        uint256 offset,
        uint256 i,
        uint256 j
    ) internal pure returns (uint256 result) {
        offset = skip_length_check(blob, offset);
        if (i > 0) {
            for (uint256 _i = 0; _i < i; _i++) {
                offset = skip_vector_of_uint256_be_check(blob, offset);
            }
        }
        result = get_i_uint256_from_vector_check(blob, offset, j);
    }

    function get_i_j_uint256_ptr_from_vector_of_vectors_check(
        bytes calldata blob,
        uint256 offset,
        uint256 i,
        uint256 j
    ) internal pure returns (uint256 result_ptr) {
        offset = skip_length_check(blob, offset);
        if (i > 0) {
            for (uint256 _i = 0; _i < i; _i++) {
                offset = skip_vector_of_uint256_be_check(blob, offset);
            }
        }
        result_ptr = get_i_uint256_ptr_from_vector_check(blob, offset, j);
    }

    function get_uint256_be_check(bytes calldata blob, uint256 offset)
        internal
        pure
        returns (uint256 result)
    {
        require(offset + 0x20 <= blob.length);
        assembly {
            result := calldataload(add(blob.offset, offset))
        }
    }
}
