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
import "../../cryptography/transcript.sol";
import "../proof_map_parser.sol";
import "../permutation_argument.sol";

contract TestPermutationArgument {
    struct test_local_vars {
        types.placeholder_proof_map proof_map;
        uint256 proof_size;
        types.placeholder_local_variables local_vars;
        types.transcript_data tr_state;
        types.fri_params_type fri_params;
        types.placeholder_common_data common_data;
    }
    uint256[] public m_result;

    function eval_argument(
        bytes calldata blob,
        // 0) modulus
        // 1) r
        // 2) max_degree
        // 3) lambda
        // 4) rows_amount
        // 5) omega
        // 6) D_omegas_size
        //  [..., D_omegas_i, ...]
        // 7 + D_omegas_size) q_size
        //  [..., q_i, ...]
        uint256[] calldata init_params,
        int256[][] calldata columns_rotations
    ) public {
        test_local_vars memory vars;
        (vars.proof_map, vars.proof_size) = placeholder_proof_map_parser
            .parse_be(blob, 0);
        require(
            vars.proof_size == blob.length,
            "Proof length was detected incorrectly!"
        );
        transcript.init_transcript(vars.tr_state, hex"");
        transcript.update_transcript_b32_by_offset_calldata(
            vars.tr_state,
            blob,
            basic_marshalling.skip_length(
                vars.proof_map.witness_commitment_offset
            )
        );

        uint256 idx = 0;
        vars.fri_params.modulus = init_params[idx++];
        vars.fri_params.r = init_params[idx++];
        vars.fri_params.max_degree = init_params[idx++];
        vars.fri_params.lambda = init_params[idx++];

        vars.common_data.rows_amount = init_params[idx++];
        vars.common_data.omega = init_params[idx++];
        vars.common_data.columns_rotations = columns_rotations;

        vars.fri_params.D_omegas = new uint256[](init_params[idx++]);
        for (uint256 i = 0; i < vars.fri_params.D_omegas.length; i++) {
            vars.fri_params.D_omegas[i] = init_params[idx++];
        }
        vars.fri_params.q = new uint256[](init_params[idx++]);
        for (uint256 i = 0; i < vars.fri_params.q.length; i++) {
            vars.fri_params.q[i] = init_params[idx++];
        }

        m_result = permutation_argument.verify_eval_be(
            blob,
            vars.tr_state,
            vars.proof_map,
            vars.fri_params,
            vars.common_data,
            vars.local_vars
        );
    }

    function get_result(uint256 i) public view returns (uint256 result) {
        result = m_result[i];
    }
}
