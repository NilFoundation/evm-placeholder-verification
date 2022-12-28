pragma solidity >=0.8.4;

import "../types.sol";
import "../algebra/polynomial.sol";
import "../logging.sol";
import "../profiling.sol";

library commitment_calc{
    function eval3_precompute(uint256 s0, uint256 xi0, uint256 xi1, uint256 xi2, uint256 modulus) 
    internal pure returns (uint256[9] memory out){
        out[0] = field.fmul(field.fadd(s0,modulus-xi0, modulus),field.fmul(field.fadd(s0,modulus-xi1,modulus),field.fadd(s0, modulus-xi2, modulus), modulus), modulus);
        out[1] = modulus - field.fmul(field.fadd(s0,xi0, modulus),field.fmul(field.fadd(s0,xi1,modulus),field.fadd(s0, xi2, modulus), modulus), modulus);

        out[2] = field.fmul(field.fadd(xi1, modulus-xi2, modulus), field.fmul(field.fadd(s0, modulus - xi1, modulus),field.fadd(s0, modulus - xi2, modulus),modulus), modulus);
        out[3] = field.fmul(field.fadd(xi2, modulus-xi0, modulus), field.fmul(field.fadd(s0, modulus - xi0, modulus),field.fadd(s0, modulus - xi2, modulus),modulus), modulus);
        out[4] = field.fmul(field.fadd(xi0, modulus-xi1, modulus), field.fmul(field.fadd(s0, modulus - xi0, modulus),field.fadd(s0, modulus - xi1, modulus),modulus), modulus);


        out[5] = field.fmul(field.fadd(xi1, modulus-xi2, modulus), field.fmul(field.fadd(s0, xi1, modulus),field.fadd(s0, xi2, modulus),modulus), modulus);
        out[6] = field.fmul(field.fadd(xi2, modulus-xi0, modulus), field.fmul(field.fadd(s0, xi0, modulus),field.fadd(s0, xi2, modulus),modulus), modulus);
        out[7] = field.fmul(field.fadd(xi0, modulus-xi1, modulus), field.fmul(field.fadd(s0, xi0, modulus),field.fadd(s0, xi1, modulus),modulus), modulus);

        out[8] = field.fmul(field.fadd(xi0, modulus - xi1, modulus), field.fmul(field.fadd(xi1, modulus- xi2, modulus), field.fadd(xi2, modulus - xi0, modulus), modulus), modulus);
    }
/*  This function output is different for each of lambda FRI rounds, because s0 depends on challenge x.
    Precomputed array is similar for all polynomials with similar evaluation points
        0 -- V(s0)  = (s0 - xi0)(s0 - xi1)(s0 - xi2)
        1 -- V(-s0) = (-s0 - xi0)(-s0 - xi1)(-s0 - xi2) = -(s0 + xi0)(s0 + xi1)(s0 + xi2)
        2 -- c00 = (xi1 - xi2)(s0 - xi1)(s0 - xi2)
        3 -- c01 = (xi2 - xi0)(s0 - xi0)(s0 - xi2)
        4 -- c02 = (xi0 - xi1)(s0 - xi0)(s0 - xi1)
        5 -- c10 = (xi1 - xi2)(-s0 - xi1)(-s0 - xi2) = (xi1 - xi2)(s0 + xi1)(s0 + xi2)
        6 -- c11 = (xi2 - xi0)(-s0 - xi0)(-s0 - xi2) = (xi2 - xi0)(s0 + xi0)(s0 + xi2)
        7 -- c12 = (xi0 - xi1)(-s0 - xi0)(-s0 - xi1) = (xi0 - xi1)(s0 + xi0)(s0 + xi1)
        8 -- Sigma = (xi0 - xi1) * (xi1 - xi2) * (xi2 - xi0)
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
        2 * c * Sigma * x * V(s0) * V(-s0) == (V(-s0)*c0)(y0*Sigma + c00*z0 + c01*z1 + c02*z2) + (V(s0)*c1)(y1*Sigma + c10*z0 + c11*z1 + c12*z2) 
    This calculation is expensive. 
    So we store all precomputed values for each triple evaluation points.
*/
    function eval3_colinear_check(
        uint256[9] memory precomputed, uint256[9] memory input, uint256 modulus
    )internal view returns(bool b){
        uint256 interpolant = field.fadd(
            field.fmul(
                field.fmul(precomputed[1], input[3], modulus),
                field.fadd(
                    field.fadd(
                        field.fmul(input[5], precomputed[8], modulus),
                        field.fmul(input[0], precomputed[2], modulus),
                        modulus
                    ),
                    field.fadd(
                        field.fmul(input[1], precomputed[3], modulus),
                        field.fmul(input[2], precomputed[4], modulus),
                        modulus
                    ),
                    modulus
                ),
                modulus
            ),
            field.fmul(
                field.fmul(precomputed[0],input[4], modulus),
                field.fadd(
                    field.fadd(
                        field.fmul(input[6], precomputed[8], modulus),
                        field.fmul(input[0], precomputed[5], modulus),
                        modulus
                    ),
                    field.fadd(
                        field.fmul(input[1], precomputed[6], modulus),
                        field.fmul(input[2], precomputed[7], modulus),
                        modulus
                    ),
                    modulus
                ),
                modulus
            ),
            modulus
        );

        uint256 c = field.fmul(
            field.fmul(field.fmul(input[7], input[8], modulus), precomputed[8], modulus), 
            field.fmul(precomputed[0], precomputed[1], modulus), 
            modulus
        );
        c = field.fadd(c, c, modulus);

        if( interpolant == c ) {
            return true;
        } else {
            return false;
        }
   }

    function eval2_precompute(uint256 s0, uint256 xi0, uint256 xi1, uint256 modulus) 
    internal pure returns(uint256[7] memory out){
        out[0] = field.fmul(field.fadd(s0, modulus - xi0, modulus), field.fadd(s0, modulus - xi1, modulus), modulus );
        out[1] = field.fmul(field.fadd(s0, xi0, modulus), field.fadd(s0, xi1, modulus), modulus );
        out[2] = field.fadd(s0, modulus-xi1, modulus);
        out[3] = field.fadd(xi0, modulus-s0, modulus);
        out[4] = modulus - field.fadd(s0, xi1, modulus);
        out[5] = field.fadd(xi0, s0, modulus);
        out[6] = field.fadd(xi1, modulus - xi0, modulus);
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
        uint256 interpolant = field.fadd(
            field.fmul(
                field.fadd(
                    field.fadd(
                        field.fmul(input[0],precomputed[2], modulus), 
                        field.fmul(input[1],precomputed[3], modulus), 
                        modulus
                    ),
                    field.fmul(precomputed[6],input[4],modulus),
                    modulus
                ),
                field.fmul(precomputed[1], input[2], modulus),
                modulus
            ),
            field.fmul(
                field.fadd(
                    field.fadd(
                        field.fmul(input[0],precomputed[4], modulus), 
                        field.fmul(input[1],precomputed[5],modulus), 
                        modulus),
                    field.fmul(input[5], precomputed[6],modulus),
                    modulus
                ),
                field.fmul(input[3], precomputed[0], modulus),
                modulus
            ),
            modulus
        );

        uint256 c = field.fmul(
            field.fmul(
                field.fmul(input[6],input[7], modulus),
                field.fmul(precomputed[0], precomputed[1], modulus),
                modulus
            ),
            precomputed[6], 
            modulus
        );
        c = field.fadd(c, c, modulus);
        if(interpolant == c){
            return true;
        }
        return false;
    }
}