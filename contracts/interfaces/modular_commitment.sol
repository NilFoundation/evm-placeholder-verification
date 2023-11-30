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

pragma solidity >=0.8.4;

import "../types.sol";

interface ICommitmentScheme {

    function initialize(
        bytes32 tr_state_before
    ) external returns(bytes32 tr_state_after);

    // Append commitments
    function verify_eval(
        bytes calldata blob,
        uint256[5] memory commitments,
        uint256 challenge,
        bytes32 transcript_state_before
    ) external view returns (bool);
}
