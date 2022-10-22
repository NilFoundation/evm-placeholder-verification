// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2022 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2022 Ilias Khairullin <ilias@nil.foundation>
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

import "../../types.sol";
import "../../cryptography/transcript.sol";
import "../proof_map_parser.sol";
import "../verifier_mina_component.sol";
import "../verifier_mina_base_component.sol";
import "../../logging.sol";
import "../verifier_unified_addition_component.sol";

contract TestPlaceholderComponentMix {
    uint256 constant UNIFIED_ADDITION_COMPONENT_ID = 0;
    uint256 constant MINA_COMPONENT_ID = 1;
    uint256 constant MINA_BASE_COMPONENT_ID = 2;

    struct test_local_vars {
        uint256 proofs_num;
        uint256 ind;

        types.placeholder_proof_map proof_map;
        uint256 proof_offset;
        uint256 proof_size;
        types.transcript_data tr_state;
        types.fri_params_type fri_params;
        types.placeholder_common_data common_data;
    }

    function init_vars(test_local_vars memory vars, uint256[] memory init_params, int256[][] memory columns_rotations) internal view{
        uint256 idx = 0;
        vars.fri_params.modulus = init_params[idx++];
        vars.fri_params.r = init_params[idx++];
        vars.fri_params.max_degree = init_params[idx++];
        vars.fri_params.lambda = init_params[idx++];

        vars.common_data.rows_amount = init_params[idx++];
        vars.common_data.omega = init_params[idx++];
        vars.fri_params.max_batch = init_params[idx++];
        placeholder_proof_map_parser.init(vars.fri_params, vars.fri_params.max_batch);

        vars.common_data.columns_rotations = columns_rotations;

        vars.fri_params.D_omegas = new uint256[](init_params[idx++]);
        for (uint256 i = 0; i < vars.fri_params.D_omegas.length;) {
            vars.fri_params.D_omegas[i] = init_params[idx];
            unchecked{ i++; idx++;}
        }
        vars.fri_params.q = new uint256[](init_params[idx++]);
        for (uint256 i = 0; i < vars.fri_params.q.length;) {
            vars.fri_params.q[i] = init_params[idx];
            unchecked{ i++; idx++;}
        }

        vars.fri_params.step_list = new uint256[](init_params[idx++]);
        vars.fri_params.max_step = 0;
        for (uint256 i = 0; i < vars.fri_params.step_list.length;) {
            vars.fri_params.step_list[i] = init_params[idx];
            if(vars.fri_params.step_list[i] > vars.fri_params.max_step)
                vars.fri_params.max_step = vars.fri_params.step_list[i];
            unchecked{ i++; idx++;}
        }
    }

    function allocate_all(test_local_vars memory vars, uint256 max_step, uint256 max_batch) internal view{
        uint256 max_coset = 1 << (vars.fri_params.max_step - 1);

        vars.fri_params.s_indices = new uint256[2][](max_coset);
        vars.fri_params.s = new uint256[2][](max_coset);
        vars.fri_params.correct_order_idx = new uint256[2][](max_coset);

        vars.fri_params.ys[0] = new uint256[2][][](max_batch);
        vars.fri_params.ys[1] = new uint256[2][][](max_batch);
        vars.fri_params.ys[2] = new uint256[2][][](max_batch);

        for(uint256 i = 0; i < vars.fri_params.max_batch;){
            vars.fri_params.ys[0][i] = new uint256[2][](max_coset);
            vars.fri_params.ys[1][i] = new uint256[2][](max_coset);
            vars.fri_params.ys[2][i] = new uint256[2][](max_coset);
            unchecked{i++;}
        }

        vars.fri_params.b = new bytes(0x40 * vars.fri_params.max_batch * max_coset);
    }

    function verify(
        bytes calldata blob,
        // 0) modulus
        // 1) r
        // 2) max_degree
        // 3) lambda
        // 4) rows_amount
        // 5) omega
        // 6) max_leaf_size
        // 7) D_omegas_size
        //  [..., D_omegas_i, ...]
        // 8 + D_omegas_size) q_size
        //  [..., q_i, ...]
        uint256[][] calldata init_params,
        int256[][][] calldata columns_rotations
    ) public {
        test_local_vars memory vars;
        vars.proofs_num = init_params[0].length;
        uint256 max_step = 0;
        uint256 max_batch = 0;

        for( vars.ind = 0; vars.ind < vars.proofs_num; ){
            init_vars(vars, init_params[vars.ind+1], columns_rotations[vars.ind]);
            if(vars.fri_params.max_step > max_step) max_step = vars.fri_params.max_step;
            if(vars.fri_params.max_batch > max_step) max_batch = vars.fri_params.max_batch;
            unchecked{ vars.ind++; }
        }
        allocate_all(vars, max_step, max_batch);

        // Map parser for each proof.
        vars.proof_offset = 0;
        for( vars.ind = 0; vars.ind < vars.proofs_num; ){
            (vars.proof_map, vars.proof_size) = placeholder_proof_map_parser.parse_be(blob, vars.proof_offset);
            require(vars.proof_size <= blob.length, "Proof length was detected incorrectly!");
            init_vars(vars, init_params[vars.ind + 1], columns_rotations[vars.ind]);
            transcript.init_transcript(vars.tr_state, hex"");
            if( init_params[0][vars.ind] ==  UNIFIED_ADDITION_COMPONENT_ID ){
                //require(false, "Call unified addition");
                require(
                    placeholder_verifier_unified_addition_component.verify_proof_be(
                        blob,
                        vars.tr_state,
                        vars.proof_map,
                        vars.fri_params,
                        vars.common_data
                    ),
                    "Proof is not correct!"
                );
            } else if( init_params[0][vars.ind] ==  MINA_COMPONENT_ID ){
                require(false, "Call mina scalar component verifier");
                /*require(
                    placeholder_verifier_mina_component.verify_proof_be(
                        blob,
                        vars.tr_state,
                        vars.proof_map,
                        vars.fri_params,
                        vars.common_data
                    ),
                    "Proof is not correct!"
                );*/
            } else if(  init_params[0][vars.ind] ==  MINA_BASE_COMPONENT_ID ){
                require(false, "Call mina base component verifier");
                /*
                require(
                    placeholder_verifier_mina_base_component.verify_proof_be(
                        blob,
                        vars.tr_state,
                        vars.proof_map,
                        vars.fri_params,
                        vars.common_data
                    ),
                    "Proof is not correct!"
                );
                */
            } else{
                require(false, "Unknown component");
            }
            unchecked{
                vars.ind++;
                vars.proof_offset += vars.proof_size;
            }
        }
    }
}
