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

/** Library for two-limbs arithmetic
 * References: HAC - Handbook of applied cryptography, specifically 14th chapter -
 * Efficient implementations
 */
import 'hardhat/console.sol';
library uint512 {



    struct uint512_t {
        uint256 l;
        uint256 h;
    }


    /// @notice addition
    function add(uint512_t memory a, uint512_t memory b) internal pure returns (uint512_t memory r)
    {
        assembly {
            let rl := add( mload(a), mload(b) )
            let rh := add( add( mload( add(a, 0x20)), mload(add(b, 0x20))), lt(rl, mload(a) ) )
            mstore( r, rl )
            mstore( add(r,0x20), rh )
        }
    }

    /// @notice substraction, r = a - b
    function sub(uint512_t memory a, uint512_t memory b) internal pure returns (uint512_t memory r)
    {
        assembly {
            let rl := sub(mload(a), mload(b))
            let rh := sub(sub( mload(add(a,0x20)), mload(add(b,0x20))), lt(mload(a), mload(b)))
            mstore( r, rl )
            mstore( add(r,0x20), rh )
        }
    }

    /// @notice Product of two uint256
    function mul(uint256 a, uint256 b) internal pure returns (uint512_t memory r)
    {
        assembly {
            let mm := mulmod(a, b, not(0))
            let rl := mul(a, b)
            let rh := sub(sub(mm, rl), lt(mm, rl))
            mstore( r, rl )
            mstore( add(r,0x20), rh )
        }
    }

    /// @notice Product of uint512_t and uint256, with wrapping
    function mul(uint512_t memory a, uint256 b) internal pure returns (uint512_t memory r) 
    {
        assembly {
            let al := mload(a)
            let ah := mload(add(a,0x20))
            let mm := mulmod(al, b, not(0))
            let rl := mul(al, b)
            let rh := sub(sub(mm, rl), lt(mm, rl))
            rh := add(rh, mul(ah, b))
            mstore( r, rl )
            mstore( add(r,0x20), rh )
        }
    }

    /// @notice Product of uint512_t and uint512, with wrapping
    function mul(uint512_t memory a, uint512_t memory b) internal pure returns (uint512_t memory r) 
    {
        r = mul(a, b.l);
        uint512_t memory rh = mul(a, b.h);
        rh = uint512_t(0, rh.l);
        r = add(r, rh);
    }

    function mulmodp(uint512_t memory a, uint512_t memory b) internal pure returns (uint512_t memory r)
    {
    }

}

