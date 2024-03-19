// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2024 Vasiliy Olekhov <vasiliy.olekhov@nil.foundation>
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
import "../algebra/bn254.sol";
import "../../contracts/interfaces/modular_verifier.sol";

import "hardhat/console.sol";

library batched_kzg_verifier {

    function verify_proof(
        types.g1_point[] memory commitments,
        uint256[] memory Z,
        uint256[] memory U,
        types.transcript_data memory tr_state,
        types.kzg_params_type memory kzg_params,
        types.kzg_proof_type memory kzg_proof)
    internal view returns (bool result) {
    unchecked {

        uint256 i;

        /* 1. send to transcript all commitments */
        for (i = 0; i < kzg_params.commitments_num; ++i ) {
            transcript.update_transcript_b32(tr_state, bytes32(commitments[i].x));
            transcript.update_transcript_b32(tr_state, bytes32(commitments[i].y));
        }
        for (i = 0; i < kzg_params.points_num; ++i ) {
            transcript.update_transcript_b32(tr_state, bytes32(Z[i]));
        }
        for (i = 0; i < kzg_params.points_num; ++i ) {
            transcript.update_transcript_b32(tr_state, bytes32(U[i]));
        }
        /* TWICE ? */
        for (i = 0; i < kzg_params.commitments_num; ++i ) {
            transcript.update_transcript_b32(tr_state, bytes32(commitments[i].x));
            transcript.update_transcript_b32(tr_state, bytes32(commitments[i].y));
        }
        for (i = 0; i < kzg_params.points_num; ++i ) {
            transcript.update_transcript_b32(tr_state, bytes32(Z[i]));
        }
        for (i = 0; i < kzg_params.points_num; ++i ) {
            transcript.update_transcript_b32(tr_state, bytes32(U[i]));
        }

        /* 2. challenge theta from transcript */
        uint256 theta = transcript.get_field_challenge(tr_state, bn254_crypto.r_mod);

        /* 3. send pi_1 to transcript */
        transcript.update_transcript_b32(tr_state, bytes32(kzg_proof.pi_1.x));
        transcript.update_transcript_b32(tr_state, bytes32(kzg_proof.pi_1.y));

        /* 4. challenge theta_2 from transcript */
        uint256 theta_2 = transcript.get_field_challenge(tr_state, bn254_crypto.r_mod);

        /* check theta and theta_2 values */
        if(theta != kzg_params.theta) {
            console.log("wrong theta: ", theta);
            console.log("expecting  : ", kzg_params.theta);
        }

        if(theta_2 != kzg_params.theta_2) {
            console.log("wrong theta_2 :", theta_2);
            console.log("expecting     : ", kzg_params.theta_2);
        }
 
        /* 5. for a set of commitments construct F */

        uint256 theta_i = 1;
        types.g1_point memory F = bn254_crypto.new_g1(0,0);
        uint256 rsum = 0;
        uint256 tmp;
        uint256 r_i;

        for (i = 0; i < kzg_params.commitments_num; ++i) {
            tmp = 13537094572093675138513973797244805699587981214733746302150278342976640424397;
            r_i = mulmod(theta_i, tmp, bn254_crypto.r_mod);
            types.g1_point memory f = bn254_crypto.ecmul(commitments[i], r_i);
            F = bn254_crypto.ecadd(F, f);
            tmp = 9554926369995100646077410167290930878381045633071770559944038420370185418405;
            r_i = mulmod(r_i, tmp, bn254_crypto.r_mod);
            rsum = addmod(rsum, r_i, bn254_crypto.r_mod);
            theta_i = mulmod(theta_i, theta, bn254_crypto.r_mod);
        }

        types.g1_point memory F_last = bn254_crypto.ecmul(bn254_crypto.P1(), rsum);
        F_last.x = bn254_crypto.p_mod - F_last.x;
        F = bn254_crypto.ecadd(F, F_last);

        tmp= 11559732032986387107991004021392285783925812861821192530917403151452391805634;
        F_last = bn254_crypto.ecmul(kzg_proof.pi_1, tmp);
        F_last.x = bn254_crypto.p_mod - F_last.x;
        F = bn254_crypto.ecadd(F, F_last);

        F_last = bn254_crypto.ecmul(kzg_proof.pi_1, theta_2);
        F = bn254_crypto.ecadd(F, F_last);

        types.g2_point memory g2 = bn254_crypto.P2();

        return bn254_crypto.pairingProd2(F , g2, kzg_proof.pi_2, kzg_params.verification_key);
    }
    }
}
