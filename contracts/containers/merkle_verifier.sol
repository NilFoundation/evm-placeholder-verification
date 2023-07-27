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

    function getBytes32(bytes calldata input, uint256 r1) pure internal returns (bytes32) {
        //return bytes32(input[r1 : r1 + 8]);
        bytes32 dummy;
        return dummy;
    }



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
    uint256 constant WORD_SIZE = 32; //32 bytes,256 bits
    uint256 constant ROOT_OFFSET = 2; //16/8;
    uint256 constant DEPTH_OFFSET = 6; //48/8;
    uint256 constant LAYERS_OFFSET = 7; //56/8;
    // only one co-element on each layer as arity is always 2
    // 8 + (number of co-path elements on the layer)
    // 8 + (co-path element position on the layer)
    // 8 + (co-path element hash value length)
    // 32 (co-path element hash value)
    uint256 constant LAYER_POSITION_OFFSET = 1; //8/8;
    uint256 constant LAYER_COPATH_HASH_OFFSET = 3; //24/8;
    uint256 constant LAYER_OCTETS = 7; //56/8;


    uint256 constant LENGTH_RESTORING_SHIFT = 0xc0;

    // TODO : Check if the offset input or output are they bits/bytes requiring conversion
    // TODO : Check if all offset are byte aligned i.e multiples of 8.
    // This has implications on all calling functions.
    function skip_merkle_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        offset = offset/8;
        unchecked { result_offset = offset + LAYERS_OFFSET; }

        uint256 read_offset_st  = offset + DEPTH_OFFSET;
        //bytes memory read_bytes = getBytes32(blob[read_offset_st:read_offset_st + WORD_SIZE];
        uint256 read_offset_uint = uint256(getBytes32(blob,read_offset_st));
        result_offset += ((read_offset_uint >> LENGTH_RESTORING_SHIFT) * LAYER_OCTETS );
        result_offset = result_offset * 8;
//        assembly {
//            result_offset := add(
//                result_offset,
//                mul(
//                    LAYER_OCTETS,
//                    shr(
//                        LENGTH_RESTORING_SHIFT,
//                        calldataload(
//                            add(blob.offset, add(offset, DEPTH_OFFSET))
//                        )
//                    )
//                )
//            )
//        }
    }

    function skip_merkle_proof_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        unchecked { result_offset = offset + LAYERS_OFFSET; }
        require(result_offset < blob.length);
        offset = offset/8;
        uint256 read_offset_st  = offset + DEPTH_OFFSET;

        //bytes memory read_offset = blob[read_offset_st:read_offset_st + WORD_SIZE];
        uint256 read_offset_uint = uint256(getBytes32(blob,read_offset_st));
        result_offset += ((read_offset_uint >> LENGTH_RESTORING_SHIFT) * LAYER_OCTETS );
        result_offset = result_offset * 8;
//        assembly {
//            result_offset := add(
//                result_offset,
//                mul(
//                    LAYER_OCTETS,
//                    shr(
//                        LENGTH_RESTORING_SHIFT,
//                        calldataload(
//                            add(blob.offset, add(offset, DEPTH_OFFSET))
//                        )
//                    )
//                )
//            )
//        }
        require(result_offset <= blob.length, "skip_merkle_proof_be");
    }

    function getKeccak256LeafNodes(bytes32[2] memory leafNodes) internal pure returns (bytes32 result) {
        result = keccak256(bytes.concat(leafNodes[0], leafNodes[1]));
    }

    function parse_verify_merkle_proof_not_pre_hash_be(bytes calldata blob, uint256 offset, bytes32 verified_data)
    internal pure returns (bool result) {
//        uint256 x = 0;
//        uint256 depth;
        uint256 depth_offset_bytes = (offset/8) + DEPTH_OFFSET;
        uint256 depth = uint256(getBytes32(blob,depth_offset_bytes)) >> LENGTH_RESTORING_SHIFT ;

        uint256 layer_pos_offset_bytes = (offset/8) + LAYERS_OFFSET + LAYER_POSITION_OFFSET;
        uint256 pos = uint256(getBytes32(blob,layer_pos_offset_bytes)) >> LENGTH_RESTORING_SHIFT ;
        bytes32[2] memory leafNodes;
        if (pos == 0) {
            leafNodes[1] = verified_data;
        } else if (pos ==1){
            leafNodes[0] = verified_data;
        }

        uint256 layer_offset = (offset/8) + LAYERS_OFFSET;
        uint256 next_pos;

        for(uint256 cur_layer_idx=0; cur_layer_idx < depth -1 ; cur_layer_idx++ ){
            //uint256 layer_offset_st = layer_offset + LAYER_POSITION_OFFSET;
            pos = uint256(getBytes32(blob,layer_offset + LAYER_POSITION_OFFSET)) >> LENGTH_RESTORING_SHIFT;

            uint256 next_pos_offset =  layer_offset + LAYER_POSITION_OFFSET + LAYER_OCTETS;
            next_pos = uint256(getBytes32(blob,next_pos_offset)) >> LENGTH_RESTORING_SHIFT;

            if (pos==0){
                uint256 start_offset = layer_offset + LAYER_COPATH_HASH_OFFSET;
                leafNodes[0] = getBytes32(blob,start_offset);

                if(next_pos==0){
                    leafNodes[1] = getKeccak256LeafNodes(leafNodes);
                } else if (next_pos ==1){
                    leafNodes[0] = getKeccak256LeafNodes(leafNodes);
                }
            } else if (pos ==1) {
                uint256 start_offset = layer_offset + LAYER_COPATH_HASH_OFFSET;
                leafNodes[1] = getBytes32(blob,start_offset);

                if(next_pos==0){
                    leafNodes[1] = getKeccak256LeafNodes(leafNodes);
                } else if (next_pos ==1){
                    leafNodes[0] = getKeccak256LeafNodes(leafNodes);
                }
            }
            layer_offset = layer_offset + LAYER_OCTETS;
        }
        uint256 start_offset = layer_offset + LAYER_POSITION_OFFSET ;
        pos = uint256(getBytes32(blob,start_offset)) >> LENGTH_RESTORING_SHIFT;

        if (pos == 0){
            uint256 _offset = layer_offset + LAYER_COPATH_HASH_OFFSET;
            leafNodes[0] = getBytes32(blob,_offset);
            verified_data = getKeccak256LeafNodes(leafNodes);

        } else if (pos ==1){
            uint256 _offset = layer_offset + LAYER_COPATH_HASH_OFFSET;
            leafNodes[1] = getBytes32(blob,_offset);
            verified_data = getKeccak256LeafNodes(leafNodes);
        }

        bytes32 root;
        uint256 _root_offset = (offset/8) + ROOT_OFFSET;
        root = getBytes32(blob,_root_offset);
        result = (verified_data == root);


    //    assembly {
            //let depth := shr(LENGTH_RESTORING_SHIFT, calldataload(add(blob.offset, add(offset, DEPTH_OFFSET))))

            // save leaf hash data to required position
//            let pos := shr(
//                LENGTH_RESTORING_SHIFT,
//                calldataload(
//                    add(
//                        blob.offset,
//                        add(add(offset, LAYERS_OFFSET), LAYER_POSITION_OFFSET)
//                    )
//                )
//            )
//            x := add(x, pos)
//            x := mul(x, 10)
//            switch pos
//            case 0 {
//                mstore(0x20, verified_data)
//            }
//            case 1 {
//                mstore(0x00, verified_data)
//            }

//            let layer_offst := add(offset, LAYERS_OFFSET)
//            let next_pos
//            for {
//                let cur_layer_i := 0
//            } lt(cur_layer_i, sub(depth, 1)) {
//                cur_layer_i := add(cur_layer_i, 1)
//            } {
//                pos := shr(
//                    LENGTH_RESTORING_SHIFT,
//                    calldataload(
//                        add(
//                            blob.offset,
//                            add(layer_offst, LAYER_POSITION_OFFSET)
//                        )
//                    )
//                )
//                next_pos := shr(
//                    LENGTH_RESTORING_SHIFT,
//                    calldataload(
//                        add(
//                            blob.offset,
//                            add(
//                                add(layer_offst, LAYER_POSITION_OFFSET),
//                                LAYER_OCTETS
//                            )
//                        )
//                    )
//                )
////                x := add(x, pos)
////                x := mul(x, 10)
//                switch pos
//                case 0 {
//                    mstore(
//                        0x00,
//                        calldataload(
//                            add(
//                                blob.offset,
//                                add(layer_offst, LAYER_COPATH_HASH_OFFSET)
//                            )
//                        )
//                    )
//                    switch next_pos
//                    case 0 {
//                        mstore(0x20, keccak256(0, 0x40))
//                    }
//                    case 1 {
//                        mstore(0, keccak256(0, 0x40))
//                    }
//                }
//                case 1 {
//                    mstore(
//                        0x20,
//                        calldataload(
//                            add(
//                                blob.offset,
//                                add(layer_offst, LAYER_COPATH_HASH_OFFSET)
//                            )
//                        )
//                    )
//                    switch next_pos
//                    case 0 {
//                        mstore(0x20, keccak256(0, 0x40))
//                    }
//                    case 1 {
//                        mstore(0, keccak256(0, 0x40))
//                    }
//                }
//                layer_offst := add(layer_offst, LAYER_OCTETS)
//            }
//
//            pos := shr(
//                LENGTH_RESTORING_SHIFT,
//                calldataload(
//                    add(blob.offset, add(layer_offst, LAYER_POSITION_OFFSET))
//                )
//            )
////            x := add(x, pos)
////            x := mul(x, 10)
//            switch pos
//            case 0 {
//                mstore(
//                    0x00,
//                    calldataload(
//                        add(
//                            blob.offset,
//                            add(layer_offst, LAYER_COPATH_HASH_OFFSET)
//                        )
//                    )
//                )
//                verified_data := keccak256(0, 0x40)
//            }
//            case 1 {
//                mstore(
//                    0x20,
//                    calldataload(
//                        add(
//                            blob.offset,
//                            add(layer_offst, LAYER_COPATH_HASH_OFFSET)
//                        )
//                    )
//                )
//                verified_data := keccak256(0, 0x40)
//            }
//        }
//
//        bytes32 root;
//        assembly {
//            root := calldataload(add(blob.offset, add(offset, ROOT_OFFSET)))
//        }
//        result = (verified_data == root);
    }
    
    // We store merkle root as an octet vector. At first length==0x20 is stored.
    // We should skip it.
    // TODO: this function should return bytes32
    function get_merkle_root_from_blob(bytes calldata blob, uint256 merkle_root_offset)
    internal pure returns(uint256 root){
         uint256 merkle_proof_offset_bytes = (merkle_root_offset/8) + 1;
         root = uint256(getBytes32(blob,merkle_proof_offset_bytes));
//        assembly {
//            root := calldataload(add(blob.offset, add(merkle_root_offset, 0x8)))
//        }
    }

    // TODO: This function should return bytes32
    function get_merkle_root_from_proof(bytes calldata blob, uint256 merkle_proof_offset)
    internal pure returns(uint256 root){
        uint256 merkle_proof_offset_bytes = (merkle_proof_offset/8) + ROOT_OFFSET;
        root = uint256(getBytes32(blob,merkle_proof_offset_bytes));
//        assembly {
//            root := calldataload(add(blob.offset, add(merkle_proof_offset, ROOT_OFFSET)))
//        }
    }

    function parse_verify_merkle_proof_be(bytes calldata blob, uint256 offset, bytes32 verified_data)
    internal pure returns (bool result) {
//        assembly {
//            mstore(0, verified_data)
//            verified_data := keccak256(0, 0x20)
//        }
        bytes memory verified_data_m = bytes.concat(verified_data);
        result = parse_verify_merkle_proof_not_pre_hash_be(blob, offset, keccak256(verified_data_m));
    }

    function parse_verify_merkle_proof_bytes_be(bytes calldata blob, uint256 offset, bytes memory verified_data)
    internal pure returns (bool result) {
        result = parse_verify_merkle_proof_not_pre_hash_be(blob, offset, keccak256(verified_data));
    }

    function parse_verify_merkle_proof_bytes_be(bytes calldata blob, uint256 offset, bytes memory verified_data_bytes,
                                                uint256 verified_data_bytes_len)
    internal pure returns (bool result) {
        uint256 addition_offset =  uint256(bytes32(verified_data_bytes)) + 0x20; // TODO : Length in bits?
        bytes32 verified_data = keccak256(abi.encodePacked(addition_offset,verified_data_bytes_len));
//        assembly {
//            verified_data := keccak256(add(verified_data_bytes, 0x20), verified_data_bytes_len)
//        }
        result = parse_verify_merkle_proof_not_pre_hash_be(blob, offset, verified_data);
    }
}
