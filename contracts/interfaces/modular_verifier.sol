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

/**
 * @dev Interface class to verify Placeholder proof
 */
interface IModularVerifier {

    /**
     * @dev Emitted when public input is wrong
     */
    event WrongPublicInput();

    /**
     * @dev Emitted when commitment is wrong
     */
    event WrongCommitment();

    /**
     * @dev Emitted when proof does not contain valid eta point values
     */
    event WrongEtaPointValues();

    /**
     * @dev Emitted when table does not satisfy constraint system
     */
    event ConstraintSystemNotSatisfied();

    /**
     * @dev Emitted when proof verification completed
     */
    event VerificationResult(bool result);

    /**
     * @dev Initializes verifier
     */
    function initialize(
        address lookup_argument_contract_address,
        address gate_argument_contract_address,
        address commitment_contract_address
    ) external;

    /**
     * @dev Verifies proof
     */
    function verify(
        bytes calldata blob,
        uint256[] calldata public_input
    ) external returns (bool result);
}
