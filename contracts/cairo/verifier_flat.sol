// Sources flattened with hardhat v2.16.1 https://hardhat.org

// File contracts/algebra/field.sol

// SPDX-License-Identifier: MIT OR Apache-2.0
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

uint256 constant ROWS_ROTATION = 2;
uint256 constant COLS_ROTATION = 3;

    function getBytes32(bytes calldata input, uint256 r1)  internal returns (bytes32) {
        //return bytes32(input[r1 : r1 + 8]);
        bytes32 dummy;
        return dummy;
    }


/**
 * @title Bn254 elliptic curve crypto
 * @dev Provides some basic methods to compute bilinear pairings, construct group elements and misc numerical methods
 */
library field {

    /// @dev Modular inverse of a (mod p) using euclid.
    /// 'a' and 'p' must be co-prime.
    /// @param a The number.
    /// @param p The mmodulus.
    /// @return x such that ax = 1 (mod p)
        function invmod(uint256 a, uint256 p)
    internal pure returns (uint256) {
        require(a != 0 && a != p && p != 0);
        if (a > p)
            a = a % p;
        int256 t1;
        int256 t2 = 1;
        uint256 r1 = p;
        uint256 r2 = a;
        uint256 q;
        while (r2 != 0) {
            q = r1 / r2;
            (t1, t2, r1, r2) = (t2, t1 - int256(q) * t2, r2, r1 - q * r2);
        }
        if (t1 < 0)
            return (p - uint256(- t1));
        return uint256(t1);
    }

    function fadd(uint256 a, uint256 b, uint256 modulus)
    internal pure returns (uint256 result) {
        result = addmod(a, b, modulus);
//        assembly {
//            result := addmod(a, b, modulus)
//        }
    }


    function fsub(uint256 a, uint256 b, uint256 modulus)
    internal pure returns (uint256 result) {
        result =addmod(a , (modulus - b), modulus);
//        assembly {
//            result := addmod(a, sub(modulus, b), modulus)
//        }
    }

    function fmul(uint256 a, uint256 b, uint256 modulus)
    internal pure returns (uint256 result) {
        result = mulmod(a, b, modulus);
//        assembly {
//            result := mulmod(a, b, modulus)
//        }
    }

    function fdiv(uint256 a, uint256 b, uint256 modulus)
    internal pure returns (uint256 result) {
        uint256 b_inv = invmod(b, modulus);
        result  =mulmod(a, b_inv, modulus);
//        assembly {
//            result := mulmod(a, b_inv, modulus)
//        }
    }

    // See https://ethereum.stackexchange.com/questions/8086/logarithm-math-operation-in-solidity
    function log2(uint256 x)
    internal pure returns (uint256 y){
         //TODO : Check for a way to do this in pure cairo instead of solidity asm
//        assembly {
//            let arg := x
//            x := sub(x, 1)
//            x := or(x, div(x, 0x02))
//            x := or(x, div(x, 0x04))
//            x := or(x, div(x, 0x10))
//            x := or(x, div(x, 0x100))
//            x := or(x, div(x, 0x10000))
//            x := or(x, div(x, 0x100000000))
//            x := or(x, div(x, 0x10000000000000000))
//            x := or(x, div(x, 0x100000000000000000000000000000000))
//            x := add(x, 1)
//            let m := mload(0x40)
//            mstore(m, 0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
//            mstore(add(m, 0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
//            mstore(add(m, 0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
//            mstore(add(m, 0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
//            mstore(add(m, 0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
//            mstore(add(m, 0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
//            mstore(add(m, 0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
//            mstore(add(m, 0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
//            mstore(0x40, add(m, 0x100))
//            let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
//            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
//            let a := div(mul(x, magic), shift)
//            y := div(mload(add(m, sub(255, a))), shift)
//            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
//        }
    }

    function expmod_static(uint256 base, uint256 exponent, uint256 modulus)
    internal view returns (uint256 res) {
        //TODO check if you can do this in cairo
//        assembly {
//            let p := mload(0x40)
//            mstore(p, 0x20) // Length of Base.
//            mstore(add(p, 0x20), 0x20) // Length of Exponent.
//            mstore(add(p, 0x40), 0x20) // Length of Modulus.
//            mstore(add(p, 0x60), base) // Base.
//            mstore(add(p, 0x80), exponent) // Exponent.
//            mstore(add(p, 0xa0), modulus) // Modulus.
//        // Call modexp precompile.
//            if iszero(staticcall(gas(), 0x05, p, 0xc0, p, 0x20)) {
//                revert(0, 0)
//            }
//            res := mload(p)
//        }
    }

    function inverse_static(uint256 val, uint256 modulus)
    internal view returns (uint256 res) {
        //        return expmod_static(val, modulus - 2, modulus); // code below similar to this call
        //TODO : Check cairo implementation
//        assembly {
//            let p := mload(0x40)
//            mstore(p, 0x20) // Length of Base.
//            mstore(add(p, 0x20), 0x20) // Length of Exponent.
//            mstore(add(p, 0x40), 0x20) // Length of Modulus.
//            mstore(add(p, 0x60), val) // Base.
//            mstore(add(p, 0x80), sub(modulus, 0x02)) // Exponent.
//            mstore(add(p, 0xa0), modulus) // Modulus.
//        // Call modexp precompile.
//            if iszero(staticcall(gas(), 0x05, p, 0xc0, p, 0x20)) {
//                revert(0, 0)
//            }
//            res := mload(p)
//        }
    }
}


// File contracts/basic_marshalling.sol


library basic_marshalling {
    uint256 constant WORD_SIZE = 4;
    uint256 constant LENGTH_OCTETS = 8;
    // 256 - 8 * LENGTH_OCTETS
    uint256 constant LENGTH_RESTORING_SHIFT = 0xc0;
    uint256 constant LENGTH_OCTETS_ADD_32 = 40;

    //================================================================================================================
    // Bounds non-checking functions
    //================================================================================================================
    // TODO: general case
    function skip_octet_vector_32_be(uint256 offset)
    internal pure returns (uint256 result_offset) {
        unchecked { result_offset = offset + LENGTH_OCTETS_ADD_32; }
    }

    function skip_uint256_be(uint256 offset)
    internal pure returns (uint256 result_offset) {
        unchecked { result_offset = offset + 32; }
    }

    function skip_vector_of_uint256_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {

        //Dev note - Bytes re-write
        uint256 offset_by = offset/8;
        uint256 offset_shr_mul = (WORD_SIZE * 8) *
                                  uint256(getBytes32(blob,offset_by)) >> LENGTH_RESTORING_SHIFT;
                                 //uint256(bytes32(blob[offset_by: offset_by + WORD_SIZE])) >> LENGTH_RESTORING_SHIFT;

        result_offset = offset_shr_mul + offset; // Returning still in bits.

//        assembly {
//            result_offset := add(
//                add(
//                    offset,
//                    mul(
//                        0x20,
//                        shr(
//                            LENGTH_RESTORING_SHIFT,
//                            calldataload(add(blob.offset, offset))
//                        )
//                    )
//                ),
//                LENGTH_OCTETS
//            )
//        }
    }

    function skip_vector_of_vectors_of_uint256_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        unchecked { result_offset = offset + LENGTH_OCTETS; }
        uint256 n;
        uint256 offset_by = offset/8;
        //Dev note - Bytes re-write
        n = uint256(getBytes32(blob,offset_by)) >> LENGTH_RESTORING_SHIFT;
        //n = uint256(bytes32(blob[offset : offset_by + WORD_SIZE])) >> LENGTH_RESTORING_SHIFT;
//        assembly {
//            n := shr(
//                LENGTH_RESTORING_SHIFT,
//                calldataload(add(blob.offset, offset))
//            )
//        }
        for (uint256 i = 0; i < n;) {
            result_offset = skip_vector_of_uint256_be(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_length(uint256 offset)
    internal pure returns (uint256 result_offset) {
        unchecked { result_offset = offset + LENGTH_OCTETS; }
    }

    function get_length(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_length){
          uint256 offset_by = offset/8;
          //dev note bytes re-write
          result_length = uint256(getBytes32(blob,offset_by)) >> LENGTH_RESTORING_SHIFT;
          //result_length = uint256(bytes32(blob[offset_by : offset_by + WORD_SIZE])) >> LENGTH_RESTORING_SHIFT;
//        assembly {
//            result_length := shr(LENGTH_RESTORING_SHIFT, calldataload(add(blob.offset, offset)))
//        }
    }

    function get_skip_length(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_length, uint256 result_offset){
         uint256 offset_by = offset/8;
        //dev note bytes re-write
        result_length = uint256(getBytes32(blob,offset_by)) >> LENGTH_RESTORING_SHIFT;
        //result_length = uint256(bytes32(blob[offset_by : offset_by + WORD_SIZE])) >> LENGTH_RESTORING_SHIFT;

//        assembly {
//            result_length := shr(LENGTH_RESTORING_SHIFT, calldataload(add(blob.offset, offset)))
//        }
        unchecked { result_offset = offset + LENGTH_OCTETS; }
    }

    function get_i_uint256_from_vector(bytes calldata blob, uint256 offset, uint256 i)
    internal pure returns (uint256 result) {
        uint256 mul_by = (i * 0x20)/8;
        uint256 offset_plus_len_octets_by = (offset + LENGTH_OCTETS)/8;
        uint256 offset_st_by = offset_plus_len_octets_by + mul_by;
        //dev note bytes re-write
        result = uint256(getBytes32(blob,offset_st_by));
        //result = uint256(bytes32(blob[offset_st_by : offset_st_by + WORD_SIZE]));

//        assembly {
//            result := calldataload(add(blob.offset, add(add(offset, LENGTH_OCTETS), mul(i, 0x20))))
//        }
    }

    function get_i_j_uint256_from_vector_of_vectors(bytes calldata blob, uint256 offset, uint256 i, uint256 j)
    internal pure returns (uint256 result) {
        offset = skip_length(offset);
        for (uint256 _i = 0; _i < i;) {
            offset = skip_vector_of_uint256_be(blob, offset);
            unchecked{ _i++; }
        }
        result = get_i_uint256_from_vector(blob, offset, j);
    }


    function get_uint256_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result) {
         uint256 offset_by = offset/8;
        //dev note bytes re-write
         result = uint256(getBytes32(blob,offset_by));
        //result = uint256(bytes32(blob[offset_by : offset_by + WORD_SIZE]));
//        assembly {
//            result := calldataload(add(blob.offset, offset))
//        }
    }

    //================================================================================================================
    // Bounds checking functions
    //================================================================================================================
    // TODO: general case
    function skip_octet_vector_32_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        unchecked { result_offset = offset + LENGTH_OCTETS_ADD_32; }
        require(result_offset <= blob.length);
    }


    function skip_uint256_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        unchecked { result_offset = offset + 32; }
        require(result_offset <= blob.length);
    }

    function skip_vector_of_uint256_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {

        uint256 offset_by = offset/8;
        //dev note bytes re-write
        //uint256 offset_shr_mul  = 0x20 * uint256(bytes32(blob[offset_by : offset_by + WORD_SIZE])) >> LENGTH_RESTORING_SHIFT;
        uint256 offset_shr_mul  = 0x20 * uint256(getBytes32(blob,offset_by)) >> LENGTH_RESTORING_SHIFT;
        result_offset = offset + offset_shr_mul + LENGTH_OCTETS;

//        assembly {
//            result_offset := add(
//                add(
//                    offset,
//                    mul(
//                        0x20,
//                        shr(
//                            LENGTH_RESTORING_SHIFT,
//                            calldataload(add(blob.offset, offset))
//                        )
//                    )
//                ),
//                LENGTH_OCTETS
//            )
//        }
        require(result_offset <= blob.length);
    }

    function skip_vector_of_vectors_of_uint256_be_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        unchecked { result_offset = offset + LENGTH_OCTETS; }
        require(result_offset <= blob.length);
        uint256 n;
        uint256 offset_by = offset/8;
        n = uint256(getBytes32(blob,offset_by)) >> LENGTH_RESTORING_SHIFT;
        //n = uint256(bytes32(blob[offset_by: offset_by + WORD_SIZE])) >> LENGTH_RESTORING_SHIFT;

//        assembly {
//            n := shr(
//                LENGTH_RESTORING_SHIFT,
//                calldataload(add(blob.offset, offset))
//            )
//        }
        for (uint256 i = 0; i < n;) {
            result_offset = skip_vector_of_uint256_be_check(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_length_check(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset){
        unchecked { result_offset = offset + LENGTH_OCTETS; }
        require(result_offset < blob.length);
    }

    function write_bytes(bytes memory sink , uint256 start_offset, bytes memory src)
    internal pure {
        for(uint256 idx=0 ; idx < src.length ; ++idx) {
            sink[start_offset + idx] = src[idx];
        }
    }

    function to_bytes(uint256 x)
    internal pure returns (bytes memory c) {
        bytes32 b = bytes32(x);
        c = new bytes(32);
        for (uint i=0; i < 32; i++) {
            c[i] = b[i];
        }
    }
}


// File contracts/algebra/polynomial.sol

/**
 * @title Turbo Plonk polynomial evaluation
 * @dev Implementation of Turbo Plonk's polynomial evaluation algorithms
 *
 * Expected to be inherited by `TurboPlonk.sol`
 */
library polynomial {
    uint256 constant LENGTH_OCTETS = 8;

    function multiply_poly_on_coeff(uint256[] memory coeffs, uint256 mul, uint256 modulus)
    internal pure{
        for(uint256 i = 0; i < coeffs.length; i++){
            coeffs[i] =  mulmod(coeffs[i], mul, modulus);
        }
    }

    /*
      Computes the evaluation of a polynomial f(x) = sum(a_i * x^i) on the given point.
      The coefficients of the polynomial are given in
        a_0 = coefsStart[0], ..., a_{n-1} = coefsStart[n - 1]
      where n = nCoeffs = friLastLayerDegBound. Note that coefsStart is not actually an array but
      a direct pointer.
      The function requires that n is divisible by 8.
    */
    function evaluate(uint256[] memory coeffs, uint256 point, uint256 modulus)
    internal pure returns (uint256) {
        uint256 result;
        for (uint i=coeffs.length -1; i>=0 ; i--){
            uint256 mul_m = mulmod(result,point,modulus);
            result = addmod(mul_m,coeffs[i],modulus);
        }
//        assembly {
//            let cur_coefs := add(coeffs, mul(mload(coeffs), 0x20)
//            )
//            for { } gt(cur_coefs, coeffs) {} {
//                result := addmod(mulmod(result, point, modulus),
//                                mload(cur_coefs), // (i - 1) * 32
//                                modulus)
//                cur_coefs := sub(cur_coefs, 0x20)
//            }
//        }
        return result;
    }
}


// File contracts/types.sol

/**
 * @title Bn254Crypto library used for the fr, g1 and g2 point types
 * @dev Used to manipulate fr, g1, g2 types, perform modular arithmetic on them and call
 * the precompiles add, scalar mul and pairing
 *
 * Notes on optimisations
 * 1) Perform addmod, mulmod etc. in assembly - removes the check that Solidity performs to confirm that
 * the supplied modulus is not 0. This is safe as the modulus's used (r_mod, q_mod) are hard coded
 * inside the contract and not supplied by the user
 */
library types {
    uint256 constant PROGRAM_WIDTH = 4;
    uint256 constant NUM_NU_CHALLENGES = 11;

    uint256 constant coset_generator0 = 0x0000000000000000000000000000000000000000000000000000000000000005;
    uint256 constant coset_generator1 = 0x0000000000000000000000000000000000000000000000000000000000000006;
    uint256 constant coset_generator2 = 0x0000000000000000000000000000000000000000000000000000000000000007;

    // TODO: add external_coset_generator() method to compute this
    uint256 constant coset_generator7 = 0x000000000000000000000000000000000000000000000000000000000000000c;

    struct g1_point {
        uint256 x;
        uint256 y;
    }

    // G2 group element where x \in Fq2 = x0 * z + x1
    struct g2_point {
        uint256 x0;
        uint256 x1;
        uint256 y0;
        uint256 y1;
    }

    // N>B. Do not re-order these fields! They must appear in the same order as they
    // appear in the proof data
    struct proof {
        g1_point W1;
        g1_point W2;
        g1_point W3;
        g1_point W4;
        g1_point Z;
        g1_point T1;
        g1_point T2;
        g1_point T3;
        g1_point T4;
        uint256 w1;
        uint256 w2;
        uint256 w3;
        uint256 w4;
        uint256 sigma1;
        uint256 sigma2;
        uint256 sigma3;
        uint256 q_arith;
        uint256 q_ecc;
        uint256 q_c;
        uint256 linearization_polynomial;
        uint256 grand_product_at_z_omega;
        uint256 w1_omega;
        uint256 w2_omega;
        uint256 w3_omega;
        uint256 w4_omega;
        g1_point PI_Z;
        g1_point PI_Z_OMEGA;
        g1_point recursive_P1;
        g1_point recursive_P2;
        uint256 quotient_polynomial_eval;
    }

    struct challenge_transcript {
        uint256 alpha_base;
        uint256 alpha;
        uint256 zeta;
        uint256 beta;
        uint256 gamma;
        uint256 u;
        uint256 v0;
        uint256 v1;
        uint256 v2;
        uint256 v3;
        uint256 v4;
        uint256 v5;
        uint256 v6;
        uint256 v7;
        uint256 v8;
        uint256 v9;
        uint256 v10;
    }

    struct verification_key {
        uint256 circuit_size;
        uint256 num_inputs;
        uint256 work_root;
        uint256 domain_inverse;
        uint256 work_root_inverse;
        g1_point Q1;
        g1_point Q2;
        g1_point Q3;
        g1_point Q4;
        g1_point Q5;
        g1_point QM;
        g1_point QC;
        g1_point QARITH;
        g1_point QECC;
        g1_point QRANGE;
        g1_point QLOGIC;
        g1_point SIGMA1;
        g1_point SIGMA2;
        g1_point SIGMA3;
        g1_point SIGMA4;
        bool contains_recursive_proof;
        uint256 recursive_proof_indices;
        g2_point g2_x;

        // zeta challenge raised to the power of the circuit size.
        // Not actually part of the verification key, but we put it here to prevent stack depth errors
        uint256 zeta_pow_n;
    }
    
    struct transcript_data {
        bytes32 current_challenge;
    }

    struct fri_params_type {
        // 0x0
        uint256 modulus;
        // 0x20
        uint256 r;
        // 0x40
        uint256 max_degree;
        // 0x60
        uint256 lambda;
        // 0x80
        uint256 omega;
        // 0xa0
        uint256[] D_omegas;
        // 0xc0
        uint256[] correct_order_idx;       // Ordered indices to pack ys to check merkle proof
        // 0xe0
        uint256[] step_list;
        // 0x100
        uint256[] q;

        // 0x120
        uint256[] s_indices;
        uint256[] s;                    // Coset indices
        uint256 max_step;       // variable for memory  initializing
        uint256 max_batch;      // variable for memory  initializing

        // These are local variables for FRI. But it's useful to allocate memory once
        uint256[]    tmp_arr;
        uint256[][]  evaluation_points;
        uint256      z_offset;

        // New fields
        uint256       max_coset;
        uint256       batches_num;
        uint256[]     batches_sizes;
        uint256       fri_proof_offset;         // fri_roots offset equals to fri_proof_offset + 0x20
        uint256       fri_final_poly_offset;
        uint256       fri_cur_query_offset;     // It'll be changed during verification process.
                                                // It's set at the begining of the first query proof after parse functions running.
        uint256       theta;
        uint256       poly_num;
        uint256[][]   combined_U;                // U polynomials for different evaluation points
        uint256[][]   denominators;              // V polynomials for different evaluation points
        uint256[]     factors;
        uint256[]     eval_map;
        uint256[][]   unique_eval_points;
        uint256       different_points;
        uint256[]     ys;
        uint256[]     final_polynomial;         // It's loaded once while parsing fri proof
        uint256[]     fri_roots;                // It should be bytes32
    }

    struct fri_state_type {
        bytes   b;
        //0x0
        uint256 x_index;
        //0x20
        uint256 x;
        //0x40
        uint256 domain_size;
        //0x60
        uint256 domain_size_mod;
        //0x80
        uint256 newind;
        //0xa0
        uint256 p_ind;
        //0xc0
        uint256 y_ind;
        //0xe0
        uint256 indices_size;
        //0x100
        uint256 b_length;
        //0x120
        uint256 query_id;
        //0x140
        uint256[] alphas;
        uint256[] values;
        uint256[] tmp_values;
        uint256 coset_size;
        uint256 offset;
        uint256 root;
        uint256 fri_root;
        uint256 s;
        uint256 step;
        uint256 round;
        uint256[] point;
        uint256 cur;
        uint256 interpolant;
        uint256 f0;
        uint256 f1;
        uint256 factor;
    }

    struct placeholder_proof_map {
        // 0x0
        uint256 variable_values_commitment_offset;
        // 0x20
        uint256 v_perm_commitment_offset;
        // 0x40
        uint256 T_commitment_offset;
        // 0x60
        uint256 fixed_values_commitment_offset;
        // 0x80
        uint256 eval_proof_offset;
        // 0xa0
        uint256 eval_proof_lagrange_0_offset;
        // 0xc0
        uint256 eval_proof_combined_value_offset;
    }

    struct placeholder_common_data {
        uint256 rows_amount;
        // 0x20
        uint256 omega;
        int256[ROWS_ROTATION][COLS_ROTATION] columns_rotations;
    }

    struct placeholder_state_type {
        // 0x0
        uint256 len;
        // 0x20
        uint256 offset;
        // 0x40
        uint256 zero_index;
        // 0x60
        uint256[] permutation_argument;
        // 0x80
        uint256 gate_argument;
        // 0xa0
        uint256[] alphas;
        // 0xc0
        uint256 challenge;
        // 0xe0
        uint256 e;
        // 0x100
        uint256[][][] evaluation_points;
        // 0x120
        uint256[] F;
        // 0x140
        uint256 F_consolidated;
        // 0x160
        uint256 T_consolidated;
        // 0x180
        uint256 Z_at_challenge;
        // 0x1a0
        uint256 beta;
        // 0x1c0
        uint256 gamma;
        // 0x1e0
        uint256 g;
        // 0x200
        uint256 h;
        // 0x220
        uint256 perm_polynomial_value;
        // 0x240
        uint256 perm_polynomial_shifted_value;
        // 0x260
        uint256 q_blind_eval;
        // 0x280
        uint256 q_last_eval;
        // 0x2a0
        uint256 S_id_i;
        // 0x2c0
        uint256 S_sigma_i;
        // 0x2e0
        uint256[] roots;
        // 0x300
        uint256 tmp1;
        // 0x320
        uint256 tmp2;
        // 0x340
        uint256 tmp3;
        // 0x360
        uint256 idx1;
        // 0x380
        uint256 idx2;
        // 0x3a0
        uint256 inversed_omega;
    }

    struct arithmetization_params{
        uint256 witness_columns;
        uint256 public_input_columns;
        uint256 constant_columns;
        uint256 selector_columns;
        uint256 lookup_table_size;

        // computed from other params
        uint256 permutation_columns;
    }

    // parameters are sent to gate argument
    struct gate_argument_params {
        // 0x0
        uint256 modulus;
        // 0x20
        uint256 theta;
    }
}


// File contracts/containers/merkle_verifier.sol


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
        //bytes memory read_bytes = blob[read_offset_st:read_offset_st + WORD_SIZE];
        bytes32 memory read_bytes = getBytes32(blob,read_offset_st);
        uint256 read_offset_uint = uint256(read_bytes);
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
        bytes32 memory read_offset = getBytes32(blob,read_offset_st);
        uint256 read_offset_uint = uint256(read_offset);
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
        //uint256 depth = uint256(bytes32(blob[depth_offset_bytes : depth_offset_bytes+  WORD_SIZE])) >> LENGTH_RESTORING_SHIFT ;
        uint256 depth = uint256(getBytes32(blob,depth_offset_bytes)) >> LENGTH_RESTORING_SHIFT ;

        uint256 layer_pos_offset_bytes = (offset/8) + LAYERS_OFFSET + LAYER_POSITION_OFFSET;
        //uint256 pos = uint256(bytes32(blob[layer_pos_offset_bytes : layer_pos_offset_bytes+  WORD_SIZE])) >> LENGTH_RESTORING_SHIFT ;
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
            uint256 layer_offset_st = layer_offset + LAYER_POSITION_OFFSET;
            //pos = uint256(bytes32(blob[layer_offset_st : layer_offset_st + WORD_SIZE])) >> LENGTH_RESTORING_SHIFT;
            pos = uint256(getBytes32(blob,layer_offset_st) >> LENGTH_RESTORING_SHIFT;

            uint256 next_pos_offset =  layer_offset + LAYER_POSITION_OFFSET + LAYER_OCTETS;
            //next_pos = uint256(bytes32(blob[next_pos_offset: next_pos_offset + WORD_SIZE])) >> LENGTH_RESTORING_SHIFT;
            next_pos = uint256(getBytes32(blob,next_pos_offset)) >> LENGTH_RESTORING_SHIFT;

            if (pos==0){
                uint256 start_offset = layer_offset + LAYER_COPATH_HASH_OFFSET;
                //leafNodes[0] = bytes32(blob[start_offset : start_offset + WORD_SIZE]);
                leafNodes[0] = getBytes32(blob,start_offset);

                if(next_pos==0){
                    leafNodes[1] = getKeccak256LeafNodes(leafNodes);
                } else if (next_pos ==1){
                    leafNodes[0] = getKeccak256LeafNodes(leafNodes);
                }
            } else if (pos ==1) {
                uint256 start_offset = layer_offset + LAYER_COPATH_HASH_OFFSET;
                //leafNodes[1] = bytes32(blob[start_offset : start_offset + WORD_SIZE]);
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
        //pos = uint256(bytes32(blob[start_offset : start_offset + WORD_SIZE])) >> LENGTH_RESTORING_SHIFT;
        pos = uint256(getBytes32(blob,start_offset)) >> LENGTH_RESTORING_SHIFT;

        if (pos == 0){
            uint256 _offset = layer_offset + LAYER_COPATH_HASH_OFFSET;
            //leafNodes[0] = bytes32(blob[_offset : _offset + WORD_SIZE]);
            leafNodes[0] = getBytes32(blob,_offset);
            verified_data = getKeccak256LeafNodes(leafNodes);

        } else if (pos ==1){
            uint256 _offset = layer_offset + LAYER_COPATH_HASH_OFFSET;
            //leafNodes[1] = bytes32(blob[_offset : _offset + WORD_SIZE]);
            leafNodes[1] = getBytes32(blob,_offset);
            verified_data = getKeccak256LeafNodes(leafNodes);
        }

        bytes32 root;
        uint256 _root_offset = (offset/8) + ROOT_OFFSET;
        //root = bytes32(blob[_root_offset : _root_offset + WORD_SIZE]);
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
         //root = uint256(bytes32(blob[merkle_proof_offset_bytes : merkle_proof_offset_bytes + WORD_SIZE]));
         root = uint256(getBytes32(blob,merkle_proof_offset_bytes));
//        assembly {
//            root := calldataload(add(blob.offset, add(merkle_root_offset, 0x8)))
//        }
    }

    // TODO: This function should return bytes32
    function get_merkle_root_from_proof(bytes calldata blob, uint256 merkle_proof_offset)
    internal pure returns(uint256 root){
        uint256 merkle_proof_offset_bytes = (merkle_proof_offset/8) + ROOT_OFFSET;
        //root = uint256(bytes32(blob[merkle_proof_offset_bytes : merkle_proof_offset_bytes + WORD_SIZE]));
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


// File contracts/cryptography/transcript.sol


pragma solidity >=0.8.4;

/**
 * @title Transcript library
 * @dev Generates Plonk random challenges
 */
library transcript {
    uint256 constant WORD_SIZE = 4;
    function init_transcript(types.transcript_data memory self, bytes memory init_blob)
    internal pure {
        self.current_challenge = keccak256(init_blob);
    }

    function update_transcript(types.transcript_data memory self, bytes memory blob)
    internal pure {
        self.current_challenge = keccak256(bytes.concat(self.current_challenge, blob));
    }

    function update_transcript_b32(types.transcript_data memory self, bytes32 blob)
    internal pure {
        self.current_challenge = keccak256(
            bytes.concat(self.current_challenge, blob)
        );
    }

    function update_transcript_b32_by_offset_calldata(types.transcript_data memory self, bytes calldata blob,
                                                      uint256 offset)
    internal pure {
        require(offset < blob.length, "update_transcript_b32_by_offset: offset < blob.length");
        require(32 <= blob.length - offset, "update_transcript_b32_by_offset: 32 <= blob.length - offset");

        bytes32 blob32;
        offset = (offset/8);
        //blob32 = bytes32(blob[offset : offset + WORD_SIZE]);
        blob32 = getBytes32(blob,offset);
//        assembly {
//            blob32 := calldataload(add(blob.offset, offset))
//        }
        update_transcript_b32(self, blob32);
    }

    function get_integral_challenge_be(types.transcript_data memory self, uint256 length)
    internal pure returns (uint256 result) {
        require(length <= 32);
        self.current_challenge = keccak256(abi.encodePacked(self.current_challenge));
        return (uint256(self.current_challenge) &
               (((uint256(1) << (length * 8)) - 1) << (uint256(256) - length * 8))) >> (uint256(256) - length * 8);
    }

    function get_field_challenge(types.transcript_data memory self, uint256 modulus)
    internal pure returns (uint256) {
        self.current_challenge = keccak256(abi.encode(self.current_challenge));
        return uint256(self.current_challenge) % modulus;
    }

    function get_field_challenges(types.transcript_data memory self, uint256[] memory challenges, uint256 modulus)
    internal pure {
        if (challenges.length > 0) {
            bytes32 new_challenge = self.current_challenge;
            for (uint256 i = 0; i < challenges.length;) {
                new_challenge = keccak256(abi.encode(new_challenge));
                challenges[i] = uint256(new_challenge) % modulus;
                unchecked{ i++; }
            }
            self.current_challenge = new_challenge;
        }
    }
}


// File contracts/commitments/batched_fri_verifier.sol






library batched_fri_verifier {
    uint256 constant FRI_PARAMS_COEFFS_OFFSET = 0x280;

    uint256 constant S1_OFFSET = 0x00;                                      
    uint256 constant X_OFFSET = 0x20;                                      
    uint256 constant ALPHA_OFFSET = 0x40;                                   // alpha challenge
    uint256 constant COEFFS_OFFSET = 0x60;
    uint256 constant Y_OFFSET = 0x80;
    uint256 constant COLINEAR_OFFSET = 0xa0;                                // colinear_value_offset
    uint256 constant C1_OFFSET = 0xc0;                                      // coefficient1_offset
    uint256 constant C2_OFFSET = 0xe0;                                      // coefficient2_offset
    uint256 constant INTERPOLANT_OFFSET = 0x100;
    uint256 constant PREV_COEFFS_LEN_OFFSET = 0x120;
    uint256 constant WORD_SIZE = 4;

    uint256 constant m = 2;

    function skip_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset) {
        // fri_roots
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        for (uint256 i = 0; i < value_len;) {
            result_offset = basic_marshalling.skip_octet_vector_32_be(result_offset);
            unchecked{ i++; }
        }
        // final_polynomial
        result_offset = basic_marshalling.skip_vector_of_uint256_be(blob, result_offset);
        // query_proofs
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        for (uint256 i = 0; i < value_len;) {
            result_offset = skip_query_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function parse_proof_be(types.fri_params_type memory fri_params, bytes calldata blob, uint256 offset)
    internal pure returns (bool success, uint256 result_offset) {
        success = true;
        // fri_roots
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        if( value_len != fri_params.step_list.length ){
            success = false;
            return(success, result_offset);
        }
        fri_params.fri_roots = new uint256[](value_len);
        for (uint256 i = 0; i < value_len;) {
            fri_params.fri_roots[i] = basic_marshalling.get_uint256_be(blob, basic_marshalling.skip_length(result_offset));
            result_offset = basic_marshalling.skip_octet_vector_32_be(result_offset);
            unchecked{ i++; }
        }
        // final_polynomial
        fri_params.fri_final_poly_offset = result_offset;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);

        if( value_len > (( 1 << (field.log2(fri_params.max_degree + 1) - fri_params.r + 1) ) ) ){
            success = false;
            return(success, result_offset);
        }

        fri_params.final_polynomial = new uint256[](value_len);
        for (uint256 i = 0; i < value_len;) {
            fri_params.final_polynomial[i] = basic_marshalling.get_uint256_be(blob, result_offset);
            result_offset = basic_marshalling.skip_uint256_be(result_offset);
            unchecked{ i++; }
        }

        // query_proofs
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        fri_params.fri_cur_query_offset = result_offset;
        if( value_len != fri_params.lambda ) {
            success = false;
            return(success, result_offset);
        }

        for (uint256 i = 0; i < value_len;) {
            (success, result_offset) = parse_query_proof_be(fri_params, blob, result_offset);
            if(!success) return(success, result_offset);
            unchecked{ i++; }
        }
    }

    function skip_query_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns (uint256 result_offset){
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        for(uint256 i = 0; i < value_len;){
            result_offset = skip_initial_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        for(uint256 i = 0; i < value_len;){
            result_offset = skip_round_proof_be(blob, result_offset);
            unchecked{ i++; }
        }
    }

    function parse_query_proof_be(types.fri_params_type memory fri_params, bytes calldata blob, uint256 offset)
    internal pure returns (bool success, uint256 result_offset){
        success = true;
        uint256 value_len;
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, offset);
        if( value_len != fri_params.batches_sizes.length ){
            success = false;
            return( success, result_offset);
        }

        for(uint256 i = 0; i < value_len;){
            (success, result_offset) = parse_initial_proof_be(fri_params, i, blob, result_offset);
            if( !success ) return(success, result_offset );
            unchecked{ i++; }
        }
        (value_len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        if( value_len != fri_params.step_list.length){
            success = false;
            return( success, result_offset);
        }
        for(uint256 i = 0; i < value_len;){
            (success, result_offset) = parse_round_proof_be(fri_params, i, blob, result_offset);
            if( !success ) return(success, result_offset );
            unchecked{ i++; }
        }
    }

    function skip_initial_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns(uint256 result_offset){
        // p;
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // polynomials num
        result_offset = basic_marshalling.skip_length(result_offset);
        // coset_size
        result_offset = basic_marshalling.skip_length(result_offset);
        result_offset = basic_marshalling.skip_vector_of_uint256_be(blob, result_offset);
    }

    function parse_initial_proof_be(types.fri_params_type memory fri_params, uint256 i, bytes calldata blob, uint256 offset)
    internal pure returns(bool success, uint256 result_offset){
        success = true;
        // p;
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // polynomials num
        uint256 len;
        (len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        if( len != fri_params.batches_sizes[i] ) {
            success = false;
            return(success, result_offset);
        }
        // coset_size
        (len, result_offset) = basic_marshalling.get_skip_length(blob, result_offset);
        if( len != (1 << fri_params.step_list[0]) ) {
            success = false;
            return(success, result_offset);
        }
        // values
        len = basic_marshalling.get_length(blob, result_offset);
        result_offset = basic_marshalling.skip_vector_of_uint256_be(blob, result_offset);
        if(len != fri_params.batches_sizes[i] * (1 << fri_params.step_list[0])){
            success = false;
            return(success, result_offset);
        }
    }

    function skip_round_proof_be(bytes calldata blob, uint256 offset)
    internal pure returns(uint256 result_offset){
        // p;
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // y;
        result_offset = basic_marshalling.skip_vector_of_uint256_be(blob, result_offset);
    }

    function parse_round_proof_be(types.fri_params_type memory fri_params, uint256 i, bytes calldata blob, uint256 offset)
    internal pure returns(bool success, uint256 result_offset){
        success = true;
        // p;
        result_offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        // y;
        if( i < fri_params.step_list.length - 1){
            if( basic_marshalling.get_length(blob, result_offset) != (1 << fri_params.step_list[i+1]) ){
                success = false;
                return(success, result_offset);
            }
        }else{
            if( basic_marshalling.get_length(blob, result_offset) != 2 ){
                success = false;
                return( success, result_offset);
            }
        }
        result_offset = basic_marshalling.skip_vector_of_uint256_be(blob, result_offset);
    }

    // Use this hack only for lpc test(!)
    // Call this function only after fri_params is completely initialized by parse* functions.
    function extract_merkle_roots(bytes calldata blob, types.fri_params_type memory fri_params) 
    internal pure returns(uint256[] memory roots){
        roots = new uint256[](fri_params.batches_num);
        uint256 offset = fri_params.fri_cur_query_offset;
        offset = basic_marshalling.skip_length(offset);
        for( uint256 i = 0; i < fri_params.batches_num;){
            roots[i] = merkle_verifier.get_merkle_root_from_proof(blob, offset);
            offset = skip_initial_proof_be(blob, offset);
            unchecked{ i++; }
        }
    }

    // if x_index is index of x, then paired_index is index of -x
    function get_paired_index(uint256 x_index, uint256 domain_size)
    internal pure returns(uint256 result ){
        unchecked{ result = (x_index + (domain_size >> 1)) & (domain_size - 1); }
    }

    // calculate indices for coset S = {s\in D| s^(2^fri_step) == x_next}
    function get_folded_index(uint256 x_index, uint256 fri_step, uint256 domain_size_mod) 
    internal pure returns(uint256 result){
        unchecked{result = x_index & (domain_size_mod >> fri_step);}
    }
  
    function calculate_s(
        types.fri_params_type memory fri_params,
        types.fri_state_type memory local_vars) internal pure{

        fri_params.s[0] = local_vars.x;
        if( local_vars.coset_size > 1){
            uint256 base_index = local_vars.domain_size >> 2; 
            uint256 prev_half_size = 1;
            uint256 i = 1;
            uint256 j;
            local_vars.newind = fri_params.D_omegas.length - 1;
            while( i < local_vars.coset_size ){
                for( j = 0; j < prev_half_size;) {
                    fri_params.s[i] = field.fmul(fri_params.s[j], fri_params.D_omegas[local_vars.newind], fri_params.modulus);
                    unchecked{ i++; } // TODO: is it really here? Yes, it is))
                    unchecked{ j++; }
                }
                unchecked{
                    base_index >>=1;
                    prev_half_size <<=1;
                    local_vars.newind--;
                }
            }
        }
    }




    function prepare_initial_leaf_data(
        bytes calldata blob,
        uint256 offset,
        uint256 k,                                              // current batch index
        types.fri_params_type memory fri_params,
        types.fri_state_type memory local_vars
    ) internal pure {
        uint256 base_index;
        uint256 prev_half_size;
        uint256 i;
        uint256 j;

        local_vars.indices_size = 1 << (fri_params.step_list[0] - 1);
        
        fri_params.s_indices[0] = local_vars.x_index;
        fri_params.s[0] = local_vars.x;
        fri_params.tmp_arr[0] = get_folded_index(local_vars.x_index, fri_params.step_list[0], local_vars.domain_size_mod);

        // Fill s and s_indices
        if( local_vars.indices_size > 1){
            unchecked{
                base_index = local_vars.domain_size >> 2; 
                prev_half_size = 1;
                i = 1;
                local_vars.newind = fri_params.D_omegas.length - 1;
            }
            while( i < local_vars.indices_size ){
                for( j = 0; j < prev_half_size;) {
                    unchecked{
                        fri_params.s_indices[i] = (base_index + fri_params.s_indices[j]) & local_vars.domain_size_mod;
                        fri_params.tmp_arr[i]   = (base_index + fri_params.tmp_arr[j]) & local_vars.domain_size_mod;
                    }
                    fri_params.s[i] = field.fmul(fri_params.s[j], fri_params.D_omegas[local_vars.newind], fri_params.modulus);
                    unchecked{ i++; } // TODO: is it really here? Yes, it is))
                    unchecked{ j++; }
                }
                unchecked{
                    base_index >>=1;
                    prev_half_size <<=1;
                    local_vars.newind--;
                }
            }
        }

        // Fill correct_order_idx
        for ( i = 0; i < local_vars.indices_size;) {
            for(j = 0; j < local_vars.indices_size;){
                if(fri_params.s_indices[j] == fri_params.tmp_arr[i]){
                    local_vars.newind = j;
                    break;
                }
                if(get_paired_index(fri_params.s_indices[j], local_vars.domain_size) == fri_params.tmp_arr[i]){
                    local_vars.newind = j;
                    break;
                }
                unchecked{ j++; }
            }
            fri_params.correct_order_idx[i] = local_vars.newind;
            unchecked{ i++; }
        }

        uint256 first_offset = 4;

        uint256 y_offset;

        offset = merkle_verifier.skip_merkle_proof_be(blob, offset);
        offset = basic_marshalling.skip_length(offset);             // Skip polynomial number
        offset = basic_marshalling.skip_length(offset);             // Skip coset size
        offset = basic_marshalling.skip_length(offset);             // Skip y length
        for (local_vars.p_ind = 0; local_vars.p_ind < fri_params.batches_sizes[k];) {
            for(local_vars.y_ind = 0; local_vars.y_ind < local_vars.indices_size;){
                local_vars.newind = fri_params.correct_order_idx[local_vars.y_ind];
                // Check leaf size
                // Prepare y-s
                unchecked{ y_offset = offset + ( local_vars.newind << 6 ); }

                // push y
                if(fri_params.s_indices[local_vars.newind] == fri_params.tmp_arr[local_vars.y_ind]){
                    bytes memory data_to_copy = blob[y_offset: y_offset + WORD_SIZE];
                    basic_marshalling.write_bytes(local_vars.b , first_offset, data_to_copy);
//                    assembly{
//                        mstore(
//                            add(mload(local_vars),first_offset),
//                            calldataload(add(blob.offset, y_offset))
//                        )
                     data_to_copy = blob[y_offset + WORD_SIZE : y_offset + WORD_SIZE + WORD_SIZE];
                     basic_marshalling.write_bytes(local_vars.b , first_offset + WORD_SIZE, data_to_copy);
//                        mstore(
//                            add(mload(local_vars),add(first_offset, 0x20)),
//                            calldataload(add(blob.offset, add(y_offset, 0x20)))
//                        )
//                    }
                } else {
                    bytes memory data_to_copy = blob[y_offset + WORD_SIZE : y_offset + WORD_SIZE + WORD_SIZE];
                    basic_marshalling.write_bytes(local_vars.b , first_offset, data_to_copy);
//                    assembly{
//                        mstore(
//                            add(mload(local_vars),first_offset),
//                            calldataload(add(blob.offset, add(y_offset, 0x20)))
//                        )
                    data_to_copy = blob[y_offset:y_offset + WORD_SIZE];
                    basic_marshalling.write_bytes(local_vars.b , first_offset + WORD_SIZE, data_to_copy);
//                        mstore(
//                            add(mload(local_vars),add(first_offset, 0x20)),
//                            calldataload(add(blob.offset, y_offset))
//                        )
//                    }
                }
                unchecked{ 
                    local_vars.y_ind++; 
                    first_offset += 8;
                }
            }
            unchecked{ offset += (1<<(fri_params.step_list[0]+5)); local_vars.p_ind++; }
        }
    }

    // For round proofs
    //     Reorder local_vars.values and push to local_vars.b
    function prepare_leaf_data(
        bytes calldata blob,
        uint256 offset,                                         // round proof offset
        types.fri_params_type memory fri_params,
        types.fri_state_type memory local_vars
    ) internal pure {
        uint256 base_index;
        uint256 prev_half_size;
        uint256 i;
        uint256 j;

        local_vars.indices_size = 1 << (fri_params.step_list[local_vars.step] - 1);
        
        fri_params.s_indices[0] = local_vars.x_index;
        fri_params.s[0] = local_vars.x;
        fri_params.tmp_arr[0] = get_folded_index(local_vars.x_index, fri_params.step_list[local_vars.step], local_vars.domain_size_mod);

        // Fill s and s_indices
        if( local_vars.indices_size > 1){
            unchecked{
                base_index = local_vars.domain_size >> 2; 
                prev_half_size = 1;
                i = 1;
                local_vars.newind = fri_params.D_omegas.length - 1;
            }
            while( i < local_vars.indices_size ){
                for( j = 0; j < prev_half_size;) {
                    unchecked{
                        fri_params.s_indices[i] = (base_index + fri_params.s_indices[j]) & local_vars.domain_size_mod;
                        fri_params.tmp_arr[i]   = (base_index + fri_params.tmp_arr[j]) & local_vars.domain_size_mod;
                    }
                    fri_params.s[i] = field.fmul(fri_params.s[j], fri_params.D_omegas[local_vars.newind], fri_params.modulus);
                    unchecked{ i++; } // TODO: is it really here? Yes, it is))
                    unchecked{ j++; }
                }
                unchecked{
                    base_index >>=1;
                    prev_half_size <<=1;
                    local_vars.newind--;
                }
            }
        }

        // Fill correct_order_idx
        for ( i = 0; i < local_vars.indices_size;) {
            for(j = 0; j < local_vars.indices_size;){
                if(fri_params.s_indices[j] == fri_params.tmp_arr[i]){
                    local_vars.newind = j;
                    break;
                }
                if(get_paired_index(fri_params.s_indices[j], local_vars.domain_size) == fri_params.tmp_arr[i]){
                    local_vars.newind = j;
                    break;
                }
                unchecked{ j++; }
            }
            fri_params.correct_order_idx[i] = local_vars.newind;
            unchecked{ i++; }
        }

        bytes memory y;
        offset = 4;
        for(local_vars.y_ind = 0; local_vars.y_ind < local_vars.indices_size;){
            local_vars.newind = fri_params.correct_order_idx[local_vars.y_ind];
            // Check leaf size
            // Prepare y-s

            // push y
            if(fri_params.s_indices[local_vars.newind] == fri_params.tmp_arr[local_vars.y_ind]){
                y = basic_marshalling.to_bytes(local_vars.values[local_vars.newind<<1]);
                basic_marshalling.write_bytes(local_vars.b,offset,y);
//                assembly{
//                    mstore(
//                        add(mload(local_vars), offset), y
//                    )
//                }
                  y = basic_marshalling.to_bytes(local_vars.values[(local_vars.newind<<1)+1]);
                  basic_marshalling.write_bytes(local_vars.b, offset + WORD_SIZE, y);
//                assembly{
//                    mstore(
//                        add(mload(local_vars),add(offset, 0x20)), y
//                    )
//                }
            } else {
                  y = basic_marshalling.to_bytes(local_vars.values[(local_vars.newind<<1)+1]);
                  basic_marshalling.write_bytes(local_vars.b, offset,y);
//                assembly{
//                    mstore(
//                        add(mload(local_vars), offset), y
//                    )
//                }
                 y = basic_marshalling.to_bytes(local_vars.values[local_vars.newind<<1]);
                basic_marshalling.write_bytes(local_vars.b, offset + WORD_SIZE,y);
//                assembly{
//                    mstore(
//                        add(mload(local_vars),add(offset, 0x20)), y
//                    )
//                }
            }
            unchecked{ 
                local_vars.y_ind++; 
                offset += (WORD_SIZE * 2);
            }
        }
    }

    function clear_values( uint256[] memory values )
    internal pure{
        for( uint256 i = 0; i < values.length;){
            values[i] = 0;
            unchecked{ i++; }
        }
    }

    function load_values( bytes calldata blob, uint256 offset, types.fri_state_type memory local_vars )
    internal pure{
        uint256 len;
        (len, offset) = basic_marshalling.get_skip_length(blob, offset);
        for( uint256 i = 0; i < len;){
            local_vars.values[i] = basic_marshalling.get_uint256_be(blob, offset);
            offset = basic_marshalling.skip_uint256_be(offset);
            unchecked{i++;}
        }
    }

    function verify_proof_be(
        bytes calldata blob, 
        uint256[] memory roots,
        types.transcript_data memory tr_state,
        types.fri_params_type memory fri_params
    ) internal view returns (bool result) {
        types.fri_state_type memory local_vars;

        // TODO strange bug. If we we exchange two next lines, then it will not work.
        local_vars.alphas = new uint256[](fri_params.r);
        local_vars.b = new bytes(0x40 * fri_params.max_batch * fri_params.max_coset);

        uint256 offset;
        uint256 ind;
        uint256 k;
        uint256 i;

        offset = basic_marshalling.skip_length(fri_params.fri_proof_offset);
        offset = basic_marshalling.skip_length(offset);
        for( ind = 0; ind < fri_params.step_list.length;){
            transcript.update_transcript_b32_by_offset_calldata(tr_state, blob, offset);
            for( uint256 round = 0; round < fri_params.step_list[ind];){
                local_vars.alphas[local_vars.cur] = transcript.get_field_challenge(tr_state, fri_params.modulus);
                unchecked{ round++; local_vars.cur++;}
            }
            offset = basic_marshalling.skip_octet_vector_32_be(offset);
            unchecked{ind++;}
        }

        for( local_vars.query_id = 0; local_vars.query_id < fri_params.lambda;){
            // It'll be init_vars function next
            unchecked{ local_vars.domain_size = 1 << (fri_params.D_omegas.length + 1); }
            unchecked{ local_vars.domain_size_mod = local_vars.domain_size - 1; }
            local_vars.x_index = transcript.get_integral_challenge_be(tr_state, 8) & local_vars.domain_size_mod;
            local_vars.x = field.expmod_static(
                fri_params.D_omegas[0],
                local_vars.x_index,
                fri_params.modulus
            );

            // Check initial proofs
            offset = basic_marshalling.skip_length(fri_params.fri_cur_query_offset);
            for( k = 0; k < fri_params.batches_num;){
                // Check merkle local_vars.roots
                local_vars.root = merkle_verifier.get_merkle_root_from_proof(blob, offset);
                if( local_vars.root != roots[k] ){
                    return false;
                }
                prepare_initial_leaf_data(blob, offset, k, fri_params, local_vars);
                local_vars.b_length = (fri_params.batches_sizes[k] << (fri_params.step_list[0] +5));
                if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                    blob, offset, local_vars.b, local_vars.b_length
                )) {
                    return false;
                }
                offset = skip_initial_proof_be(blob, offset);
                // Check merkle proofs
                unchecked{k++;}
            }

            // Construct ys for the first round
            local_vars.coset_size = 1 << fri_params.step_list[0];
            local_vars.values = new uint256[](1 << fri_params.max_step);
            local_vars.tmp_values = new uint256[](1 << fri_params.max_step);

            for( ind = 0; ind < fri_params.different_points;){                
                offset = basic_marshalling.skip_length(fri_params.fri_cur_query_offset);
                offset = merkle_verifier.skip_merkle_proof_be(blob,offset);
                offset = basic_marshalling.skip_length(offset);
                offset = basic_marshalling.skip_length(offset);
                offset = basic_marshalling.skip_length(offset);
                clear_values(local_vars.tmp_values);
                local_vars.cur = 0;
                for( k = 0; k < fri_params.batches_num;){
                    for( i = 0; i < fri_params.batches_sizes[k];){
                        polynomial.multiply_poly_on_coeff(local_vars.tmp_values,fri_params.theta, fri_params.modulus);
                        if( fri_params.eval_map[local_vars.cur] == ind ){
                            for( uint256 j = 0; j < local_vars.coset_size;){
                                local_vars.tmp_values[j] = addmod(
                                    local_vars.tmp_values[j], 
                                    basic_marshalling.get_uint256_be(blob, offset),
                                    fri_params.modulus
                                );
                                offset = basic_marshalling.skip_uint256_be(offset);
                                unchecked{ j++; }
                            }
                        } else {
                            offset += (local_vars.coset_size << 5);
                        }
                        unchecked{ i++; local_vars.cur++;} 
                    }
                    offset = merkle_verifier.skip_merkle_proof_be(blob,offset);
                    offset = basic_marshalling.skip_length(offset);
                    offset = basic_marshalling.skip_length(offset);
                    offset = basic_marshalling.skip_length(offset);
                    unchecked{ k++; }
                }

                for( uint256 j = 0; j < local_vars.coset_size; j++){
                    if( j & 1 == 0 )
                        { local_vars.s = fri_params.s[j>>1];}
                    else
                        { local_vars.s = fri_params.modulus - fri_params.s[j>>1];}
                    local_vars.tmp_values[j] = addmod(
                        mulmod( local_vars.tmp_values[j], fri_params.factors[ind], fri_params.modulus),
                        fri_params.modulus - polynomial.evaluate(fri_params.combined_U[ind], local_vars.s, fri_params.modulus),
                        fri_params.modulus
                    );
                    // TODO Denominators for all s can be precomputed. It doesn't depend on polynomial.
                    local_vars.tmp_values[j] = mulmod(
                        local_vars.tmp_values[j],
                        field.inverse_static(
                            polynomial.evaluate(fri_params.denominators[ind], local_vars.s, fri_params.modulus),
                            fri_params.modulus
                        ),
                        fri_params.modulus
                    );
                    local_vars.values[j] = addmod(local_vars.values[j], local_vars.tmp_values[j], fri_params.modulus);
                }
                unchecked{ind++;}
            }

            offset = basic_marshalling.skip_length(fri_params.fri_cur_query_offset);
            for( k = 0; k < fri_params.batches_num; ){
                offset = skip_initial_proof_be(blob, offset);
                unchecked{k++;}
            }

            // Round proofs check
            local_vars.cur = 0;
            offset = basic_marshalling.skip_length(offset);

            for( local_vars.step = 0; local_vars.step < fri_params.step_list.length;){
                // Merkle check;
                local_vars.fri_root = basic_marshalling.get_uint256_be(blob, basic_marshalling.skip_length(offset) + 0x8);
                if( local_vars.fri_root != fri_params.fri_roots[local_vars.step]) {
                    return false;
                }

                local_vars.coset_size = 1 << fri_params.step_list[local_vars.step];
                prepare_leaf_data(blob, offset, fri_params, local_vars);
                local_vars.b_length = (1 << (fri_params.step_list[local_vars.step] + 5));
                if (!merkle_verifier.parse_verify_merkle_proof_bytes_be(
                    blob, offset, local_vars.b, local_vars.b_length
                )) {
                    return false;
                }

                // Colinear check;
                local_vars.factor = 1;
                for( local_vars.round = 0; local_vars.round < fri_params.step_list[local_vars.step];){
                    local_vars.coset_size >>= 1;
                    calculate_s(fri_params, local_vars);
                    local_vars.domain_size >>= 1;
                    local_vars.domain_size_mod >>= 1;
                    local_vars.x_index &= local_vars.domain_size_mod;
                    local_vars.x = mulmod(local_vars.x, local_vars.x, fri_params.modulus);
                    if( local_vars.round == 0){
                        for( uint256 j = 0; j < local_vars.coset_size;){
                            local_vars.f0 = local_vars.values[j<<1];
                            local_vars.f1 = local_vars.values[(j<<1) + 1];
                            local_vars.values[j] = addmod(local_vars.f0, local_vars.f1, fri_params.modulus);
                            local_vars.values[j] = mulmod(local_vars.values[j], fri_params.s[j], fri_params.modulus);
                            local_vars.values[j] = addmod(
                                local_vars.values[j], 
                                mulmod(
                                    local_vars.alphas[local_vars.cur],
                                    addmod(local_vars.f0, fri_params.modulus-local_vars.f1, fri_params.modulus), 
                                    fri_params.modulus
                                ),
                                fri_params.modulus
                            );
                            local_vars.values[j] = mulmod(
                                local_vars.values[j], 
                                fri_params.s[j],
                                fri_params.modulus
                            );
                            unchecked{ j++; }
                        }
                        local_vars.factor = mulmod(local_vars.factor, 2, fri_params.modulus);
                    } else {
                        for( uint256 j = 0; j < local_vars.coset_size;){
                            local_vars.f0 = local_vars.values[j<<1];
                            local_vars.f1 = local_vars.values[(j<<1) + 1];
                            local_vars.values[j] = addmod(local_vars.f0, fri_params.modulus - local_vars.f1, fri_params.modulus);
                            local_vars.values[j] = mulmod(local_vars.values[j], fri_params.s[j], fri_params.modulus);
                            local_vars.values[j] = addmod(
                                local_vars.values[j], 
                                mulmod(
                                    local_vars.alphas[local_vars.cur],
                                    addmod(local_vars.f0, local_vars.f1, fri_params.modulus), 
                                    fri_params.modulus
                                ),
                                fri_params.modulus
                            );
                            unchecked{ j++; }
                        }
                        local_vars.factor = mulmod(local_vars.factor, 2, fri_params.modulus);
                    }
                    unchecked{local_vars.round++; local_vars.cur++;}
                }
                local_vars.factor = mulmod(local_vars.factor, fri_params.s[0], fri_params.modulus);
                local_vars.factor = mulmod(local_vars.factor, fri_params.s[0], fri_params.modulus);
                local_vars.interpolant = local_vars.values[0];

                offset = merkle_verifier.skip_merkle_proof_be(blob,offset);
                load_values(blob, offset, local_vars);
                if( local_vars.interpolant != mulmod(local_vars.factor, local_vars.values[0], fri_params.modulus) ){
                    return false;
                }
                offset = basic_marshalling.skip_vector_of_uint256_be(blob, offset);
                unchecked{local_vars.step++;}
            }

            // Final polynomial check. Final polynomial degree is already checked while parsing process
            if( polynomial.evaluate(fri_params.final_polynomial, local_vars.x, fri_params.modulus) != local_vars.values[0]){
                return false;
            }
            if( polynomial.evaluate(fri_params.final_polynomial, fri_params.modulus-local_vars.x, fri_params.modulus) != local_vars.values[1]){
                return false;
            }
            
            fri_params.fri_cur_query_offset = skip_query_proof_be(blob, fri_params.fri_cur_query_offset);
            unchecked{local_vars.query_id++;}
        }
        return true;
    }
}


// File contracts/commitments/batched_lpc_verifier.sol






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


// File contracts/interfaces/gate_argument.sol


interface IGateArgument {
    function evaluate_gates_be(bytes calldata blob,
        uint256 eval_proof_combined_value_offset,
        types.gate_argument_params memory gate_params,
        types.arithmetization_params memory ar_params,
        int256[ROWS_ROTATION][COLS_ROTATION] calldata columns_rotations
    ) external pure returns (uint256 gates_evaluation);
}


// File contracts/placeholder/permutation_argument.sol


library permutation_argument {
    uint256 constant ARGUMENT_SIZE = 3;

    uint256 constant EVAL_PROOF_LAGRANGE_0_OFFSET_OFFSET = 0xa0;

    uint256 constant LEN_OFFSET = 0x0;
    uint256 constant OFFSET_OFFSET = 0x20;
    uint256 constant ZERO_INDEX_OFFSET = 0x40;
    uint256 constant PERMUTATION_ARGUMENT_OFFSET = 0x60;
    uint256 constant GATE_ARGUMENT_OFFSET = 0x80;
    uint256 constant ALPHAS_OFFSET = 0xa0;
    uint256 constant CHALLENGE_OFFSET = 0xc0;
    uint256 constant E_OFFSET = 0xe0;
    uint256 constant EVALUATION_POINTS_OFFSET = 0x100;
    uint256 constant F_OFFSET = 0x120;
    uint256 constant F_CONSOLIDATED_OFFSET = 0x140;
    uint256 constant T_CONSOLIDATED_OFFSET = 0x160;
    uint256 constant Z_AT_CHALLENGE_OFFSET = 0x180;
    uint256 constant BETA_OFFSET = 0x1a0;
    uint256 constant GAMMA_OFFSET = 0x1c0;
    uint256 constant G_OFFSET = 0x1e0;
    uint256 constant H_OFFSET = 0x200;
    uint256 constant PERM_POLYNOMIAL_VALUE_OFFSET = 0x220;
    uint256 constant PERM_POLYNOMIAL_SHIFTED_VALUE_OFFSET = 0x240;
    uint256 constant Q_BLIND_EVAL_OFFSET = 0x260;
    uint256 constant Q_LAST_EVAL_OFFSET = 0x280;
    uint256 constant S_ID_I_OFFSET = 0x2a0;
    uint256 constant S_SIGMA_I_OFFSET = 0x2c0;
    uint256 constant WITNESS_EVALUATION_POINTS_OFFSET = 0x2e0;
    uint256 constant TMP1_OFFSET = 0x300;
    uint256 constant TMP2_OFFSET = 0x320;
    uint256 constant TMP3_OFFSET = 0x340;
    uint256 constant IDX1_OFFSET = 0x360;
    uint256 constant IDX2_OFFSET = 0x380;
    uint256 constant STATUS_OFFSET = 0x3a0;

    uint256 constant WORD_SIZE = 4;


    function eval_permutations_at_challenge(
        types.fri_params_type memory fri_params,
        types.placeholder_state_type memory local_vars,
        uint256 column_polynomials_values_i
    ) internal pure {
        uint256 modulus = fri_params.modulus;
        uint256 gamma  =  local_vars.gamma;

        // beta * S_id[i].evaluate(challenge)
        uint256 beta_eval = mulmod(local_vars.beta,local_vars.S_id_i,modulus);

        // beta * S_id[i].evaluate(challenge) + gamma
        uint256 beta_eval_gamma = addmod(beta_eval,local_vars.gamma ,modulus);

        // column_polynomials_values[i] + beta * S_id[i].evaluate(challenge) + gamma
        uint256 beta_eval_g_poly = addmod(column_polynomials_values_i,beta_eval_gamma,modulus);

        local_vars.g = mulmod(local_vars.g,beta_eval_g_poly,modulus);



        // beta * S_sigma[i].evaluate(challenge)
        uint256 beta_eval_h =  mulmod(local_vars.beta,local_vars.S_sigma_i,modulus);

        // beta * S_sigma[i].evaluate(challenge) + gamma
        uint256 beta_eval_h_gamma = addmod(beta_eval_h,local_vars.gamma ,modulus);

        // column_polynomials_values[i] +  beta * S_sigma[i].evaluate(challenge) + gamma
        uint256 beta_eval_h_poly = addmod(column_polynomials_values_i,beta_eval_h_gamma,modulus);

        local_vars.h = mulmod(local_vars.h,beta_eval_h_poly , modulus);

        assembly {
//            let modulus := mload(fri_params)
//            mstore(
//                add(local_vars, G_OFFSET),
//                mulmod(
//                    mload(add(local_vars, G_OFFSET)),
//                    // column_polynomials_values[i] + beta * S_id[i].evaluate(challenge) + gamma
//                    addmod(
//                        // column_polynomials_values[i]
//                        column_polynomials_values_i,
//                        // beta * S_id[i].evaluate(challenge) + gamma
//                        addmod(
//                            // beta * S_id[i].evaluate(challenge)
//                            mulmod(
//                                // beta
//                                mload(add(local_vars, BETA_OFFSET)),
//                                // S_id[i].evaluate(challenge)
//                                mload(add(local_vars, S_ID_I_OFFSET)),
//                                modulus
//                            ),
//                            // gamma
//                            mload(add(local_vars, GAMMA_OFFSET)),
//                            modulus
//                        ),
//                        modulus
//                    ),
//                    modulus
//                )
//            )
//            mstore(
//                add(local_vars, H_OFFSET),
//                mulmod(
//                    mload(add(local_vars, H_OFFSET)),
//                    // column_polynomials_values[i] + beta * S_sigma[i].evaluate(challenge) + gamma
//                    addmod(
//                        // column_polynomials_values[i]
//                        column_polynomials_values_i,
//                        // beta * S_sigma[i].evaluate(challenge) + gamma
//                        addmod(
//                            // beta * S_sigma[i].evaluate(challenge)
//                            mulmod(
//                                // beta
//                                mload(add(local_vars, BETA_OFFSET)),
//                                // S_sigma[i].evaluate(challenge)
//                                mload(add(local_vars, S_SIGMA_I_OFFSET)),
//                                modulus
//                            ),
//                            // gamma
//                            mload(add(local_vars, GAMMA_OFFSET)),
//                            modulus
//                        ),
//                        modulus
//                    ),
//                    modulus
//                )
//            )
        }
    }

    function verify_eval_be(bytes calldata blob,
        types.transcript_data memory tr_state,
        types.placeholder_proof_map memory proof_map,
        types.fri_params_type memory fri_params,
        types.placeholder_common_data memory common_data,
        types.placeholder_state_type memory local_vars,
        types.arithmetization_params memory ar_params
    ) internal pure returns (uint256[] memory F) {
        // 1. Get beta, gamma
        local_vars.beta = transcript.get_field_challenge(
            tr_state,
            fri_params.modulus
        );
        local_vars.gamma = transcript.get_field_challenge(
            tr_state,
            fri_params.modulus
        );

        // 2. Add commitment to V_P to transcript
        transcript.update_transcript_b32_by_offset_calldata(
            tr_state,
            blob,
            proof_map.v_perm_commitment_offset + basic_marshalling.LENGTH_OCTETS
        );

        // splash
        local_vars.len = ar_params.permutation_columns;

        //require(
        //    batched_lpc_verifier.get_z_n_be(blob, proof_map.eval_proof_fixed_values_offset) == ar_params.permutation_columns + ar_params.permutation_columns + ar_params.constant_columns + ar_params.selector_columns + 2,
        //    "Something wrong with number of fixed values polys"
        //);
        local_vars.tmp1 = ar_params.witness_columns;
        local_vars.tmp2 = ar_params.public_input_columns;
        local_vars.tmp3 = ar_params.constant_columns;


        // 3. Calculate h_perm, g_perm at challenge pointa
        local_vars.g = 1;
        local_vars.h = 1;
        for (
            local_vars.idx1 = 0;
            local_vars.idx1 < local_vars.len;
            local_vars.idx1++
        ) {
            for (
                local_vars.idx2 = 0;
                local_vars.idx2 < common_data.columns_rotations[local_vars.idx1].length;
                local_vars.idx2++
            ) {
                if (common_data.columns_rotations[local_vars.idx1][local_vars.idx2] == 0 ) {
                    local_vars.zero_index = local_vars.idx2;
                }
            }

            local_vars.S_id_i = batched_lpc_verifier.get_fixed_values_z_i_j_from_proof_be(
                blob,
                proof_map.eval_proof_combined_value_offset,
                local_vars.idx1,
                0
            );

            // sigma_i
            local_vars.S_sigma_i = batched_lpc_verifier.get_fixed_values_z_i_j_from_proof_be(
                blob,
                proof_map.eval_proof_combined_value_offset,
                ar_params.permutation_columns + local_vars.idx1,
                0
            );

            if (local_vars.idx1 < local_vars.tmp1) {
                eval_permutations_at_challenge(
                    fri_params,
                    local_vars,
                    batched_lpc_verifier.get_variable_values_z_i_j_from_proof_be(
                        blob,
                        proof_map.eval_proof_combined_value_offset, // witnesses
                        local_vars.idx1,
                        local_vars.zero_index
                    )
                );
            } else if (local_vars.idx1 < local_vars.tmp1 + local_vars.tmp2) {
                eval_permutations_at_challenge(
                    fri_params,
                    local_vars,
                    batched_lpc_verifier.get_variable_values_z_i_j_from_proof_be(
                        blob,
                        proof_map.eval_proof_combined_value_offset, // public_input
                        local_vars.idx1,
                        local_vars.zero_index
                    )
                );
            } else if ( local_vars.idx1 <  local_vars.tmp1 + local_vars.tmp2 + local_vars.tmp3 ) {
                eval_permutations_at_challenge(
                    fri_params,
                    local_vars,
                    batched_lpc_verifier.get_fixed_values_z_i_j_from_proof_be(
                        blob,
                        proof_map.eval_proof_combined_value_offset, // constant
                        local_vars.idx1 - local_vars.tmp1 - local_vars.tmp2 + ar_params.permutation_columns + ar_params.permutation_columns,
                        local_vars.zero_index
                    )
                );
            }
        }

        local_vars.perm_polynomial_value = batched_lpc_verifier.get_permutation_z_i_j_from_proof_be(
            blob, proof_map.eval_proof_combined_value_offset, 0, 0
        );
        local_vars.perm_polynomial_shifted_value = batched_lpc_verifier.get_permutation_z_i_j_from_proof_be(
            blob, proof_map.eval_proof_combined_value_offset, 0, 1
        );

        local_vars.q_last_eval = batched_lpc_verifier.get_fixed_values_z_i_j_from_proof_be(
            blob, 
            proof_map.eval_proof_combined_value_offset,       // special selector 0
            ar_params.permutation_columns + ar_params.permutation_columns + ar_params.constant_columns + ar_params.selector_columns,
            0
        );
        local_vars.q_blind_eval = batched_lpc_verifier.get_fixed_values_z_i_j_from_proof_be(
            blob, 
            proof_map.eval_proof_combined_value_offset,       // special selector 1
            ar_params.permutation_columns + ar_params.permutation_columns + ar_params.constant_columns + ar_params.selector_columns + 1,
            0
        );
        F = new uint256[](ARGUMENT_SIZE);
        local_vars.challenge = basic_marshalling.get_uint256_be(
            blob,
            proof_map.eval_proof_offset
        );

        uint256 modulus = fri_params.modulus;
        {
        uint256 one_minus_perm_poly_v = addmod(1 , (modulus - local_vars.perm_polynomial_value), modulus);

        uint256 read_offset = proof_map.eval_proof_lagrange_0_offset;
        //uint256 blob_data = uint256(bytes32(blob[read_offset : read_offset + WORD_SIZE]));
        uint256 blob_data = uint256(getBytes32(blob,read_offset));

        F[0] = mulmod(blob_data,one_minus_perm_poly_v,modulus);
        }

                // blob[proof_map.eval_proof_lagrange_0_offset: proof_map.eval_proof_lagrange_0_offset + WORD_SIZE] +
                //proof_map.eval_proof_lagrange_0_offset


//        assembly {
            //let modulus := mload(fri_params)

//            // F[0]
//            mstore(
//                add(F, 0x20),
//                mulmod(
//                    calldataload(
//                        add(
//                            blob.offset,
//                            mload(
//                                add(
//                                    proof_map,
//                                    EVAL_PROOF_LAGRANGE_0_OFFSET_OFFSET
//                                )
//                            )
//                        )
//                    ),
//                    addmod(
//                        1,
//                        // one - perm_polynomial_value
//                        sub(
//                            modulus,
//                            mload(add(local_vars, PERM_POLYNOMIAL_VALUE_OFFSET))
//                        ),
//                        modulus
//                    ),
//                    modulus
//                )
//            )
//        }

        // - perm_polynomial_value * g
        {
            uint256 perm_poly_val_g=  modulus - mulmod(local_vars.perm_polynomial_value,local_vars.g, modulus);
    //
    //        // perm_polynomial_shifted_value * h
            uint256 perm_poly_val_h =   mulmod(local_vars.perm_polynomial_shifted_value, local_vars.h, modulus);
    //
    //        // perm_polynomial_shifted_value * h - perm_polynomial_value * g
            uint256 poly_h_min_g = addmod(perm_poly_val_h,perm_poly_val_g, modulus);
    //
    //        //-preprocessed_data.q_last.evaluate(challenge) - preprocessed_data.q_blind.evaluate(challenge)
             uint256 mod_min_q_last_eval = modulus - local_vars.q_last_eval;
             uint256 mod_min_q_blind_eval = modulus - local_vars.q_blind_eval;
             uint256 pre_process_st_1 = addmod(mod_min_q_last_eval,mod_min_q_blind_eval,modulus);

    //
            // -preprocessed_data.q_last.evaluate(challenge) - preprocessed_data.q_blind.evaluate(challenge)
            uint256 pre_process_st_2 = addmod(1,pre_process_st_1,modulus );


            F[1] = mulmod(pre_process_st_2,poly_h_min_g , modulus);
        }




//        assembly{
//            //let modulus := mload(fri_params)
//            // F[1]
//            mstore(
//                add(F, 0x40),
//                // (one - preprocessed_data.q_last.evaluate(challenge) -
//                //  preprocessed_data.q_blind.evaluate(challenge)) *
//                //  (perm_polynomial_shifted_value * h - perm_polynomial_value * g)
//                mulmod(
//                    // one - preprocessed_data.q_last.evaluate(challenge) -
//                    //  preprocessed_data.q_blind.evaluate(challenge)
//                    addmod(
//                        1,
//                        // -preprocessed_data.q_last.evaluate(challenge) - preprocessed_data.q_blind.evaluate(challenge)
//                        addmod(
//                            // -preprocessed_data.q_last.evaluate(challenge)
//                            sub(
//                                modulus,
//                                mload(add(local_vars, Q_LAST_EVAL_OFFSET))
//                            ),
//                            // -preprocessed_data.q_blind.evaluate(challenge)
//                            sub(
//                                modulus,
//                                mload(add(local_vars, Q_BLIND_EVAL_OFFSET))
//                            ),
//                            modulus
//                        ),
//                        modulus
//                    ),
//                    // perm_polynomial_shifted_value * h - perm_polynomial_value * g
//                    addmod(
//                        // perm_polynomial_shifted_value * h
//                        mulmod(
//                            // perm_polynomial_shifted_value
//                            mload(
//                                add(
//                                    local_vars,
//                                    PERM_POLYNOMIAL_SHIFTED_VALUE_OFFSET
//                                )
//                            ),
//                            // h
//                            mload(add(local_vars, H_OFFSET)),
//                            modulus
//                        ),
//                        // - perm_polynomial_value * g
//                        sub(
//                            modulus,
//                            mulmod(
//                                // perm_polynomial_value
//                                mload(
//                                    add(
//                                        local_vars,
//                                        PERM_POLYNOMIAL_VALUE_OFFSET
//                                    )
//                                ),
//                                // g
//                                mload(add(local_vars, G_OFFSET)),
//                                modulus
//                            )
//                        ),
//                        modulus
//                    ),
//                    modulus
//                )
//            )
//        }
        {
        //-perm_polynomial_value
        uint256 min_per_poly_val = modulus - local_vars.perm_polynomial_value;

        // perm_polynomial_value.squared()
        uint256 perm_poly_sq = mulmod(local_vars.perm_polynomial_value, local_vars.perm_polynomial_value,modulus);

        //
        uint256 poly_sq_minus_min_poly_val = addmod(perm_poly_sq,min_per_poly_val,modulus);

        F[2] = mulmod(local_vars.q_last_eval,poly_sq_minus_min_poly_val, modulus);

        }

//        assembly{
//            //let modulus := mload(fri_params)
//            // F[2]
//            mstore(
//                add(F, 0x60),
//                // preprocessed_data.q_last.evaluate(challenge) *
//                //  (perm_polynomial_value.squared() - perm_polynomial_value)
//                mulmod(
//                    // preprocessed_data.q_last.evaluate(challenge)
//                    mload(add(local_vars, Q_LAST_EVAL_OFFSET)),
//                    // perm_polynomial_value.squared() - perm_polynomial_value
//                    addmod(
//                        // perm_polynomial_value.squared()
//                        mulmod(
//                            // perm_polynomial_value
//                            mload(
//                                add(local_vars, PERM_POLYNOMIAL_VALUE_OFFSET)
//                            ),
//                            // perm_polynomial_value
//                            mload(
//                                add(local_vars, PERM_POLYNOMIAL_VALUE_OFFSET)
//                            ),
//                            modulus
//                        ),
//                        // -perm_polynomial_value
//                        sub(
//                            modulus,
//                            mload(add(local_vars, PERM_POLYNOMIAL_VALUE_OFFSET))
//                        ),
//                        modulus
//                    ),
//                    modulus
//                )
//            )
//        }
    }
}


// File contracts/placeholder/placeholder_verifier.sol





library placeholder_verifier {
    // TODO: check correctness all this const
    uint256 constant f_parts = 9;

    uint256 constant OMEGA_OFFSET = 0x20;

    uint256 constant LEN_OFFSET = 0x0;
    uint256 constant OFFSET_OFFSET = 0x20;
    uint256 constant ZERO_INDEX_OFFSET = 0x40;
    uint256 constant PERMUTATION_ARGUMENT_OFFSET = 0x60;
    uint256 constant GATE_ARGUMENT_OFFSET = 0x80;
    uint256 constant ALPHAS_OFFSET = 0xa0;
    uint256 constant CHALLENGE_OFFSET = 0xc0;
    uint256 constant E_OFFSET = 0xe0;
    uint256 constant EVALUATION_POINTS_OFFSET = 0x100;
    uint256 constant F_OFFSET = 0x120;
    uint256 constant F_CONSOLIDATED_OFFSET = 0x140;
    uint256 constant T_CONSOLIDATED_OFFSET = 0x160;
    uint256 constant Z_AT_CHALLENGE_OFFSET = 0x180;
    uint256 constant BETA_OFFSET = 0x1a0;
    uint256 constant GAMMA_OFFSET = 0x1c0;
    uint256 constant G_OFFSET = 0x1e0;
    uint256 constant H_OFFSET = 0x200;
    uint256 constant PERM_POLYNOMIAL_VALUE_OFFSET = 0x220;
    uint256 constant PERM_POLYNOMIAL_SHIFTED_VALUE_OFFSET = 0x240;
    uint256 constant Q_BLIND_EVAL_OFFSET = 0x260;
    uint256 constant Q_LAST_EVAL_OFFSET = 0x280;
    uint256 constant S_ID_I_OFFSET = 0x2a0;
    uint256 constant S_SIGMA_I_OFFSET = 0x2c0;
    uint256 constant WITNESS_EVALUATION_POINTS_OFFSET = 0x2e0;
    uint256 constant STATUS_OFFSET = 0x3a0;

    function verify_proof_be(bytes calldata blob,
        types.transcript_data memory tr_state,
        types.placeholder_proof_map memory proof_map,
        types.fri_params_type memory fri_params,
        types.placeholder_common_data memory common_data,
        types.placeholder_state_type memory local_vars,
        types.arithmetization_params memory ar_params
    ) external view returns (bool result) {
        // 8. alphas computations
        local_vars.alphas = new uint256[](f_parts);
        transcript.get_field_challenges(tr_state, local_vars.alphas, fri_params.modulus);

        // 9. Evaluation proof check
        transcript.update_transcript_b32_by_offset_calldata(tr_state, blob, basic_marshalling.skip_length(proof_map.T_commitment_offset));
        local_vars.challenge = transcript.get_field_challenge(tr_state, fri_params.modulus);
        if (local_vars.challenge != basic_marshalling.get_uint256_be(blob, proof_map.eval_proof_offset)) {
            return false;
        }

        // variable values

        local_vars.inversed_omega = field.inverse_static(common_data.omega, fri_params.modulus);
        uint256 challenge_omega = field.fmul(local_vars.challenge, common_data.omega, fri_params.modulus);
        uint256 challenge_inversed_omega = field.fmul(local_vars.challenge, local_vars.inversed_omega, fri_params.modulus);
        
        // TODO this should be bytes32
        local_vars.roots = new uint256[](fri_params.batches_num);
        local_vars.roots[0] = merkle_verifier.get_merkle_root_from_blob(blob, proof_map.variable_values_commitment_offset);
        local_vars.roots[1] = merkle_verifier.get_merkle_root_from_blob(blob, proof_map.v_perm_commitment_offset);
        local_vars.roots[2] = merkle_verifier.get_merkle_root_from_blob(blob, proof_map.T_commitment_offset);
        local_vars.roots[3] = merkle_verifier.get_merkle_root_from_blob(blob, proof_map.fixed_values_commitment_offset);

        uint256[] memory challenge_point = new uint256[](1);
        challenge_point[0] = local_vars.challenge;

        local_vars.evaluation_points = new uint256[][][](fri_params.batches_num);
        local_vars.evaluation_points[0] = new uint256[][](fri_params.batches_sizes[0]);

        for (uint256 i = 0; i < ar_params.witness_columns + ar_params.public_input_columns;) {
            local_vars.evaluation_points[0][i] = new uint256[](common_data.columns_rotations[i].length);
            for (uint256 j = 0; j < common_data.columns_rotations[i].length;) {
                if(common_data.columns_rotations[i][j] == 0){
                    local_vars.evaluation_points[0][i][j] = local_vars.challenge;
                } else if(common_data.columns_rotations[i][j] == 1){
                    local_vars.evaluation_points[0][i][j] = challenge_omega;
                } else if(common_data.columns_rotations[i][j] == -1) {
                    local_vars.evaluation_points[0][i][j] = challenge_inversed_omega;
                } else {
                    uint256 omega;
                    uint256 e;

                    if (common_data.columns_rotations[i][j] < 0) {
                        omega = local_vars.inversed_omega;
                        e = uint256(-common_data.columns_rotations[i][j]);
                    } else {
                        omega = common_data.omega;
                        e = uint256(common_data.columns_rotations[i][j]);
                    }
                    // TODO check it!!!!
                    // TODO: check properly if column_rotations will be not one of 0, +-1
                    // local_vars.evaluation_points[0][i][j] = local_vars.challenge * omega ^ column_rotations[i][j]
                    local_vars.e = local_vars.challenge ;
                    while(e > 0){
                        if ((e & 1) != 0){
                            local_vars.e = mulmod(local_vars.e, omega, fri_params.modulus);
                        }
                        if (e !=1) {
                            omega = mulmod(omega,omega, fri_params.modulus);
                        }
                        e = e >> 1;
                    }

//                    assembly{
//                        for{mstore(add(local_vars, E_OFFSET), mload(add(local_vars, CHALLENGE_OFFSET)))} gt(e,0) {e := shr(e, 1)} {
//                            if not(eq(and(e,1), 0)){
//                                mstore(add(local_vars, E_OFFSET),mulmod(mload(add(local_vars, E_OFFSET)), omega, mload(fri_params)))
//                            }
//                            if not(eq(e, 1)){
//                                omega := mulmod(omega,omega, mload(fri_params))
//                            }
//                        }
//                    }
                    local_vars.evaluation_points[0][i][j] = local_vars.e;
                }
            unchecked{j++;}
            }
        unchecked{i++;}
        }

        // For permutation polynomial
        local_vars.evaluation_points[1] = new uint256[][](1);
        local_vars.evaluation_points[1][0] = new uint256[](2);
        local_vars.evaluation_points[1][0][0] = local_vars.challenge;
        local_vars.evaluation_points[1][0][1] = challenge_omega;

        local_vars.evaluation_points[2] = new uint256[][](1);
        local_vars.evaluation_points[2][0] = challenge_point;

        local_vars.evaluation_points[3] = new uint256[][](fri_params.batches_sizes[3]);
        for (uint256 i = 0; i < (ar_params.permutation_columns << 1);) {
            local_vars.evaluation_points[3][i] = challenge_point;
            unchecked{i++;}
        }
        
        // constant columns and selector columns may be rotated
        for( uint256 i = 0; i < ar_params.constant_columns + ar_params.selector_columns; ){
            uint256 eval_point_ind = i + (ar_params.permutation_columns << 1);
            uint256 rotation_ind = i + (ar_params.witness_columns + ar_params.public_input_columns);
            local_vars.evaluation_points[3][eval_point_ind] =
                new uint256[](common_data.columns_rotations[rotation_ind].length);
            for (uint256 j = 0; j < common_data.columns_rotations[rotation_ind].length;) {
                if(common_data.columns_rotations[rotation_ind][j] == 0){
                    local_vars.evaluation_points[3][eval_point_ind][j] = local_vars.challenge;
                } else if(common_data.columns_rotations[rotation_ind][j] == 1){
                    local_vars.evaluation_points[3][eval_point_ind][j] = challenge_omega;
                } else if(common_data.columns_rotations[rotation_ind][j] == -1) {
                    local_vars.evaluation_points[3][eval_point_ind][j] = challenge_inversed_omega;
                } else {
                    uint256 omega;
                    uint256 e;

                    if (common_data.columns_rotations[rotation_ind][j] < 0) {
                        omega = local_vars.inversed_omega;
                        e = uint256(-common_data.columns_rotations[rotation_ind][j]);
                    } else {
                        omega = common_data.omega;
                        e = uint256(common_data.columns_rotations[rotation_ind][j]);
                    }
                    // TODO check it!!!!
                    // TODO: check properly if column_rotations will be not one of 0, +-1
                    // local_vars.evaluation_points[0][i][j] = local_vars.challenge * omega ^ column_rotations[i][j]
                    local_vars.e = local_vars.challenge;
                    while(e > 0) {
                        if (e & 1 !=0) {
                            local_vars.e = mulmod(local_vars.e, omega, fri_params.modulus);
                        }
                        if (e !=1){
                            omega = mulmod(omega, omega, fri_params.modulus);
                        }
                        e = e >> 1;
                    }

//                    assembly{
//                        for{mstore(add(local_vars, E_OFFSET), mload(add(local_vars, CHALLENGE_OFFSET)))} gt(e,0) {e := shr(e, 1)} {
//                            if not(eq(and(e,1), 0)){
//                                mstore(add(local_vars, E_OFFSET),mulmod(mload(add(local_vars, E_OFFSET)), omega, mload(fri_params)))
//                            }
//                            if not(eq(e, 1)){
//                                omega := mulmod(omega,omega, mload(fri_params))
//                            }
//                        }
//                    }
                    local_vars.evaluation_points[0][eval_point_ind][j] = local_vars.e;
                }
                unchecked{j++;}
            }
            unchecked{i++;}
        }

        //  q_last and q_blind
        for (uint256 i = (ar_params.permutation_columns << 1) + ar_params.constant_columns + ar_params.selector_columns; 
            i < fri_params.batches_sizes[3];
        ) {
            local_vars.evaluation_points[3][i] = challenge_point;
            unchecked{i++;}
        }

        if( !batched_lpc_verifier.verify_proof_be(
            blob,
            proof_map.eval_proof_combined_value_offset,
            local_vars.roots,
            local_vars.evaluation_points,  
            tr_state,
            fri_params
        )){
            return false;
        }

        // quotient
        // 10. final check
        local_vars.F = new uint256[](f_parts);
        local_vars.F[0] = local_vars.permutation_argument[0];
        local_vars.F[1] = local_vars.permutation_argument[1];
        local_vars.F[2] = local_vars.permutation_argument[2];
        local_vars.F[3] = 0;
        local_vars.F[4] = 0;
        local_vars.F[5] = 0;
        local_vars.F[6] = 0;
        local_vars.F[7] = 0;
        local_vars.F[8] = local_vars.gate_argument;

        local_vars.F_consolidated = 0;
        for (uint256 i = 0; i < f_parts;) {
            local_vars.F_consolidated = addmod(
                local_vars.F_consolidated,
                mulmod(local_vars.alphas[i], local_vars.F[i], fri_params.modulus),
                fri_params.modulus
            );
            unchecked{ i++; }
        }
        local_vars.T_consolidated = 0;
        local_vars.len = fri_params.batches_sizes[2];

        for (uint256 i = 0; i < local_vars.len; i++) {
            local_vars.zero_index = batched_lpc_verifier.get_quotient_z_i_j_from_proof_be(blob, proof_map.eval_proof_combined_value_offset, i, 0);
            local_vars.e = field.expmod_static(local_vars.challenge, (fri_params.max_degree + 1) * i, fri_params.modulus);
            local_vars.zero_index = field.fmul(local_vars.zero_index, local_vars.e, fri_params.modulus);
            //local_vars.T_consolidated  = field.fadd(local_vars.T_consolidated, local_vars.zero_index, fri_params.modulus);
//            assembly {
//                mstore(
//                    // local_vars.zero_index
//                    add(local_vars, ZERO_INDEX_OFFSET),
//                    // local_vars.zero_index * local_vars.e
//                    mulmod(
//                        // local_vars.zero_index
//                        mload(add(local_vars, ZERO_INDEX_OFFSET)),
//                        // local_vars.e
//                        mload(add(local_vars, E_OFFSET)),
//                        // modulus
//                        mload(fri_params)
//                    )
//                )
//                mstore(
//                    // local_vars.T_consolidated
//                    add(local_vars, T_CONSOLIDATED_OFFSET),
//                    // local_vars.T_consolidated + local_vars.zero_index
//                    addmod(
//                        // local_vars.T_consolidated
//                        mload(add(local_vars, T_CONSOLIDATED_OFFSET)),
//                        // local_vars.zero_index
//                        mload(add(local_vars, ZERO_INDEX_OFFSET)),
//                        // modulus
//                        mload(fri_params)
//                    )
//                )
//            }
        }
        local_vars.Z_at_challenge = field.expmod_static(local_vars.challenge, common_data.rows_amount, fri_params.modulus);
        local_vars.Z_at_challenge = field.fsub(local_vars.Z_at_challenge, 1, fri_params.modulus);
        local_vars.Z_at_challenge = field.fmul(local_vars.Z_at_challenge, local_vars.T_consolidated, fri_params.modulus);
//        assembly {
//            mstore(
//                // local_vars.Z_at_challenge
//                add(local_vars, Z_AT_CHALLENGE_OFFSET),
//                // local_vars.Z_at_challenge - 1
//                addmod(
//                    // Z_at_challenge
//                    mload(add(local_vars, Z_AT_CHALLENGE_OFFSET)),
//                    // -1
//                    sub(mload(fri_params), 1),
//                    // modulus
//                    mload(fri_params)
//                )
//            )
//            mstore(
//                // local_vars.Z_at_challenge
//                add(local_vars, Z_AT_CHALLENGE_OFFSET),
//                // Z_at_challenge * T_consolidated
//                mulmod(
//                    // Z_at_challenge
//                    mload(add(local_vars, Z_AT_CHALLENGE_OFFSET)),
//                    // T_consolidated
//                    mload(add(local_vars, T_CONSOLIDATED_OFFSET)),
//                    // modulus
//                    mload(fri_params)
//                )
//            )
//        }
        if (local_vars.F_consolidated != local_vars.Z_at_challenge) {
            return false;
        }

        return true;
    }
}


// File contracts/placeholder/proof_map_parser.sol


library placeholder_proof_map_parser {
    /**
     * Proof structure: https://github.com/NilFoundation/crypto3-zk-marshalling/blob/master/include/nil/crypto3/marshalling/zk/types/placeholder/proof.hpp
     */
    function parse_be(bytes calldata blob, uint256 offset)
    internal pure returns (types.placeholder_proof_map memory proof_map, uint256 proof_size){
        proof_map.variable_values_commitment_offset = offset;
        proof_map.v_perm_commitment_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, proof_map.variable_values_commitment_offset);
        proof_map.T_commitment_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, proof_map.v_perm_commitment_offset);
        proof_map.fixed_values_commitment_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, proof_map.T_commitment_offset);
        proof_map.eval_proof_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, proof_map.fixed_values_commitment_offset);//challenge_offset

        //require(false, logging.uint2decstr(basic_marshalling.get_uint256_be(blob, proof_map.eval_proof_offset)));
        // TODO: add data structures for lookups

        proof_map.eval_proof_lagrange_0_offset = basic_marshalling.skip_uint256_be_check(blob, proof_map.eval_proof_offset); 
        proof_map.eval_proof_combined_value_offset = basic_marshalling.skip_uint256_be_check(blob, proof_map.eval_proof_lagrange_0_offset);
        proof_size = batched_lpc_verifier.skip_proof_be(blob, proof_map.eval_proof_combined_value_offset);
    }
}


// File contracts/interfaces/verifier.sol


interface IVerifier {
    function verify(
        bytes calldata blob, 
        uint256[]  calldata init_params,
        int256[ROWS_ROTATION][COLS_ROTATION] calldata columns_rotations,
        address gate_argument
    ) external view returns (bool);
}


// File contracts/verifier.sol



contract PlaceholderVerifier is IVerifier {
    struct verifier_state {
        uint256 proofs_num;
        uint256 proof_offset;
        uint256 proof_size;
        uint256 ind;

        types.fri_params_type           fri_params;
        types.placeholder_proof_map     proof_map;
        types.transcript_data           tr_state;
        types.placeholder_common_data   common_data;
        types.arithmetization_params    arithmetization_params;
    }

    function init_vars(
        verifier_state memory vars, 
        uint256[] memory init_params, 
        int256[ROWS_ROTATION][COLS_ROTATION] memory columns_rotations
    ) internal pure {
        uint256 idx;
        uint256 max_coset;
        uint256 i;

        vars.fri_params.modulus = init_params[idx++];
        vars.fri_params.r = init_params[idx++];
        vars.fri_params.max_degree = init_params[idx++];
        vars.fri_params.lambda = init_params[idx++];

        vars.common_data.rows_amount = init_params[idx++];
        vars.common_data.omega = init_params[idx++];
        vars.common_data.columns_rotations = columns_rotations;

        vars.fri_params.D_omegas = new uint256[](init_params[idx++]);
        for (i = 0; i < vars.fri_params.D_omegas.length;) {
            vars.fri_params.D_omegas[i] = init_params[idx];
        unchecked{ i++; idx++;}
        }

        vars.fri_params.max_step = 0;
        vars.fri_params.step_list = new uint256[](init_params[idx++]);
        for (i = 0; i < vars.fri_params.step_list.length;) {
            vars.fri_params.step_list[i] = init_params[idx];
            if(vars.fri_params.step_list[i] > vars.fri_params.max_step)
                vars.fri_params.max_step = vars.fri_params.step_list[i];
            unchecked{ i++; idx++;}
        }

        unchecked{
            idx++; // arithmetization_params length;
            vars.arithmetization_params.witness_columns = init_params[idx++];
            vars.arithmetization_params.public_input_columns = init_params[idx++];
            vars.arithmetization_params.constant_columns = init_params[idx++];
            vars.arithmetization_params.selector_columns = init_params[idx++];
            vars.arithmetization_params.permutation_columns = vars.arithmetization_params.witness_columns 
                + vars.arithmetization_params.public_input_columns 
                + vars.arithmetization_params.constant_columns;
        }

        unchecked{ max_coset = 1 << (vars.fri_params.max_step - 1);}

        vars.fri_params.max_coset = max_coset;
        vars.fri_params.s_indices = new uint256[](max_coset);
        vars.fri_params.correct_order_idx = new uint256[](max_coset);
        vars.fri_params.tmp_arr = new uint256[](max_coset << 1);
        vars.fri_params.s = new uint256[](max_coset);
        vars.fri_params.batches_num = 4;
        vars.fri_params.batches_sizes = new uint256[](vars.fri_params.batches_num);
        vars.fri_params.batches_sizes[0] = vars.arithmetization_params.witness_columns + vars.arithmetization_params.public_input_columns;        
        vars.fri_params.batches_sizes[1] = 1;
            // TODO We don't know T_polynomials size. 
            // We'll extract it from proof in parse_be function 
            //      and verify fri_proof.query_proof[i].initial_proof[2].values have 
        vars.fri_params.batches_sizes[2] = 0; 
        vars.fri_params.batches_sizes[3] = vars.arithmetization_params.permutation_columns 
            + vars.arithmetization_params.permutation_columns
            + vars.arithmetization_params.constant_columns 
            + vars.arithmetization_params.selector_columns + 2;
    }

    function verify(
        bytes calldata blob, 
        uint256[] calldata init_params,
        int256[ROWS_ROTATION][COLS_ROTATION] calldata columns_rotations,
        address gate_argument
    ) public view returns (bool result) {
        verifier_state memory vars;
        init_vars(vars, init_params, columns_rotations);
        transcript.init_transcript(vars.tr_state, hex"");
        
        (vars.proof_map, vars.proof_size) = placeholder_proof_map_parser.parse_be(blob, 0);
        if(vars.proof_size != blob.length) return false;
        (result, )= batched_lpc_verifier.parse_proof_be(vars.fri_params, blob, vars.proof_map.eval_proof_combined_value_offset);
        if( !result ) return false;

        types.placeholder_state_type memory local_vars;

        // 3. append witness commitments to transcript
        transcript.update_transcript_b32_by_offset_calldata(vars.tr_state, blob, basic_marshalling.skip_length(vars.proof_map.variable_values_commitment_offset));


        // 4. prepare evaluations of the polynomials that are copy-constrained
        // 5. permutation argument
        local_vars.permutation_argument = permutation_argument.verify_eval_be(blob, vars.tr_state,
            vars.proof_map, vars.fri_params,
            vars.common_data, local_vars, vars.arithmetization_params);

        // 7. gate argument specific for circuit
        types.gate_argument_params memory gate_params;
        gate_params.modulus = vars.fri_params.modulus;
        gate_params.theta = transcript.get_field_challenge(vars.tr_state, vars.fri_params.modulus);

        IGateArgument gate_argument_component = IGateArgument(gate_argument);
        local_vars.gate_argument = gate_argument_component.evaluate_gates_be(
            blob, 
            vars.proof_map.eval_proof_combined_value_offset,  
            gate_params,
            vars.arithmetization_params,
            vars.common_data.columns_rotations
        );

        if (!placeholder_verifier.verify_proof_be(
            blob, 
            vars.tr_state,
            vars.proof_map, 
            vars.fri_params, vars.common_data, local_vars,
            vars.arithmetization_params))
            return false;
            
        return true;
    }
}
