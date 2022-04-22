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
import "../verifier_unified_addition_component.sol";

contract TestPlaceholderVerifierUnifiedAddition {
    struct test_local_vars {
        types.placeholder_proof_map proof_map;
        uint256 proof_size;
        types.transcript_data tr_state;
        types.lpc_params_type lpc_params;
        types.batched_fri_params_type fri_params;
        types.placeholder_common_data common_data;
    }

    function verify(
        bytes calldata blob,
        // 0) modulus
        // 1) r
        // 2) max_degree
        // 3) leaf_size
        // 4) lambda
        // 5) rows_amount
        // 6) omega
        // 7) D_omegas_size
        //  [..., D_omegas_i, ...]
        // 8 + D_omegas_size) q_size
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

        uint256 idx = 0;
        vars.fri_params.modulus = init_params[idx++];
        vars.fri_params.r = init_params[idx++];
        vars.fri_params.max_degree = init_params[idx++];
        vars.fri_params.leaf_size = init_params[idx++];
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

        vars.lpc_params.modulus = vars.fri_params.modulus;
        vars.lpc_params.lambda = vars.fri_params.lambda;
        vars.lpc_params.r = vars.fri_params.r;
        vars.lpc_params.m = 2;
        vars.lpc_params.fri_params.D_omegas = vars.fri_params.D_omegas;
        vars.lpc_params.fri_params.q = vars.fri_params.q;

        vars.lpc_params.fri_params.modulus = vars.fri_params.modulus;
        vars.lpc_params.fri_params.max_degree = vars.fri_params.max_degree;
        vars.lpc_params.fri_params.r = vars.fri_params.r;

        require(
            placeholder_verifier_unified_addition_component.verify_proof_be(
                blob,
                vars.tr_state,
                vars.proof_map,
                vars.lpc_params,
                vars.fri_params,
                vars.common_data
            ),
            "Proof is not correct!"
        );
    }
}
