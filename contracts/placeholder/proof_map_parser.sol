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
import "../commitments/batched_lpc_verifier.sol";
import "../basic_marshalling.sol";

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
