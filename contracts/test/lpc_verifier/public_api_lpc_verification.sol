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
import "../../commitments/batched_lpc_verifier.sol";
import "../../cryptography/transcript.sol";

contract TestLpcVerifier {
    bool m_result;

    function allocate_all(types.fri_params_type memory fri_params, uint256 max_step, uint256 max_batch) internal view{
        uint256 max_coset = 1 << (fri_params.max_step - 1);

        fri_params.max_coset = max_coset;
        fri_params.s_indices = new uint256[](max_coset);
        fri_params.s = new uint256[](max_coset);
        fri_params.correct_order_idx = new uint256[](max_coset);
        fri_params.tmp_arr = new uint256[](max_coset << 1);
    }

    function batched_verify(
        bytes calldata raw_proof,
        // 0) modulus
        // 1) r
        // 2) max_degree
        // 3) lambda
        // 4) batches_num
        // 5) D_omegas_size
        //  [..., D_omegas_i, ...]
        // 6)step_list_size
        //  [..., step_list_i, ...]
        uint256[] calldata init_params,
        uint256[][][] calldata evaluation_points
    ) public {
        types.transcript_data memory tr_state;
        transcript.init_transcript(tr_state, hex"");
        types.fri_params_type memory fri_params;


        // Load params from init_params structure
        uint256 idx = 0;
        fri_params.modulus = init_params[idx++];

        fri_params.r = init_params[idx++];
        fri_params.max_degree = init_params[idx++];
        fri_params.lambda = init_params[idx++];
        uint256 omega = init_params[idx++];
        fri_params.D_omegas = new uint256[](init_params[idx++]);
        for (uint256 i = 0; i < fri_params.D_omegas.length; i++) {
            fri_params.D_omegas[i] = init_params[idx++];
        }
        fri_params.step_list = new uint256[](init_params[idx++]);
        uint256 sum = 0;
        fri_params.max_step = 0;
        for (uint256 i = 0; i < fri_params.step_list.length; i++) {
            fri_params.step_list[i] = init_params[idx++];
            if(fri_params.step_list[i] > fri_params.max_step) fri_params.max_step = fri_params.step_list[i]; 
            sum += fri_params.step_list[i];
        }
        fri_params.max_batch = 0;
        fri_params.batches_num = init_params[idx++];
        fri_params.batches_sizes = new uint256[](fri_params.batches_num);
        for (uint256 i = 0; i < fri_params.batches_num; i++) {
            fri_params.batches_sizes[i] = init_params[idx++];
            fri_params.poly_num += fri_params.batches_sizes[i];
            if( fri_params.batches_sizes[i] > fri_params.max_batch ) fri_params.max_batch = fri_params.batches_sizes[i];
        }

        require(sum == fri_params.r, "Sum of fri_params.step_list and fri_params.r are different");
        
        allocate_all(fri_params, fri_params.max_step, fri_params.max_batch);
        require(
            raw_proof.length == batched_lpc_verifier.skip_proof_be(raw_proof, 0),
            "Batched lpc proof length is not correct!"
        );

        batched_lpc_verifier.parse_proof_be(fri_params, raw_proof, 0);

        uint256[] memory roots = batched_lpc_verifier.extract_merkle_roots(raw_proof, fri_params);
        // We need Merkle roots for all batches.
        // In the full placeholder version they'll be extracted from placeholder proof.
        // But in lpc test they're just extracted from the fri_proof.query_proof[0].initial_proof[i].p.root
        require(
            batched_lpc_verifier.verify_proof_be(
                raw_proof,
                0,
                roots,
                evaluation_points,
                tr_state,
                fri_params
            ),
            "Batched lpc proof verification failed!"
        );
    }
}
