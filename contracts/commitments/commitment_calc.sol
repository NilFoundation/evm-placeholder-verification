// SPDX-License-Identifier: Apache-2.0.
//---------------------------------------------------------------------------//
// Copyright (c) 2022 Elena Tatuzova <e.tatuzova@nil.foundation>
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
import "../algebra/polynomial.sol";
import "../logging.sol";
import "../profiling.sol";

library commitment_calc{
    function eval3_precompute(uint256 s0, uint256 xi0, uint256 xi1, uint256 xi2, uint256 c0, uint256 c1, uint256 modulus) 
    internal pure returns (uint256[6] memory out){
        uint256[9] memory local;
        local[0] = mulmod(addmod(s0,modulus-xi0, modulus),mulmod(addmod(s0,modulus-xi1,modulus),addmod(s0, modulus-xi2, modulus), modulus), modulus);
        local[1] = modulus - mulmod(addmod(s0,xi0, modulus),mulmod(addmod(s0,xi1,modulus),addmod(s0, xi2, modulus), modulus), modulus);
        local[2] = mulmod(addmod(xi0, modulus - xi1, modulus), mulmod(addmod(xi1, modulus- xi2, modulus), addmod(xi2, modulus - xi0, modulus), modulus), modulus);

        out[5] = mulmod(local[0], local[1], modulus);
        out[5] = mulmod(out[5], local[2], modulus);
        out[5] = mulmod(out[5], s0, modulus);
        out[5] = mulmod(out[5], s0, modulus);
        out[5] = addmod(out[5], out[5], modulus);

        local[0] = mulmod(c1, local[0], modulus); 
        local[1] = mulmod(c0, local[1], modulus);

        local[3] = mulmod(addmod(xi1, modulus-xi2, modulus), mulmod(addmod(s0, modulus - xi1, modulus),addmod(s0, modulus - xi2, modulus),modulus), modulus);
        local[4] = mulmod(addmod(xi1, modulus-xi2, modulus), mulmod(addmod(s0, xi1, modulus),addmod(s0, xi2, modulus),modulus), modulus);
        out[2]= addmod(
            mulmod(local[1], local[3], modulus), 
            mulmod(local[0], local[4], modulus), 
        modulus);

        local[5] = mulmod(addmod(xi2, modulus-xi0, modulus), mulmod(addmod(s0, modulus - xi0, modulus),addmod(s0, modulus - xi2, modulus),modulus), modulus);
        local[6] = mulmod(addmod(xi2, modulus-xi0, modulus), mulmod(addmod(s0, xi0, modulus),addmod(s0, xi2, modulus),modulus), modulus);
        out[3]= addmod(mulmod(local[1], local[5], modulus), mulmod(local[0], local[6], modulus), modulus);

        local[7] = mulmod(local[1], mulmod(addmod(xi0, modulus-xi1, modulus), mulmod(addmod(s0, modulus - xi0, modulus),addmod(s0, modulus - xi1, modulus),modulus), modulus), modulus);
        local[8] = mulmod(local[0], mulmod(addmod(xi0, modulus-xi1, modulus), mulmod(addmod(s0, xi0, modulus),addmod(s0, xi1, modulus),modulus), modulus), modulus);
        out[4]= addmod(
            local[7], 
            local[8], 
            modulus
        );

        out[0] = mulmod(local[1], local[2], modulus);
        out[1]= mulmod(local[0], local[2], modulus);

    }
/*  This function output is different for each of lambda FRI rounds, because s0 depends on challenge x.
    Precomputed array is similar for all polynomials with similar evaluation points
        local[0] = V(s0)  = (s0 - xi0)(s0 - xi1)(s0 - xi2)
        local[1] = V(-s0) = (-s0 - xi0)(-s0 - xi1)(-s0 - xi2) = -(s0 + xi0)(s0 + xi1)(s0 + xi2)
        local[2] = Sigma = (xi0 - xi1) * (xi1 - xi2) * (xi2 - xi0)
        local[3] = c00 = (xi1 - xi2)(s0 - xi1)(s0 - xi2)
        local[4] = (xi2 - xi0)(s0 - xi0)(s0 - xi2)
        local[5] = (xi0 - xi1)(s0 - xi0)(s0 - xi1)
        local[6] = (xi1 - xi2)(-s0 - xi1)(-s0 - xi2) = (xi1 - xi2)(s0 + xi1)(s0 + xi2)
        local[7] = (xi2 - xi0)(-s0 - xi0)(-s0 - xi2) = (xi2 - xi0)(s0 + xi0)(s0 + xi2)
        local[8] = (xi0 - xi1)(-s0 - xi0)(-s0 - xi1) = (xi0 - xi1)(s0 + xi0)(s0 + xi1)

        0 -- V(-s0) * c0 * local[2]
        1-- V(s0) * c1 * local[2]
        2-- V(-s0) * c0 * c00 + V(s0) * c1 * c10
        3-- V(-s0) * c0 * c01 + V(s0) * c1 * c11
        4-- V(-s0) * c0 * c02 + V(s0) * c1 * c12
        5-- 2 * local[2] * V(s0) * V(-s0)
    input
        0 -- z0
        1 -- z1
        2 -- z2
        3 -- c0
        4 -- c1
        5 -- y0
        6 -- y1
        7 -- c      //colinear_value
        8 -- x
    Main equation is
        2 * c * local[2] * x * V(s0) * V(-s0) == (V(-s0)*c0)(y0*local[2] + c00*z0 + c01*z1 + c02*z2) + (V(s0)*c1)(y1*local[2] + c10*z0 + c11*z1 + c12*z2) 
    This calculation is expensive. 
    So we store all precomputed values for each triple evaluation points.
*/
    function eval3_colinear_check(
        uint256[6] memory precomputed, uint256[9] memory input, uint256 modulus
    )internal view returns(bool b){
        uint256 interpolant = addmod(
            addmod(
                addmod(
                    mulmod(input[5], precomputed[0], modulus),
                    mulmod(input[6], precomputed[1], modulus),
                    modulus
                ),
                mulmod(input[2], precomputed[4], modulus),
                modulus
            ),
            addmod(
                mulmod(input[0], precomputed[2], modulus),
                mulmod(input[1], precomputed[3], modulus),
                modulus
            ),
            modulus
        );

        uint256 c = mulmod(precomputed[5], input[7], modulus);
        if( interpolant == c ) {
            return true;
        } else {
            return false;
        }
   }

    function eval2_precompute(uint256 s0, uint256 xi0, uint256 xi1, uint256 modulus) 
    internal pure returns(uint256[7] memory out){
        out[0] = mulmod(addmod(s0, modulus - xi0, modulus), addmod(s0, modulus - xi1, modulus), modulus );
        out[1] = mulmod(addmod(s0, xi0, modulus), addmod(s0, xi1, modulus), modulus );
        out[2] = addmod(s0, modulus-xi1, modulus);
        out[3] = addmod(xi0, modulus-s0, modulus);
        out[4] = modulus - addmod(s0, xi1, modulus);
        out[5] = addmod(xi0, s0, modulus);
        out[6] = addmod(xi1, modulus - xi0, modulus);
    }

/*  This function output is different for lambda FRI rounds, because s0 depends on challenge x.
    precomputed
        0 -- V(s0) = (s0 - xi0)(s0 - xi1)
        1 -- V(-s0) = (-s0 - xi0)(-s0 - xi1) = (s0+xi0)(s0+xi1)
        2 -- c00 = (s0 - xi1)
        3 -- c01 = (xi0 - s0)
        4 -- c10 = (-s0 - xi1) = -(s0 + xi1)
        5 -- c11 = (xi0 + s0)
        6 -- xi1 - xi0
    input    
        0 -- z0
        1 -- z1
        2 -- c0
        3 -- c1
        4 -- y0
        5 -- y1
        6 -- c
        7 -- x = s0^2
    Main equation is
        2cx(xi1-xi0)V(s0)V(-s0) = (V(-s0)c0)[y0(xi0-x1)+c00*z0+c01*z1] + (V(s0)c1)*[y1(xi0-x1)+c10*z0+c11*z1]
    For mina circuits cost of storing additional data is more than cost of recomputing precomputed arrays.
    So we don't store any additional data for the case evaluation points.length == 2
    Another strategy may be more efficient for another circuits
    */
    function eval2_colinear_check(uint256[7] memory precomputed, uint256[8] memory input, uint256 modulus)
    internal view returns(bool b){      
        uint256 interpolant = addmod(
            mulmod(
                addmod(
                    addmod(
                        mulmod(input[0],precomputed[2], modulus), 
                        mulmod(input[1],precomputed[3], modulus), 
                        modulus
                    ),
                    mulmod(precomputed[6],input[4],modulus),
                    modulus
                ),
                mulmod(precomputed[1], input[2], modulus),
                modulus
            ),
            mulmod(
                addmod(
                    addmod(
                        mulmod(input[0],precomputed[4], modulus), 
                        mulmod(input[1],precomputed[5],modulus), 
                        modulus),
                    mulmod(input[5], precomputed[6],modulus),
                    modulus
                ),
                mulmod(input[3], precomputed[0], modulus),
                modulus
            ),
            modulus
        );

        uint256 c = mulmod(
            mulmod(
                mulmod(input[6],input[7], modulus),
                mulmod(precomputed[0], precomputed[1], modulus),
                modulus
            ),
            precomputed[6], 
            modulus
        );
        c = addmod(c, c, modulus);
        if(interpolant == c){
            return true;
        }
        return false;
    }
}