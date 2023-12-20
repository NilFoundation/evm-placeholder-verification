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
pragma solidity >=0.8.4;

import { uint512 } from "./uint512.sol";

/**
 * @title BLS12-381 elliptic curve crypto
 * @dev Provides some basic methods to compute bilinear pairings, construct group elements and misc numerical methods
 */
library bls12_381_crypto {
    
    /* @notice Jacobian coordinates (x/z^2, y/z^3)
       */
    struct g1_point {
        uint512.uint512_t x;
        uint512.uint512_t y;
        uint512.uint512_t z;
    }

    struct g2_point {
        uint512.uint512_t x0;
        uint512.uint512_t x1;
        uint512.uint512_t y0;
        uint512.uint512_t y1;
    }

    // Field prime, 381 bits long
    uint256 constant ph_mod = 0x000000000000000000000000000000001A0111EA397FE69A4B1BA7B6434BACD7;
    uint256 constant pl_mod = 0x64774B84F38512BF6730D2A0F6B0F6241EABFFFEB153FFFFB9FEFFFFFFFFAAAB;

    function g1_to_affine(g1_point memory point, uint512.uint512_t memory p) internal pure returns (g1_point memory r) 
    {
    /*
        uint512.uint512_t memory z = uint512.mulmodp(point.z, point.z, p);
        r.x = uint512.divmodp(point.x, z, p);
        z = uint512.mulmodp(z, point.z, p);
        r.y = uint512.divmodp(point.y, z, p);
        */
    }

    /** @notice Checks whether point (x,y) is on curve. xy is in compressed form, little-endian
      * array should contain only x coordinate (with flags). If point is on curve,
      * the y coordinate is recovered */
    function g1_is_on_curve(uint256[4] memory xy) internal pure returns (bool result)
    {

    }


    /** @notice adds two points on G1
      * https://hyperelliptic.org/EFD/g1p/data/shortw/jacobian-0/addition/add-1998-cmo
     */
    function g1_add(uint256[6] memory a, uint256[6] memory b, uint256[6] memory r) internal pure
    {
        /* layout for temporary vars:
           v[ 0], v[ 1] = U1
           v[ 2], v[ 3] = U2
           v[ 4], v[ 5] = S1
           v[ 6], v[ 7] = S2
           v[ 8], v[ 9] = H
           v[10], v[11] = r
           */
        uint256[12] memory v;

        /* there is a room for optimization - store intermediate Zi^2 in H, r? */

        /* U1 = X1*Z2^2 */
        (v[ 0], v[ 1]) = field3.mulmod_p381(a[ 0], a[ 1], b[ 4], b[ 5]);
        (v[ 0], v[ 1]) = field3.mulmod_p381(v[ 0], v[ 1], b[ 4], b[ 5]);
        /* U2 = X2*Z1^2 */
        (v[ 2], v[ 3]) = field3.mulmod_p381(b[ 0], b[ 0], a[ 4], a[ 5]);
        (v[ 2], v[ 3]) = field3.mulmod_p381(v[ 2], v[ 3], a[ 4], a[ 5]);
        /* S1 = Y1*Z2^3 */
        (v[ 4], v[ 5]) = field3.mulmod_p381(a[ 2], a[ 3], b[ 4], b[ 5]);
        (v[ 4], v[ 5]) = field3.mulmod_p381(v[ 4], v[ 5], b[ 4], b[ 5]);
        (v[ 4], v[ 5]) = field3.mulmod_p381(v[ 4], v[ 5], b[ 4], b[ 5]);
        /* S2 = Y2*Z1^3 */
        (v[ 6], v[ 7]) = field3.mulmod_p381(b[ 2], b[ 3], a[ 4], a[ 5]);
        (v[ 6], v[ 7]) = field3.mulmod_p381(v[ 6], v[ 7], a[ 4], a[ 5]);
        (v[ 6], v[ 7]) = field3.mulmod_p381(v[ 6], v[ 7], a[ 4], a[ 5]);
        /* H = U2 - U1 */
        (v[ 8], v[ 9]) = field3.submod_p381(v[ 2], v[ 3], v[ 0], v[ 1]);
        /* r = S2 - S1 */
        (v[10], v[11]) = field3.submod_p381(v[ 6], v[ 7], v[ 4], v[ 5]);

        /* reuse U2 as H^2 */
        (v[ 2], v[ 3]) = field3.mulmod_p381(v[ 8], v[ 9], v[ 8], v[ 9]);
        /* reuse U1 as U1*H^2 */
        (v[ 0], v[ 1]) = field3.mulmod_p381(v[ 0], v[ 1], v[ 2], v[ 3]); 
        /* reuse S2 as H^3 */
        (v[ 6], v[ 7]) = field3.mulmod_p381(v[ 2], v[ 3], v[ 8], v[ 9]);
        /* reuse S1 as S1*H^3 */
        (v[ 4], v[ 5]) = field3.mulmod_p381(v[ 4], v[ 5], v[ 6], v[ 7]);

        /* X3 = r^2-H^3-2*U1*H^2 */
        (r[ 0], r[ 1]) = field3.mulmod_p381(v[10], v[11], v[10], v[11]);
        (r[ 0], r[ 1]) = field3.submod_p381(r[ 0], r[ 1], v[ 6], v[ 7]);
        (r[ 0], r[ 1]) = field3.submod_p381(r[ 0], r[ 1], v[ 0], v[ 1]);
        (r[ 0], r[ 1]) = field3.submod_p381(r[ 0], r[ 1], v[ 0], v[ 1]);

        /* Y3 = r (U1 H^2-X3)-S1 H^3 */
        (r[ 2], r[ 3]) = field3.submod_p381(v[ 0], v[ 1], r[ 0], r[ 1]);
        (r[ 2], r[ 3]) = field3.mulmod_p381(r[ 2], r[ 3], v[10], v[11]);
        (r[ 2], r[ 3]) = field3.submod_p381(r[ 2], r[ 3], v[ 4], v[ 5]);

        /* Z3 = Z1*Z2*H */
        (r[ 4], p[ 5]) = field3.mulmod_p381(a[ 4], a[ 5], b[ 4], b[ 5]);
        (r[ 4], p[ 5]) = field3.mulmod_p381(r[ 4], r[ 5], v[ 8], v[ 9]);
    }

    /** @notice doubles a point on G1
      * https://hyperelliptic.org/EFD/g1p/data/shortw/jacobian-0/doubling/dbl-2009-l
     */
    function g1_dbl(uint256[6] memory a, uint256[6] memory r) internal pure
    {
        /* layout for temporary vars:
           v[ 0], v[ 1] = A
           v[ 2], v[ 3] = B
           v[ 4], v[ 5] = C
           v[ 6], v[ 7] = D
           v[ 8], v[ 9] = E
           v[10], v[11] = F
           */
        uint256[12] memory v;
        
        /* A = X1^2 */
        (v[ 0], v[ 1]) = field3.mulmod_p381(a[ 0], a[ 1], a[ 0], a[ 1]);
        /* B = Y1^2 */
        (v[ 2], v[ 3]) = field3.mulmod_p381(a[ 2], a[ 3], a[ 2], a[ 3]);
        /* C = B^2 */
        (v[ 4], v[ 5]) = field3.mulmod_p381(v[ 2], v[ 3], v[ 2], v[ 3]);

        /* D = 2 ((X1 + B)^2 - A - C) */
        (v[ 6], v[ 7]) = field3.addmod_p381(a[ 0], a[ 1], v[ 2], v[ 3]); /* X1+B */
        (v[ 6], v[ 7]) = field3.mulmod_p381(v[ 6], v[ 7], v[ 6], v[ 7]); /* ^2 */
        (v[ 6], v[ 7]) = field3.submod_p381(v[ 6], v[ 7], v[ 0], v[ 1]); /* -A */
        (v[ 6], v[ 7]) = field3.submod_p381(v[ 6], v[ 7], v[ 4], v[ 5]); /* -C */
        (v[ 6], v[ 7]) = field3.addmod_p381(v[ 6], v[ 7], v[ 6], v[ 7]); /* *2 */

        /* reuse C as 8*C */
        (v[ 4], v[ 5]) = field3.addmod_p381(v[ 4], v[ 5], v[ 4], v[ 5]); /* 2*C */
        (v[ 4], v[ 5]) = field3.addmod_p381(v[ 4], v[ 5], v[ 4], v[ 5]); /* 4*C */
        (v[ 4], v[ 5]) = field3.addmod_p381(v[ 4], v[ 5], v[ 4], v[ 5]); /* 8*C */

        /* E = 3*A */
        (v[ 8], v[ 9]) = field3.addmod_p381(v[ 0], v[ 1], v[ 0], v[ 1]);
        (v[ 8], v[ 9]) = field3.addmod_p381(v[ 8], v[ 9], v[ 0], v[ 1]);

        /* F = E^2 */
        (v[10], v[11]) = field3.mulmod_p381(v[ 8], v[ 9], v[ 8], v[ 9]);

        /* X3 = F-2*D */
        (r[ 0], r[ 1]) = field3.submod_p381(v[10], v[11], v[ 6], v[ 7]);
        (r[ 0], r[ 1]) = field3.submod_p381(r[ 0], r[ 1], v[ 6], v[ 7]);

        /* Y3 =  E*(D - X3) - 8*C */
        (r[ 2], r[ 3]) = field3.submod_p381(v[ 6], v[ 7], a[ 0], a[ 1]);
        (r[ 2], r[ 3]) = field3.mulmod_p381(r[ 2], r[ 3], v[ 8], v[ 9]);
        (r[ 2], r[ 3]) = field3.submod_p381(r[ 2], r[ 3], v[ 4], v[ 5]);

        /* Z3 = 2*Y1*Z1 */
        (r[ 4], r[ 5]) = field3.mulmod_p381(a[ 2], a[ 3], a[ 4], a[ 5]);
        (r[ 4], r[ 5]) = field3.addmod_p381(r[ 4], r[ 5], r[ 4], r[ 5]);

    }
 


}
