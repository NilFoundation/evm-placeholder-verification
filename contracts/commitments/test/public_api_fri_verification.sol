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

import "../../types.sol";
import "../fri_verifier.sol";
import "../batched_fri_verifier.sol";
import "../../cryptography/transcript.sol";

contract TestFriVerifier {
    bool m_result;
    uint256 m_proof_size;
    types.fri_params_type m_params;

    function set_params(
        uint256 modulus,
        uint256 r,
        uint256 max_degree
    ) public {
        m_params.modulus = modulus;
        m_params.r = r;
        m_params.max_degree = max_degree;
    }

    function set_q(uint256[] calldata q) public {
        m_params.q = q;
    }

    function set_D_omegas(uint256[] calldata D_omegas) public {
        m_params.D_omegas = D_omegas;
    }

    function set_U(uint256[] calldata U) public {
        m_params.U = U;
    }

    function set_V(uint256[] calldata V) public {
        m_params.V = V;
    }

    // TODO: optimize - do not copy params from storage to memory
    function verify(
        bytes calldata raw_proof,
        bytes calldata init_transcript_blob
    ) public {
        types.transcript_data memory tr_state;
        transcript.init_transcript(tr_state, init_transcript_blob);
        (m_result, ) = fri_verifier.parse_verify_proof_be(
            raw_proof,
            0,
            tr_state,
            m_params
        );
        require(
            raw_proof.length == fri_verifier.skip_proof_be(raw_proof, 0),
            "FRI proof length is incorrect!"
        );
        require(
            raw_proof.length == fri_verifier.skip_proof_be_check(raw_proof, 0),
            "FRI proof length is incorrect!"
        );
        require(m_result, "FRI proof is not correct!");
    }

    function batched_verify(
        bytes calldata raw_proof,
        bytes calldata init_transcript_blob,
        // 0) modulus
        // 1) r
        // 2) max_degree
        // 3) leaf_size
        // 4) D_omegas_size
        //  [..., D_omegas_i, ...]
        // 5 + D_omegas_size) q_size
        //  [..., q_i, ...]
        uint256[] calldata init_params,
        uint256[][] calldata U,
        uint256[][] calldata V
    ) public {
        types.transcript_data memory tr_state;
        transcript.init_transcript(tr_state, init_transcript_blob);
        types.fri_params_type memory fri_params;
        uint256 idx = 0;
        fri_params.modulus = init_params[idx++];
        fri_params.r = init_params[idx++];
        fri_params.max_degree = init_params[idx++];
        fri_params.leaf_size = init_params[idx++];
        fri_params.D_omegas = new uint256[](init_params[idx++]);
        for (uint256 i = 0; i < fri_params.D_omegas.length; i++) {
            fri_params.D_omegas[i] = init_params[idx++];
        }
        fri_params.q = new uint256[](init_params[idx++]);
        for (uint256 i = 0; i < fri_params.q.length; i++) {
            fri_params.q[i] = init_params[idx++];
        }
        fri_params.batched_U = U;
        fri_params.batched_V = V;
        require(
            raw_proof.length ==
                batched_fri_verifier.skip_proof_be(raw_proof, 0),
            "Batched fri proof length is not correct!"
        );
        require(
            raw_proof.length ==
                batched_fri_verifier.skip_proof_be_check(raw_proof, 0),
            "Batched fri proof length is not correct!"
        );
        require(
            batched_fri_verifier.parse_verify_proof_be(
                raw_proof,
                0,
                tr_state,
                fri_params
            ),
            "Batched fri proof verification failed!"
        );
    }
}
