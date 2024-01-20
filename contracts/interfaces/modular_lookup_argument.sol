// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2023 Elena Tatuzova <e.tatuzova@nil.foundation>
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

interface ILookupArgument {
    function verify(
        bytes calldata blob, // Table values and permutations' values
        bytes calldata sorted, // Sorted batch values
        uint256 lookup_commitment, // Lookup commitment
        uint256 l0,
        bytes32 tr_state_before // It's better than transfer all random values
    ) external view returns (uint256[4] memory F, bytes32 tr_state_after);
}
