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

import "../types.sol";
import "../logging.sol";
import "../commitments/batched_lpc_verifier.sol";
import "../basic_marshalling.sol";

library placeholder_proof_map_parser {
    /**
     * Proof structure: https://github.com/NilFoundation/crypto3-zk-marshalling/blob/master/include/nil/crypto3/marshalling/zk/types/placeholder/proof.hpp
     */
    function parse_be(bytes calldata blob, uint256 offset)
    internal pure returns (types.placeholder_proof_map memory proof_map, uint256 proof_size){

        proof_map.witness_commitment_offset = offset;
        // skip witness_commitment
        proof_map.v_perm_commitment_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, proof_map.witness_commitment_offset);
        // skip v_perm_commitment
        proof_map.input_perm_commitment_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, proof_map.v_perm_commitment_offset);
        // skip input_perm_commitment
        proof_map.value_perm_commitment_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, proof_map.input_perm_commitment_offset);
        // skip value_perm_commitment
        proof_map.v_l_perm_commitment_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, proof_map.value_perm_commitment_offset);
        // skip v_l_perm_commitment
        proof_map.T_commitments_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, proof_map.v_l_perm_commitment_offset);
        // skip T_commitment
        proof_map.eval_proof_offset = basic_marshalling.skip_octet_vector_32_be_check(blob, proof_map.T_commitments_offset);
        // skip challenge
        proof_map.eval_proof_lagrange_0_offset = basic_marshalling.skip_uint256_be_check(blob, proof_map.eval_proof_offset);
        // skip lagrange_0
        proof_map.eval_proof_witness_offset = basic_marshalling.skip_uint256_be_check(blob, proof_map.eval_proof_lagrange_0_offset);

        // skip witness
        proof_map.eval_proof_permutation_offset = batched_lpc_verifier.skip_proof_be_check(blob, proof_map.eval_proof_witness_offset);
        // skip permutation
        proof_map.eval_proof_quotient_offset = batched_lpc_verifier.skip_proof_be_check(blob, proof_map.eval_proof_permutation_offset);
        // skip quotient
        proof_map.eval_proof_lookups_offset = batched_lpc_verifier.skip_proof_be_check(blob, proof_map.eval_proof_quotient_offset);
        // skip lookups
        proof_map.eval_proof_id_permutation_offset = batched_lpc_verifier.skip_vector_of_proofs_be_check(blob, proof_map.eval_proof_lookups_offset);
        // skip id_permutation
        proof_map.eval_proof_sigma_permutation_offset = batched_lpc_verifier.skip_proof_be_check(blob, proof_map.eval_proof_id_permutation_offset);
        // skip sigma_permutation
        proof_map.eval_proof_public_input_offset = batched_lpc_verifier.skip_proof_be_check(blob, proof_map.eval_proof_sigma_permutation_offset);
        // skip public_input
        proof_map.eval_proof_constant_offset = batched_lpc_verifier.skip_proof_be_check(blob, proof_map.eval_proof_public_input_offset);
        // skip constant
        proof_map.eval_proof_selector_offset = batched_lpc_verifier.skip_proof_be_check(blob, proof_map.eval_proof_constant_offset);
        // skip selector
        proof_map.eval_proof_special_selectors_offset = batched_lpc_verifier.skip_proof_be_check(blob, proof_map.eval_proof_selector_offset);
        // skip special_selectors
        proof_size = batched_lpc_verifier.skip_proof_be_check(blob, proof_map.eval_proof_special_selectors_offset) - offset;
    }

    function init(types.fri_params_type memory fri_params, uint256 max_leaf_size)
    internal pure {
        fri_params.batched_fri_verified_data = new bytes(0x20 * max_leaf_size);
        fri_params.batched_U = new uint256[][](max_leaf_size);
        fri_params.batched_V = new uint256[][](max_leaf_size);
        fri_params.lpc_z = new uint256[](2);
        fri_params.lpc_z[1] = 1;
    }
}
