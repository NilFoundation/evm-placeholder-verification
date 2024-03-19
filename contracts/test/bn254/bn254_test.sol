// SPDX-License-Identifier: MIT OR Apache-2.0
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
pragma solidity ^0.8.0;

import '../../../contracts/commitments/batched_kzg_verifier.sol';
import "../../../contracts/interfaces/modular_verifier.sol";
import 'hardhat/console.sol';

contract kzg_estimation is IModularVerifier {

    /**
     * @dev Initializes verifier
     */
    function initialize(
        address lookup_argument_contract_address,
        address gate_argument_contract_address,
        address commitment_contract_address) public
    {

    }

    /**
     * @dev Verifies proof
     */
    function verify(
        bytes calldata blob,
        uint256[] calldata public_input
    ) public returns (bool result)
    {

        types.g1_point[] memory commitments;
        commitments = new types.g1_point[](4);

        commitments[0].x = 0x0c44878bb8ff269d74d4c82a460b47503e72178c24ea96b071db39f540083856;
        commitments[0].y = 0x15e1d289c6429156a6812b89f5f2b9c5adbcae41274c88a317d7b394e15a339;
        commitments[1].x = 0x1a61eddcc2d2c249e4fea2895bf5d5c258dccd230ce16b355e22da9ccef3d796;
        commitments[1].y = 0x88dfa0426989fe5b61b796b53fb18bd72b74bc513524e62ba8c0651366d1e96;
        commitments[2].x = 0x00a81266b641f4305269eaf67036ee6a5d532143cbc706c1e97c7a84ba769d14;
        commitments[2].y = 0x347d40c1e4471ca1423f38a73aec0a009819eff6571813db1620156d4719b67;
        commitments[3].x = 0x5804dfe02a750643061c878b6d938cb74c621375c63c77cde1eb3804b8206d80;
        commitments[3].y = 0x2501fa3f32e1cd9b04d66803dc467373c9f4f8fe285e2d53422fe9e508fe75e3;

        uint256[] memory Z;
        Z = new uint256[](12);
        Z[ 0] = 0x0000000000000000000000000000000000000000000000000000000000000701;
        Z[ 1] = 0x000000000000000000000000000000000000000000000000000000000000601c;
        Z[ 2] = 0x000000000000000000000000000000000000000000000000000312e5a822d164;
        Z[ 3] = 0x00000000000000000000000000000000000000000000000000000000000010f7;
        Z[ 4] = 0x000000000000000000000000000000000000000000000000000000000000e03c;
        Z[ 5] = 0x00000000000000000000000000000000000000000000000000076a1399d05b27;
        Z[ 6] = 0x00000000000000000000000000000000000000000000000000000000000000c4;
        Z[ 7] = 0x0000000000000000000000000000000000000000000000000000000000001aed;
        Z[ 8] = 0x000000000000000000000000000000000000000000000000000000000001605c;
        Z[ 9] = 0x00000000000000000000000000000000000000000000000000000000000024e3;
        Z[10] = 0x000000000000000000000000000000000000000000000000000000000001e07c;
        Z[11] = 0x0000000000000000000000000000000000000000000000000011eef27398435f;

        uint256[] memory U;
        U = new uint256[](12);
        U[ 0] = 0x0000000000000000000000000000000000000000000000000000007c9471f41d;
        U[ 1] = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f52c1ef629ad;
        U[ 2] = 0x00000000000000000000000000000000000000000000000000000014c3686fe3;
        U[ 3] = 0x000000000000000000000000000000000000000000000000000001267d4b52fb;
        U[ 4] = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f49e87961425;
        U[ 5] = 0x0000000000000000000000000000000000000000000000000000003114e2256d;
        U[ 6] = 0x00000000000000000000000000000000000000000000000000000000000111e1;
        U[ 7] = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593effe5941;
        U[ 8] = 0x00000000000000000000000000000000000000000000000000000000000095a3;
        U[ 9] = 0x000000000000000000000000000000000000000000000000000002ac7f620cdf;
        U[10] = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f35985d7ec49;
        U[11] = 0x00000000000000000000000000000000000000000000000000000072153b8fdd;

        types.kzg_params_type memory kzg_params;

        kzg_params.commitments_num = 4;
        kzg_params.points_num = 12;
        kzg_params.theta   = 0x146669b8f0f804db1f65879b69ebd1eb5a62d5a304f397fe2214f1a09512289;
        kzg_params.theta_2 = 0x60ccd0177322ae60e62f674ae1f0594ef507a2296f0fe7ea45537a2493e5c6a;
        kzg_params.verification_key = bn254_crypto.new_g2(
            18551411094430470096460536606940536822990217226529861227533666875800903099477,
            15512671280233143720612069991584289591749188907863576513414377951116606878472,
            1711576522631428957817575436337311654689480489843856945284031697403898093784,
            13376798835316611669264291046140500151806347092962367781523498857425536295743);


        types.kzg_proof_type memory kzg_proof;
        kzg_proof.pi_1 = bn254_crypto.new_g1(
            0x2a5962762ebd3540336267427860b210e8cd10ceb111d10c279ca20d3419c36f,
            0x79cc53475493803aac3f585ccaf63d893d009dc8c143160098327542c4c6d87);
        kzg_proof.pi_2 = bn254_crypto.new_g1(
            0x28fbae026e8b174c26e0ab3ad4d3e523fa0ed914cfc4b81d206b985108471305,
            0x21532211d9b11dc61e52f52f66f2408d577278b6fc33c6fe83f3a8d089ad1a1c);
        /*
        kzg_proof.pi_1 = bn254_crypt.new_g1(
            0x2a5962762ebd3540336267427860b210e8cd10ceb111d10c279ca20d3419c36f,
            0x79cc53475493803aac3f585ccaf63d893d009dc8c143160098327542c4c6d87);
        kzg_proof.pi_2 = bn254_crypt.new_g1(
            0x28fbae026e8b174c26e0ab3ad4d3e523fa0ed914cfc4b81d206b985108471305,
            0x21532211d9b11dc61e52f52f66f2408d577278b6fc33c6fe83f3a8d089ad1a1c);
        */

        types.transcript_data memory tr_state;
        transcript.init_transcript(tr_state, hex"");

        result = batched_kzg_verifier.verify_proof(commitments, Z, U, tr_state, kzg_params, kzg_proof);
        emit VerificationResult(result);
    }

}
