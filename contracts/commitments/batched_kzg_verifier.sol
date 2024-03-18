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

library batched_kzg_verifier {

    function verify_proof(
        /*
        uint256[] memory commitments,
        types.kzg_proof_type memory kzg_proof,
        types.transcript_data memory tr_state,
        types.kzg_params_type memory kzg_params*/)
    internal view returns (bool result) {

        types.g1_point memory a1 = bn254_crypto.new_g1(
            13537094572093675138513973797244805699587981214733746302150278342976640424397,
            9554926369995100646077410167290930878381045633071770559944038420370185418405);

        types.g2_point memory a2 = bn254_crypto.new_g2(
            10857046999023057135944570762232829481370756359578518086990519993285655852781,
            11559732032986387107991004021392285783925812861821192530917403151452391805634,
            8495653923123431417604973247489272438418190587263600148770280649306958101930,
            4082367875863433681332203403145435568316851327593401208105741076214120093531);

        types.g1_point memory b1 = bn254_crypto.new_g1(
            18537193526015835698554895901144353361264554539198746530791998564522770502405,
            15073207450244909649956103901894317250233986784535780985960937295179118615068);

        types.g2_point memory b2 = bn254_crypto.new_g2(
            15512671280233143720612069991584289591749188907863576513414377951116606878472,
            18551411094430470096460536606940536822990217226529861227533666875800903099477,
            13376798835316611669264291046140500151806347092962367781523498857425536295743,
            1711576522631428957817575436337311654689480489843856945284031697403898093784);

        return bn254_crypto.pairingProd2(a1,a2, b1,b2);
    }
}
