// SPDX-License-Identifier: MIT OR Apache-2.0
//---------------------------------------------------------------------------//
// Copyright (c) 2021 Mikhail Komarov <nemo@nil.foundation>
// Copyright (c) 2021 Ilias Khairullin <ilias@nil.foundation>
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

import "./field.sol";
import "../basic_marshalling.sol";



/**
 * @title Turbo Plonk polynomial evaluation
 * @dev Implementation of Turbo Plonk's polynomial evaluation algorithms
 *
 * Expected to be inherited by `TurboPlonk.sol`
 */
library polynomial {
    uint256 constant LENGTH_OCTETS = 8;

    function multiply_poly_on_coeff(uint256[] memory coeffs, uint256 mul, uint256 modulus)
    internal pure{
        for(uint256 i = 0; i < coeffs.length; i++){
            coeffs[i] =  mulmod(coeffs[i], mul, modulus);
        }
    }

    /*
      Computes the evaluation of a polynomial f(x) = sum(a_i * x^i) on the given point.
      The coefficients of the polynomial are given in
        a_0 = coefsStart[0], ..., a_{n-1} = coefsStart[n - 1]
      where n = nCoeffs = friLastLayerDegBound. Note that coefsStart is not actually an array but
      a direct pointer.
      The function requires that n is divisible by 8.
    */
    function evaluate(uint256[] memory coeffs, uint256 point, uint256 modulus)
    internal pure returns (uint256) {
        uint256 result;
        for (uint i=coeffs.length -1; i>=0 ; i--){
            uint256 mul_m = mulmod(result,point,modulus);
            result = addmod(mul_m,coeffs[i],modulus);
        }
//        assembly {
//            let cur_coefs := add(coeffs, mul(mload(coeffs), 0x20)
//            )
//            for { } gt(cur_coefs, coeffs) {} {
//                result := addmod(mulmod(result, point, modulus),
//                                mload(cur_coefs), // (i - 1) * 32
//                                modulus)
//                cur_coefs := sub(cur_coefs, 0x20)
//            }
//        }
        return result;
    }
}
