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

import '../../../contracts/algebra/uint512.sol';
import 'hardhat/console.sol';

contract test_uint512 {

    uint256 constant not0 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function test_create() public pure {
        uint512.uint512_t memory a = uint512.uint512_t(0x1, 0);
        require(a.l == 0x1 && a.h == 0, "Creation from single uint256 failed");
        a = uint512.uint512_t(0x2, 0x3);
        require(a.l == 0x2 && a.h == 0x3, "Creation from two uint256 failed");
    }

    function test_add() public pure {
        uint512.uint512_t memory a = uint512.uint512_t(0x12345, 0);
        uint512.uint512_t memory b = uint512.uint512_t(0x23456, 0);
        a = uint512.add(a, b);
        require(a.l == 0x3579b && a.h == 0, "Addition does not work");

        a = uint512.uint512_t(0, 0x12345);
        b = uint512.uint512_t(0, 0x23456);
        a = uint512.add(a, b);
        require(a.h == 0x3579b && a.l == 0, "Addition does not work");

        a = uint512.uint512_t(not0, 0x12345);
        b = uint512.uint512_t(1, 0);
        a = uint512.add(a, b);
        require(a.l == 0 && a.h == 0x12346, "Addition with wrapping does not work");

        a = uint512.uint512_t(not0, not0);
        b = uint512.uint512_t(1, 0);
        a = uint512.add(a, b);
        require(a.l == 0 && a.h == 0, "Addition with overflow does not work");

        a = uint512.uint512_t(not0, not0);
        b = uint512.uint512_t(not0, not0);
        a = uint512.add(a, b);
        b = uint512.uint512_t(2, 0);
        a = uint512.add(a, b);
        require(a.l == 0 && a.h == 0, "Addition with overflow does not work");
    }

    function test_sub() public pure {
        uint512.uint512_t memory a = uint512.uint512_t(0x12345, 0);
        uint512.uint512_t memory b = uint512.uint512_t(0x23456, 0);
        a = uint512.sub(b, a);
        require(a.l == 0x11111 && a.h == 0, "Subtraction does not work");

        a = uint512.uint512_t(0, 0x12345);
        b = uint512.uint512_t(0, 0x23456);
        a = uint512.sub(b, a);
        require(a.h == 0x11111 && a.l == 0, "Subtraction does not work");

        a = uint512.uint512_t(0, 0x12345);
        b = uint512.uint512_t(1, 0);
        a = uint512.sub(a, b);
        require(a.l == not0 && a.h == 0x12344, "Subtraction with wrapping does not work");

        a = uint512.uint512_t(1, 0);
        b = uint512.uint512_t(not0, not0);
        a = uint512.sub(a, b);
        require(a.l == 2 && a.h == 0, "Subtraction with borrow does not work");

        a = uint512.uint512_t(0, 0);
        b = uint512.uint512_t(1, 0);
        a = uint512.sub(a, b);
        require(a.l == not0 && a.h == not0, "Subtraction with borrow does not work");
    }

    function test_mul() public pure {
        
        uint512.uint512_t memory a = uint512.mul(0x12345, 0x23456);
        require(a.l == 0x28215dd2e && a.h == 0, "Multiplication does not work");
        
        a = uint512.mul(not0, not0);
        require(a.l == 1 && a.h == not0-1, "Multiplication does not work");
        
        a = uint512.uint512_t(not0, not0);
        a = uint512.mul(a, not0);
        require(a.l == 1 && a.h == not0, "Multiplication does not work");

        uint512.uint512_t memory b = uint512.uint512_t(not0, not0);
        a = uint512.uint512_t(not0, not0);
        a = uint512.mul(a, b);
        require(a.l == 1 && a.h == 0, "Multiplication does not work");
    }
}
