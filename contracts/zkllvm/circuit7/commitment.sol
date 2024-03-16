
// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2023 Generated by ZKLLVM-transpiler
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

import "../../cryptography/transcript.sol";
import "../../interfaces/modular_commitment.sol";
// Move away unused structures from types.sol
import "../../types.sol";
import "../../basic_marshalling.sol";
import "../../containers/merkle_verifier.sol";
import "../../algebra/polynomial.sol";
import "hardhat/console.sol";

library modular_commitment_scheme_circuit7 {
    uint256 constant modulus = 28948022309329048855892746252171976963363056481941560715954676764349967630337;
    uint64 constant batches_num = 5;
    uint256 constant r = 3;
    uint256 constant lambda = 40;
    uint256 constant D0_size = 256;
    uint256 constant max_degree = 15;
    uint256 constant D0_omega = 23692685744005816481424929253249866475360293751445976741406164118468705843520;
    uint256 constant unique_points = 9;
    uint256 constant omega = 14450201850503471296781915119640920297985789873634237091629829669980153907901;
    uint256 constant _eta = 3220364210532353783132791604212137439743112382567031206832408370394102550017;
    bytes constant point_ids = hex"000100010001000100010001000100010002010002010002010002010002010002010002010002010002010001000100010001000201000201030405060002070806000002000200000000000000000000000000000000000000000000000000000205000205000205000205000205000205000205000205000205"; // 1 byte -- point id
    bytes constant poly_points_num = hex"003d0017001700010001000a000200010001"; // 2 byte lengths
    bytes constant poly_ids = hex"00000040008000c001000140018001c002000240028002c003000340038003c004000440048004c005000540058005c006000640068006c007000740078007c008000840088008c009000940098009c00a000a400a800ac00b000b400b800bc00c000c400c800cc00d000d400d800dc00e000e400e800ec00f0000000040008000c001000140018001c002000240028002c003000340038003c004000440048004c005000540058002000240028002c003000340038003c004000540058005c0064006800d000d400d800dc00e000e400e800ec00f0005c005c005c00d000d400d800dc00e000e400e800ec00f0005c0060005c005c0"; // 2 byte poly_id 2 byte

    struct commitment_state{
        bytes   leaf_data;
        uint256 roots_offset;
        uint256 query_proof_offset;
        uint256 initial_data_offset;
        uint256 initial_proof_offset;
        uint256 round_proof_offset;
        uint256 round_data_offset;
        uint256[r]  alphas;
        uint64[batches_num] batch_sizes;
        uint64 poly_num;
        uint256 points_num;
        uint256 theta;
        uint256 x_index;
        uint256 x;
        uint256 max_batch;
        uint256 domain_size;
        uint256[] final_polynomial;
        uint256 leaf_length;
        uint256[2][unique_points] denominators;
        uint256[unique_points] U;
        uint256[unique_points] unique_eval_points;
        uint256[unique_points] theta_factors;
        uint256[2] y;
        uint256[2] Q;
        uint256 j;
        uint256 offset;
        uint16[][unique_points] poly_inds;
    }


    function prepare_eval_points(uint256[unique_points] memory result, uint256 xi, uint256 eta) internal view {
        uint256 inversed_omega = field.inverse_static(omega, modulus);
		result[0] = xi;
		result[1] = eta;
		result[2] = mulmod(xi, omega, modulus);
		result[3] = mulmod(xi, field.pow_small(inversed_omega, 7, modulus), modulus);
		result[4] = mulmod(xi, field.pow_small(inversed_omega, 3, modulus), modulus);
		result[5] = mulmod(xi, field.pow_small(inversed_omega, 2, modulus), modulus);
		result[6] = mulmod(xi, inversed_omega, modulus);
		result[7] = mulmod(xi, field.pow_small(omega, 2, modulus), modulus);
		result[8] = mulmod(xi, field.pow_small(omega, 3, modulus), modulus);

    }

    function prepare_Y(bytes calldata blob, uint256 offset, commitment_state memory state) internal pure {
        unchecked{
            state.y[0] = 0;
            state.y[1] = 0;
            for(uint256 cur_point = unique_points; cur_point > 0; ){
                cur_point--;
                for(uint256 cur_poly = state.poly_inds[cur_point].length; cur_poly > 0;){
                    cur_poly--;
                    uint256 cur_offset = state.poly_inds[cur_point][cur_poly];
                    cur_offset = state.query_proof_offset + cur_offset;
                    state.Q[0] = mulmod(state.Q[0], state.theta, modulus);
                    state.Q[1] = mulmod(state.Q[1], state.theta, modulus);
                    state.Q[0] = addmod(state.Q[0], basic_marshalling.get_uint256_be(blob, cur_offset), modulus);
                    state.Q[1] = addmod(state.Q[1], basic_marshalling.get_uint256_be(blob, cur_offset + 0x20), modulus);
                }
                state.Q[0] = addmod(state.Q[0], modulus - state.U[cur_point], modulus);
                state.Q[1] = addmod(state.Q[1], modulus - state.U[cur_point], modulus);
                state.Q[0] = mulmod(state.Q[0], state.denominators[cur_point][0], modulus);
                state.Q[1] = mulmod(state.Q[1], state.denominators[cur_point][1], modulus);
                state.Q[0] = mulmod(state.Q[0], state.theta_factors[cur_point], modulus);
                state.Q[1] = mulmod(state.Q[1], state.theta_factors[cur_point], modulus);
                state.y[0] = addmod(state.y[0], state.Q[0], modulus);
                state.y[1] = addmod(state.y[1], state.Q[1], modulus);
                state.Q[0] = 0;
                state.Q[1] = 0;
            }
        }
    }

    function initialize(
        bytes32 tr_state_before
    ) internal returns(bytes32 tr_state_after){
        types.transcript_data memory tr_state;
        tr_state.current_challenge = tr_state_before;
        uint256 eta = transcript.get_field_challenge(tr_state, modulus);
        require(eta == _eta, "Wrong eta");
        tr_state_after = tr_state.current_challenge;
    }

    function copy_memory_pair_and_check(bytes calldata blob, uint256 proof_offset, bytes memory leaf, uint256[2] memory pair)
    internal pure returns(bool b){
        uint256 c = pair[0];
        uint256 d = pair[1];
        assembly{
            mstore(
                add(leaf, 0x20),
                c
            )
            mstore(
                add(leaf, 0x40),
                d
            )
        }
        if( !merkle_verifier.parse_verify_merkle_proof_bytes_be(blob, proof_offset, leaf, 0x40 )){
            return false;
        } else {
            return true;
        }
    }

    function copy_reverted_memory_pair_and_check(bytes calldata blob, uint256 proof_offset, bytes memory leaf, uint256[2] memory pair)
    internal pure returns(bool b){
        uint256 c = pair[0];
        uint256 d = pair[1];
        assembly{
            mstore(
                add(leaf, 0x20),
                d
            )
            mstore(
                add(leaf, 0x40),
                c
            )
        }
        if( !merkle_verifier.parse_verify_merkle_proof_bytes_be(blob, proof_offset, leaf, 0x40 )){
            return false;
        } else {
            return true;
        }
    }

    function copy_pairs_and_check(bytes calldata blob, uint256 offset, bytes memory leaf, uint256 size, uint256 proof_offset)
    internal pure returns(bool b){
        unchecked {
            uint256 offset2 = 0x20;
            for(uint256 k = 0; k < size;){
                assembly{
                    mstore(
                        add(leaf, offset2),
                        calldataload(add(blob.offset, offset))
                    )
                    mstore(
                        add(leaf, add(offset2, 0x20)),
                        calldataload(add(blob.offset, add(offset, 0x20)))
                    )
                }
                k++; offset2 += 0x40; offset += 0x40;
            }
            if( !merkle_verifier.parse_verify_merkle_proof_bytes_be(blob, proof_offset, leaf, offset2 - 0x20 )){
                return false;
            } else {
                return true;
            }
        }
    }

    function copy_reverted_pairs_and_check(bytes calldata blob, uint256 offset, bytes memory leaf, uint256 size, uint256 proof_offset)
    internal pure returns(bool){
        unchecked {
            uint256 offset2 = 0x20;
            for(uint256 k = 0; k < size;){
                assembly{
                    mstore(
                        add(leaf, offset2),
                        calldataload(add(blob.offset, add(offset, 0x20)))
                    )
                    mstore(
                        add(leaf, add(offset2, 0x20)),
                        calldataload(add(blob.offset, offset))
                    )
                }
                k++; offset2 += 0x40; offset += 0x40;
            }
            if( !merkle_verifier.parse_verify_merkle_proof_bytes_be(blob, proof_offset, leaf, offset2 - 0x20 )){
                return false;
            } else {
                return true;
            }
        }
    }

    function colinear_check(uint256 x, uint256[2] memory y, uint256 alpha, uint256 colinear_value) internal pure returns(bool){
        unchecked {
            uint256 tmp;
            tmp = addmod(y[0], y[1], modulus);
            tmp = mulmod(tmp, x, modulus);
            tmp = addmod(
                tmp,
                mulmod(
                    alpha,
                    addmod(y[0], modulus-y[1], modulus),
                    modulus
                ),
                modulus
            );
            uint256 tmp1 = mulmod(colinear_value , 2, modulus);
            tmp1 = mulmod(tmp1 , x, modulus);
            if( tmp !=  tmp1 ){
                return false;
            }
        return true;
        }
    }

    function verify_eval(
        bytes calldata blob,
        uint256[5] memory commitments,
        uint256 challenge,
        bytes32 transcript_state
    ) internal view returns (bool){

unchecked {
        types.transcript_data memory tr_state;
        tr_state.current_challenge = transcript_state;
        commitment_state memory state;

        {
            uint256 offset;

            if (challenge!= transcript.get_field_challenge(tr_state, modulus)) {
                console.log("Wrong challenge");
                return false;
            }

            for(uint8 i = 0; i < batches_num;){
                transcript.update_transcript_b32(tr_state, bytes32(commitments[i]));
                i++;
            }
            state.theta = transcript.get_field_challenge(tr_state, modulus);

            state.points_num = basic_marshalling.get_length(blob, 0x0);
            offset = 0x10 + state.points_num * 0x20;
            for(uint8 i = 0; i < batches_num;){
                state.batch_sizes[i] = uint64(uint8(blob[offset + 0x1]));
                if( state.batch_sizes[i] > state.max_batch ) state.max_batch = state.batch_sizes[i];
                state.poly_num += state.batch_sizes[i];
                i++; offset +=2;
            }

            offset += 0x8;
            offset += state.poly_num;
            state.roots_offset = offset + 0x8;
            offset += 0x8;

            for( uint8 i = 0; i < r;){
                transcript.update_transcript_b32(tr_state, bytes32(basic_marshalling.get_uint256_be(blob, offset + 0x8)));
                state.alphas[i] = transcript.get_field_challenge(tr_state, modulus);
                i++; offset +=40;
            }

            
        bytes calldata proof_of_work = blob[blob.length - 4:];
        transcript.update_transcript(tr_state, proof_of_work);
        uint256 p_o_w = transcript.get_integral_challenge_be(tr_state, 4);
        if (p_o_w & 0xffff0000 != 0) return false;


            offset += 0x8 + r;
            state.initial_data_offset = offset + 0x8;
            offset += 0x8 + 0x20*basic_marshalling.get_length(blob, offset);

            state.round_data_offset = offset + 0x8;
            offset += 0x8 + 0x20*basic_marshalling.get_length(blob, offset);
            offset += 0x8;

            state.initial_proof_offset = offset;
            for(uint256 i = 0; i < lambda;){
                for(uint256 j = 0; j < batches_num;){
                    if(basic_marshalling.get_uint256_be(blob, offset + 0x10) != commitments[j] ) return false;
                    offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
                    j++;
                }
                i++;
            }
            offset += 0x8;
            state.round_proof_offset = offset;

            for(uint256 i = 0; i < lambda;){
                for(uint256 j = 0; j < r;){
                    if(basic_marshalling.get_uint256_be(blob, offset + 0x10) != basic_marshalling.get_uint256_be(blob, state.roots_offset + j * 40 + 0x8) ) return false;
                    offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
                    j++;
                }
                i++;
            }

            state.final_polynomial = new uint256[](basic_marshalling.get_length(blob, offset));
            offset += 0x8;
            for (uint256 i = 0; i < state.final_polynomial.length;) {
                state.final_polynomial[i] = basic_marshalling.get_uint256_be(blob, offset);
                i++; offset+=0x20;
            }
        }
        if( state.final_polynomial.length > (( 1 << (field.log2(max_degree + 1) - r + 1) ) ) ){
            console.log("Wrong final poly degree");
            return false;
        }

        prepare_eval_points(state.unique_eval_points, challenge, _eta);
        {
            uint256 sum;

            for(uint256 i = 0; i < state.unique_eval_points.length;){
                state.theta_factors[i] = field.pow_small(state.theta, sum, modulus);
                sum += (uint256(uint8(poly_points_num[2*i])) << 8) + uint256(uint8(poly_points_num[2*i + 1]));
                i++;
            }
            uint256 off = point_ids.length * 0x20 - 0x18;
            for(uint256 i = 0; i < point_ids.length;){
                uint256 p = uint256(uint8(point_ids[point_ids.length - i - 1]));
                state.U[p] = mulmod(state.U[p], state.theta, modulus);
                state.U[p] = addmod(state.U[p], basic_marshalling.get_uint256_be(blob, off), modulus);
                off -= 0x20;
                i++;
            }
            for(uint256 i = 0; i < state.unique_eval_points.length;){
                i++;
            }
        }
			///* 1 - 2*permutation_size */
		///* eta points check */
		{
			uint256[23] memory points;
			points[0] = basic_marshalling.get_uint256_be(blob,0x28);
			points[0x1] = basic_marshalling.get_uint256_be(blob,0x68);
			points[0x2] = basic_marshalling.get_uint256_be(blob,0xa8);
			points[0x3] = basic_marshalling.get_uint256_be(blob,0xe8);
			points[0x4] = basic_marshalling.get_uint256_be(blob,0x128);
			points[0x5] = basic_marshalling.get_uint256_be(blob,0x168);
			points[0x6] = basic_marshalling.get_uint256_be(blob,0x1a8);
			points[0x7] = basic_marshalling.get_uint256_be(blob,0x1e8);
			points[0x8] = basic_marshalling.get_uint256_be(blob,0x248);
			points[0x9] = basic_marshalling.get_uint256_be(blob,0x2a8);
			points[0xa] = basic_marshalling.get_uint256_be(blob,0x308);
			points[0xb] = basic_marshalling.get_uint256_be(blob,0x368);
			points[0xc] = basic_marshalling.get_uint256_be(blob,0x3c8);
			points[0xd] = basic_marshalling.get_uint256_be(blob,0x428);
			points[0xe] = basic_marshalling.get_uint256_be(blob,0x488);
			points[0xf] = basic_marshalling.get_uint256_be(blob,0x4e8);
			points[0x10] = basic_marshalling.get_uint256_be(blob,0x548);
			points[0x11] = basic_marshalling.get_uint256_be(blob,0x588);
			points[0x12] = basic_marshalling.get_uint256_be(blob,0x5c8);
			points[0x13] = basic_marshalling.get_uint256_be(blob,0x608);
			points[0x14] = basic_marshalling.get_uint256_be(blob,0x648);
			points[0x15] = basic_marshalling.get_uint256_be(blob,0x6a8);
			points[0x16] = basic_marshalling.get_uint256_be(blob,0x708);
			// Check keccak(points) 
			if ( bytes32(0x913002db2afc1e6c2dd64efded0538c8acc9abda2906f020502ba40deeea53b8) != keccak256(abi.encode(points))) {
				return false;
			}
		}


        uint64 cur = 0;
        for(uint64 p = 0; p < unique_points; p++){
            state.poly_inds[p] = new uint16[]((uint16(uint8(poly_points_num[2*p])) << 8) + uint16(uint8(poly_points_num[2*p + 1])));
            for(uint64 i = 0; i < state.poly_inds[p].length; i++){
                state.poly_inds[p][i] = (uint16(uint8(poly_ids[cur])) << 8) + uint16(uint8(poly_ids[cur + 1]));
                cur+=2;
            }
        }

        state.leaf_data = new bytes(state.max_batch * 0x40 + 0x40);
        for(uint64 i = 0; i < lambda;){
            // Initial proofs
            state.query_proof_offset = state.initial_data_offset;
            state.x_index = uint256(transcript.get_integral_challenge_be(tr_state, 8))  % D0_size;
            state.x = field.pow_small(D0_omega, state.x_index, modulus);
            state.domain_size = D0_size >> 1;
            for(uint64 j = 0; j < batches_num;){
                if( state.x_index < state.domain_size ){
                    if(!copy_pairs_and_check(blob, state.initial_data_offset, state.leaf_data, state.batch_sizes[j], state.initial_proof_offset)){
                        console.log("Error in initial mekle proof");
                        return false;
                    }
                } else {
                    if(!copy_reverted_pairs_and_check(blob, state.initial_data_offset, state.leaf_data, state.batch_sizes[j], state.initial_proof_offset)){
                        console.log("Error in initial mekle proof");
                        return false;
                    }
                }
                state.leaf_length = state.batch_sizes[j] * 0x40;
                state.initial_data_offset += state.batch_sizes[j] * 0x40;
                state.initial_proof_offset = merkle_verifier.skip_merkle_proof_be(blob, state.initial_proof_offset);
                j++;
            }

            for( uint64 p = 0; p < unique_points; p++){
                state.denominators[p][0] = addmod(state.x, modulus - state.unique_eval_points[p], modulus);
                state.denominators[p][1] = addmod(modulus - state.x, modulus - state.unique_eval_points[p], modulus);
                state.denominators[p][0] = field.inverse_static(state.denominators[p][0], modulus);
                state.denominators[p][1] = field.inverse_static(state.denominators[p][1], modulus);
            }
            prepare_Y(blob, state.query_proof_offset, state);
            if( state.x_index < state.domain_size ){
                if( !copy_memory_pair_and_check(blob, state.round_proof_offset, state.leaf_data, state.y) ){
                    console.log("Not validated!");
                    return false;
                }
            }else{
                if( !copy_reverted_memory_pair_and_check(blob, state.round_proof_offset, state.leaf_data, state.y) ){
                    console.log("Not validated!");
                    return false;
                }
            }
            if( !colinear_check(state.x, state.y, state.alphas[0], basic_marshalling.get_uint256_be(blob,state.round_data_offset)) ){
                console.log("Colinear check failed");
                return false;
            }

            state.round_proof_offset = merkle_verifier.skip_merkle_proof_be(blob, state.round_proof_offset);
            for(state.j = 1; state.j < r;){
                state.x_index %= state.domain_size;
                state.x = mulmod(state.x, state.x, modulus);
                state.domain_size >>= 1;
                if( state.x_index < state.domain_size ){
                    if(!copy_pairs_and_check(blob, state.round_data_offset, state.leaf_data, 1, state.round_proof_offset)) {
                        console.log("Error in round mekle proof");
                        return false;
                    }
                } else {
                    if(!copy_reverted_pairs_and_check(blob, state.round_data_offset, state.leaf_data, 1, state.round_proof_offset)) {
                        console.log("Error in round mekle proof");
                        return false;
                    }
                }
                state.y[0] = basic_marshalling.get_uint256_be(blob, state.round_data_offset);
                state.y[1] = basic_marshalling.get_uint256_be(blob, state.round_data_offset + 0x20);
                if( !colinear_check(state.x, state.y, state.alphas[state.j], basic_marshalling.get_uint256_be(blob,state.round_data_offset + 0x40)) ){
                    console.log("Round colinear check failed");
                    return false;
                }
                state.j++; state.round_data_offset += 0x40;
                state.round_proof_offset = merkle_verifier.skip_merkle_proof_be(blob, state.round_proof_offset);
            }

            state.x = mulmod(state.x, state.x, modulus);
            if(polynomial.evaluate(state.final_polynomial, state.x, modulus) != basic_marshalling.get_uint256_be(blob, state.round_data_offset)) {
                console.log("Wrong final poly check");
                return false;
            }
            if(polynomial.evaluate(state.final_polynomial, modulus - state.x, modulus) != basic_marshalling.get_uint256_be(blob, state.round_data_offset + 0x20)){
                console.log("Wrong final poly check");
                return false;
            }
            state.round_data_offset += 0x40;
            i++;
        }
        return true;
}
    }
}
    