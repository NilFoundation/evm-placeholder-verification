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

library merkle_verifier {
    // Merkle proof has the following structure:
    // [0:8] - leaf index
    // [8:16] - root length (which is always 32 bytes in current implementation)
    // [16:48] - root
    // [48:56] - merkle tree depth
    //
    // Depth number of layers with co-path elements follows then.
    // Each layer has following structure (actually indexes begin from a certain offset):
    // [0:8] - number of co-path elements on the layer
    //  (layer_size = arity-1 actually, which (arity) is always 2 in current implementation)
    //
    // layer_size number of co-path elements for every layer in merkle proof follows then.
    // Each element has following structure (actually indexes begin from a certain offset):
    // [0:8] - co-path element position on the layer
    // [8:16] - co-path element hash value length (which is always 32 bytes in current implementation)
    // [16:48] - co-path element hash value
    uint256 constant ROOT_OFFSET = 16;
    uint256 constant DEPTH_OFFSET = 48;
    uint256 constant LAYERS_OFFSET = 56;
    // only one co-element on each layer as arity is always 2
    // 8 + (number of co-path elements on the layer)
    // 8 + (co-path element position on the layer)
    // 8 + (co-path element hash value length)
    // 32 (co-path element hash value)
    uint256 constant LAYER_POSITION_OFFSET = 8;
    uint256 constant LAYER_COPATH_HASH_OFFSET = 24;
    uint256 constant LAYER_OCTETS = 56;

    uint256 constant LENGTH_OCTETS = 8;
    // 256 - 8 * LENGTH_OCTETS
    uint256 constant LENGTH_RESTORING_SHIFT = 0xc0;

    function skip_merkle_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        unchecked { result_offset = offset + LAYERS_OFFSET; }
        assembly {
            result_offset := add(
                result_offset,
                mul(
                    LAYER_OCTETS,
                    shr(
                        LENGTH_RESTORING_SHIFT,
                        calldataload(
                            add(blob.offset, add(offset, DEPTH_OFFSET))
                        )
                    )
                )
            )
        }
    }

    function skip_merkle_proof_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        unchecked { result_offset = offset + LAYERS_OFFSET; }
        require(result_offset < blob.length);
        assembly {
            result_offset := add(
                result_offset,
                mul(
                    LAYER_OCTETS,
                    shr(
                        LENGTH_RESTORING_SHIFT,
                        calldataload(
                            add(blob.offset, add(offset, DEPTH_OFFSET))
                        )
                    )
                )
            )
        }
        require(result_offset <= blob.length, "skip_merkle_proof_be");
    }

    function parse_verify_merkle_proof_not_pre_hash_be(bytes calldata blob, uint256 offset, bytes32 verified_data)
    internal pure returns (bool result) {
//        uint256 x = 0;
//        uint256 depth;
        assembly {
            let depth := shr(LENGTH_RESTORING_SHIFT, calldataload(add(blob.offset, add(offset, DEPTH_OFFSET))))

            // save leaf hash data to required position
            let pos := shr(
                LENGTH_RESTORING_SHIFT,
                calldataload(
                    add(
                        blob.offset,
                        add(add(offset, LAYERS_OFFSET), LAYER_POSITION_OFFSET)
                    )
                )
            )
//            x := add(x, pos)
//            x := mul(x, 10)
            switch pos
            case 0 {
                mstore(0x20, verified_data)
            }
            case 1 {
                mstore(0x00, verified_data)
            }

            let layer_offst := add(offset, LAYERS_OFFSET)
            let next_pos
            for {
                let cur_layer_i := 0
            } lt(cur_layer_i, sub(depth, 1)) {
                cur_layer_i := add(cur_layer_i, 1)
            } {
                pos := shr(
                    LENGTH_RESTORING_SHIFT,
                    calldataload(
                        add(
                            blob.offset,
                            add(layer_offst, LAYER_POSITION_OFFSET)
                        )
                    )
                )
                next_pos := shr(
                    LENGTH_RESTORING_SHIFT,
                    calldataload(
                        add(
                            blob.offset,
                            add(
                                add(layer_offst, LAYER_POSITION_OFFSET),
                                LAYER_OCTETS
                            )
                        )
                    )
                )
//                x := add(x, pos)
//                x := mul(x, 10)
                switch pos
                case 0 {
                    mstore(
                        0x00,
                        calldataload(
                            add(
                                blob.offset,
                                add(layer_offst, LAYER_COPATH_HASH_OFFSET)
                            )
                        )
                    )
                    switch next_pos
                    case 0 {
                        mstore(0x20, keccak256(0, 0x40))
                    }
                    case 1 {
                        mstore(0, keccak256(0, 0x40))
                    }
                }
                case 1 {
                    mstore(
                        0x20,
                        calldataload(
                            add(
                                blob.offset,
                                add(layer_offst, LAYER_COPATH_HASH_OFFSET)
                            )
                        )
                    )
                    switch next_pos
                    case 0 {
                        mstore(0x20, keccak256(0, 0x40))
                    }
                    case 1 {
                        mstore(0, keccak256(0, 0x40))
                    }
                }
                layer_offst := add(layer_offst, LAYER_OCTETS)
            }

            pos := shr(
                LENGTH_RESTORING_SHIFT,
                calldataload(
                    add(blob.offset, add(layer_offst, LAYER_POSITION_OFFSET))
                )
            )
//            x := add(x, pos)
//            x := mul(x, 10)
            switch pos
            case 0 {
                mstore(
                    0x00,
                    calldataload(
                        add(
                            blob.offset,
                            add(layer_offst, LAYER_COPATH_HASH_OFFSET)
                        )
                    )
                )
                verified_data := keccak256(0, 0x40)
            }
            case 1 {
                mstore(
                    0x20,
                    calldataload(
                        add(
                            blob.offset,
                            add(layer_offst, LAYER_COPATH_HASH_OFFSET)
                        )
                    )
                )
                verified_data := keccak256(0, 0x40)
            }
        }

        bytes32 root;
        assembly {
            root := calldataload(add(blob.offset, add(offset, ROOT_OFFSET)))
        }
        result = (verified_data == root);
    }
    
    // We store merkle root as an octet vector. At first length==0x20 is stored.
    // We should skip it.
    // TODO: this function should return bytes32
    function get_merkle_root_from_blob(bytes calldata blob, uint256 merkle_root_offset)
    internal pure returns(uint256 root){
        assembly {
            root := calldataload(add(blob.offset, add(merkle_root_offset, 0x8)))
        }
    }

    // TODO: This function should return bytes32
    function get_merkle_root_from_proof(bytes calldata blob, uint256 merkle_proof_offset)
    internal pure returns(uint256 root){
        assembly {
            root := calldataload(add(blob.offset, add(merkle_proof_offset, ROOT_OFFSET)))
        }
    }

    function parse_verify_merkle_proof_be(bytes calldata blob, uint256 offset, bytes32 verified_data)
    internal pure returns (bool result) {
        assembly {
            mstore(0, verified_data)
            verified_data := keccak256(0, 0x20)
        }
        result = parse_verify_merkle_proof_not_pre_hash_be(blob, offset, verified_data);
    }

    function parse_verify_merkle_proof_bytes_be(bytes calldata blob, uint256 offset, bytes memory verified_data)
    internal pure returns (bool result) {
        result = parse_verify_merkle_proof_not_pre_hash_be(blob, offset, keccak256(verified_data));
    }

    function parse_verify_merkle_proof_bytes_be(bytes calldata blob, uint256 offset, bytes memory verified_data_bytes,
                                                uint256 verified_data_bytes_len)
    internal pure returns (bool result) {
        bytes32 verified_data;
        assembly {
            verified_data := keccak256(add(verified_data_bytes, 0x20), verified_data_bytes_len)
        }
        result = parse_verify_merkle_proof_not_pre_hash_be(blob, offset, verified_data);
    }
}
