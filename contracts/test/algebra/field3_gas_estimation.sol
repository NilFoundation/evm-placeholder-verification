// SPDX-License-Identifier: MIT OR Apache-2.0
//---------------------------------------------------------------------------//
// Copyright (c) 2023 Vasiliy Olekhov <vasiliy.olekhov@nil.foundation>
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

import '../../../contracts/algebra/field3.sol';
import 'hardhat/console.sol';

contract field3_gas_estimation {

    function test_add(uint256 runs) public view returns (uint256[3] memory r) {
        
        uint256[3] memory a = [uint256(1),0,0];
        uint256[3] memory b = [0, runs, 0];
        uint256 gas = gasleft();
        uint256 save_runs = runs;
        unchecked {
            for(;runs>0;runs--) {
                (b[0], b[1], b[2]) = field3.empty(a[0], a[1], a[2], b[0], b[1], b[2]);
            }
        }
        gas = gas-gasleft();
        uint256 per_one = gas / save_runs;
        console.log("Gas used: ", gas, " per one empty call:", per_one);
 
        a = [uint256(1),0,0];
        b = [0, save_runs, 0];
        runs = save_runs;

        gas = gasleft();
        unchecked {
            for(;runs>0;runs--) {
                (b[0], b[1], b[2]) = field3.add(a[0], a[1], a[2], b[0], b[1], b[2]);
            }
        }
        gas = gas-gasleft();
        require(b[0] == save_runs, "add test failed");
        per_one = gas / save_runs;
        console.log("Gas used: ", gas, " per one call:", per_one);
        console.log("Runs: ", save_runs);
        return b;

        /*
        uint256[3] memory a = field3.create(1);
        uint256[3] memory b = field3.create(0, runs);
        uint256 gas = gasleft();
        unchecked {
            for(;runs>0;runs--) {
                b = field3.add(a, b);
            }
        }
        gas = gas-gasleft();
        require(b[0] == b[1], "add test failed");
        uint256 per_one = gas/ b[0];
        console.log("Gas used: ", gas, "per one call:", per_one);
        return b;
        */
    }

    function test_sub(uint256 runs) public view {
        uint256[3] memory b = [runs, runs, 0];
        uint256[3] memory a = [uint256(1),0,0];
        uint256 gas = gasleft();
        unchecked {
            for(;runs>0;runs--) {
                (b[0], b[1], b[2]) = field3.sub(b[0], b[1], b[2], a[0], a[1], a[2]);
            }
        }
        gas = gas-gasleft();
        require(b[0] == 0 && b[2] == 0, "sub test failed");
        uint256 per_one = gas / b[1];
        console.log("Gas used: ", gas, " per one call:", per_one);
        console.log("Runs: ", b[1]);
     }

}
