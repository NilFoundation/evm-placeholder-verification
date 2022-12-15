pragma solidity >=0.8.4;

import "../types.sol";
//import "../algebra/field.sol";
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
/*  precomputed
        0 -- V(x)
        1 -- V(-x)
        2 -- c00
        3 -- c01
        4 -- c02
        5 -- c10
        6 -- c11
        7 -- c12
        8 -- Sigma
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

/*  precomputed
        0 -- V(x)
        1 -- V(-x)
        2 -- c00
        3 -- c01
        4 -- c10
        5 -- c11
        6 -- xi1 - xi0
    input    
        0 -- z0
        1 -- z1
        2 -- c0
        3 -- c1
        4 -- y0
        5 -- y1
        6 -- c
        7 -- x
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