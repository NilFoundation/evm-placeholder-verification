
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

import "../../interfaces/verifier.sol";

contract TestPlaceholderVerifier {
    address _verifier;

    function initialize(address verifier) public{
        _verifier = verifier;
    }

    function verify(
        bytes calldata blob,
    // 0) modulus
    // 1) r
    // 2) max_degree
    // 3) lambda = 1
    // 4) rows_amount
    // 5) omega
    // 6) max_leaf_size
    // 7) D_omegas_size
    //  [..., D_omegas_i, ...]
    // 8 + D_omegas_size) q_size
    //  [..., q_i, ...]
       uint256[] calldata init_params,
       int256[][] calldata columns_rotations,
       address gate_argument
    ) public view{
        require(
            IVerifier(_verifier).verify(blob,init_params,columns_rotations,gate_argument),
            "Proof is not correct"
        );
    }
}