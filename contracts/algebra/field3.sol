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

/** Library for three-limbs arithmetic
 * References: HAC - Handbook of applied cryptography, specifically 14th chapter -
 * Efficient implementations
 */
import 'hardhat/console.sol';
library field3 {

    uint256 constant not0 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /** @notice empty function, for testing purposes and measurements */
    function empty(uint256 al, uint256 am, uint256 ah,
                 uint256 bl, uint256 bm, uint256 bh) internal pure returns
                (uint256 rl, uint256 rm, uint256 rh)
    {
        return (al,am,ah);
    }

    /** @notice r = a + b */
    function add(uint256 al, uint256 am, uint256 ah,
                 uint256 bl, uint256 bm, uint256 bh) internal pure returns
                (uint256 rl, uint256 rm, uint256 rh)
    {
        assembly {
            rl := add(al, bl)
            rm := add(am, bm)
            rh := add(ah, bh)
            // carry from low to mid
            rm := add(rm, lt(rl, al))
            // carry from mid to hi
            rh := add(rh, or(lt(rm, am), lt(rm,bm)))
        }
    }

    /** @notice r = a - b */
    function sub(uint256 al, uint256 am, uint256 ah,
                 uint256 bl, uint256 bm, uint256 bh) internal pure returns
                (uint256 rl, uint256 rm, uint256 rh)
    {
        assembly {
            rh := sub(ah, bh)
            rm := sub(am, bm)
            rl := sub(al, bl)
            // borrow from mid to low
            rm := sub(rm, lt(al, bl))
            // borrow from hi to mid
            rh := sub(rh, or(lt(am, bm), gt(rm, am)))
        }
    }

    /** @notice Less-than */
    function lt(uint256 al, uint256 am, uint256 ah,
                uint256 bl, uint256 bm, uint256 bh) internal pure returns (bool r)
    {
        if (ah > bh) return false;
        if (ah < bh) return true;
        if (am > bm) return false;
        if (am < bm) return true;
        return (al < bl);
    }

    /** @notice Less-than, but b has two limbs */
    function lt(uint256 al, uint256 am, uint256 ah,
                uint256 bl, uint256 bm) internal pure returns (bool r)
    {
        if (ah > 0) return false;
        if (am > bm) return false;
        if (am < bm) return true;
        return (al < bl);
    }


    /** @notice Compare, -1 - a less than b, 0 - a == b , 1 - a greater than b */
    function cmp(uint256 al, uint256 am, uint256 ah,
                uint256 bl, uint256 bm, uint256 bh) internal pure returns (int r)
    {
        if (ah > bh) return 1;
        if (ah < bh) return -1;
        if (am > bm) return 1;
        if (am < bm) return -1;
        if (al > bl) return 1;
        if (al < bl) return -1;
        return 0;
    }

    /** @notice Same as compare, but b has two limbs */
    function cmp(uint256 al, uint256 am, uint256 ah,
                uint256 bl, uint256 bm) internal pure returns (int r)
    {
        if (ah > 0) return 1;
        if (am > bm) return 1;
        if (am < bm) return -1;
        if (al > bl) return 1;
        if (al < bl) return -1;
        return 0;
    }

    /** @notice Same as compare, but b has two high limbs */
    function cmph(uint256 al, uint256 am, uint256 ah,
                uint256 bm, uint256 bh) internal pure returns (int r)
    {
        if (ah > bh) return 1;
        if (ah < bh) return -1;
        if (am > bm) return 1;
        if (am < bm) return -1;
        if (al > 0) return 1;
        return 0;
    }


    /** @notice a == 1 ? */
    function is_one(uint256 al, uint256 am, uint256 ah) internal pure returns (bool r)
    {
        return (al == 1) && (am == 0) && (ah == 0);
    }

    /** @notice a != 0 */
    function nz(uint256 al, uint256 am, uint256 ah) internal pure returns (bool r)
    {
        return (al != 0) || (am != 0) || (ah != 0);
    }
    
    /** @notice Multiply words, result is two words */
    function mul256x256(uint256 a, uint256 b) internal pure returns (uint256 l, uint256 h)
    {
        assembly {
            let mm := mulmod(a, b, not(0))
            l := mul(a, b)
            h := sub(sub(mm, l), lt(mm, l))
        }
    }

    /** @notice Multiply 3x3 limbs. The result is 6 digits, high 3 are discarded,
     *  because common use case involves multiplication of 384 bits integers */
    function mul3x3(uint256 al, uint256 am, uint256 ah,
                    uint256 bl, uint256 bm, uint256 bh) internal pure returns
                   (uint256 rl, uint256 rm, uint256 rh)
    {
        /* @dev TODO: separate optimized version for 2x2 -> 3 digits? 381x381 bits -> 762 bits*/
        /* @dev TODO: this uses three temporaries, rethink to reuse parameters and return values */
        assembly {
            let mm := mulmod(al, bl, not(0))
            rl := mul(al, bl)
            rm := sub(sub(mm, rl), lt(mm, rl))

            mm := mulmod(am, bl, not(0))
            let t1 := mul(am, bl)
            rh := sub(sub(mm, t1), lt(mm, t1))

            let t2 := mul(ah, bl)
            rh := add(rh, t2)
            rm := add(rm, t1)
            rh := add(rh, lt(rm, t1))

            mm := mulmod(al, bm, not(0))
            t1 := mul(al, bm)
            t2 := sub(sub(mm, t1), lt(mm, t1))

            rm := add(rm, t1)
            rh := add(rh, t2)
            rh := add(rh, mul(am,bm))
            rh := add(rh, lt(rm, t1))
            rh := add(rh, mul(al,bh))
        }
    }

    /** @notice divide three limbs x by two limb y
     *  @dev see HAC 14.20, n = 2, t = 1, b=2^256 */
    function divrem(uint256 xl, uint256 xm, uint256 xh,
                    uint256 yl, uint256 ym) internal view returns
                    (uint256 ql, uint256 qm, uint256 rl, uint256 rm)
    {
    unchecked {

        uint256 tl;
        uint256 tm;
        uint256 th;

        require(ym > 0, "division by short y");

        /* 2. while (x>= y*2^256) do { qm+=1, x -= y*2^256;}  */

        /* This will be at most once for normalized version,
           but we want to keep it in three limbs, as normalization for p381 
           implies shift left for 131 bits */

        console.log("need to divide: ", xm, xh);
        console.log("by            : ", yl, ym);
        qm = xh / ym;
        console.log("first approach: ", qm);

        (tm, th) = mul256x256(qm, yl);
        console.log("qm * xl", tm, th);
        if (th>0) {
            console.log("adj, over by  : ", th);
            console.log("adj, sub  by  : ", th/ym);
            qm -= th/ym ;
            (tm, th) = mul256x256(qm, yl);
        }

        (xl, xm, xh) = sub(xl, xm, xh, 0, tm, th);


    } /* unchecked */
    }

    /* div256, mod256, add512, sub512, div512 - https://2π.com/17/512-bit-division/ License: MIT
     */

    /** @notice Divide 2^256 by a */
    function div256(uint256 a) internal pure returns (uint256 r) {
        require(a > 1);
        assembly {
            r := add(div(sub(0, a), a), 1)
        }
    }

    /** @notice 2^256 mod a */
    function mod256(uint256 a) internal pure returns (uint256 r) {
        require(a != 0);
        assembly {
            r := mod(sub(0, a), a)
        }
    }

    /** @notice add two-word numbers */
    function add512(uint256 a0, uint256 a1, uint256 b0, uint256 b1)
    internal pure returns (uint256 r0, uint256 r1) {
        assembly {
            r0 := add(a0, b0)
            r1 := add(add(a1, b1), lt(r0, a0))
        }
    }

    /** @notice subtract two-word numbers */
    function sub512(uint256 a0, uint256 a1, uint256 b0, uint256 b1)
    internal pure returns (uint256 r0, uint256 r1) {
        assembly {
            r0 := sub(a0, b0)
            r1 := sub(sub(a1, b1), lt(a0, b0))
        }
    }

    /** @notice divide two-word a by one-word b */
    function div512(uint256 a0, uint256 a1, uint256 b) internal pure returns (uint256 x0, uint256 x1)
    {
        uint256 q = div256(b);
        uint256 r = mod256(b);
        uint256 t0;
        uint256 t1;

        while (a1 != 0) {
            (t0, t1) = mul256x256(a1, q);
            (x0, x1) = add512(x0, x1, t0, t1);
            (t0, t1) = mul256x256(a1, r);
            (a0, a1) = add512(t0, t1, a0, 0);
        }
        (x0, x1) = add512(x0, x1, a0 / b, 0);
    }
    /* https://2π.com/17/512-bit-division/ - Code ends */

    /** @notice Multiplies (al,ah)*b */
    function mul512x256(uint256 xl, uint256 xh, uint256 y) internal pure returns(uint256 rl, uint256 rm, uint256 rh)
    {
        /*
           (xl,xh) * y

           (xl*y)_L  (xl*y)_H
                     (xh*y)_L  (xh*yl)_H
           ========== ======== ==========
           rl         rh       (discarded)
         */

        assembly {
            let mm := mulmod(xh, y, not(0))
            rm := mul(xh, y)
            rh := sub(sub(mm, rm), lt(mm, rm))
            
            mm := mulmod(xl, y, not(0))
            rl := mul(xl, y)
            let t := sub(sub(mm, rl), lt(mm, rl))

            rm := add(rm, t)
            rh := add(rh, lt(rm, t))
        }
    }

    /* normalized p381 = p381 << 131 */
    uint256 constant norm_p_381_h = 0xd0088f51cbff34d258dd3db21a5d66bb23ba5c279c2895fb39869507b587b120;
    uint256 constant norm_p_381_l = 0xf55ffff58a9ffffdcff7fffffffd555800000000000000000000000000000000;

    /** @notice multiply (xl,xh) * (yl,yh) mod (p381) */
    function mulmod_p381(uint256 xl, uint256 xh, uint256 yl, uint256 yh) internal pure returns
    (uint256 rl, uint256 rh)
    {

    unchecked {

        uint256 tl;
        uint256 tm;
        uint256 th;

        uint256 xyl;

        /* First, compute x*y

           (xl,xh) * (yl,yh)

           (xl*yl)_L (xl*yl)_H
                     (xl*yh+xh*yl)_L   (xl*yh+xh*yl)_H
                                       (xh*yh)_L        (no xh*yh_H)
           ========== ==============   ===============  ============
           tl         tm               th

           */

        assembly {
            let mm := mulmod(xl, yl, not(0))
            tl := mul(xl, yl)
            tm := sub(sub(mm, tl), lt(mm, tl))

            mm := mulmod(xl, yh, not(0))
            xyl := mul(xl, yh)
            th := sub(sub(mm, xyl), lt(mm, xyl))

            tm := add(tm, xyl)
            th := add(th, lt(tm, xyl))

            mm := mulmod(xh, yl, not(0))
            xyl := mul(xh, yl)
            th := add(th, sub(sub(mm, xyl), lt(mm, xyl)))

            tm := add(tm, xyl)
            th := add(th, lt(tm, xyl))

            th := add(th, mul(xh,yh))
        }

        /* Second, normalize x*y (shift left by 512-381=131) */
        assembly {
            xyl := shr(125,th)
            th  := or(shl(131,th), shr(125,tm))
            tm  := or(shl(131,tm), shr(125,tl))
            tl  := shl(131,tl)
        }

        /* HAC 14.20 Multiple-precision division
           Here we have n = 3, t = 1, b=2^256 */

        /* 1. q_i = 0 */
        uint256 q2;
        uint256 q1;
        uint256 q0;
        uint256 rtop;

        /* 2. while (x>= y*2^256) do { q2 += 1, x -= y*2^256;}  */
        /* This will be at most once for normalized numbers */
        if (xyl >= norm_p_381_h) {
            q2 = 1;
            (tm, th, xyl) = sub(tm, th, xyl, 0, norm_p_381_l, norm_p_381_h);
        }

        /* 3. i = 3 */

        /* 3.1 */
        if (xyl == norm_p_381_h) {
            q1 = not0;
        } else {
            /* The hardest at EVM */
            (q1, rtop /*high part discarded, should be zero*/) = div512(th, xyl, norm_p_381_h);
        }

        /* 3.2 while q*(y_t*b + y_{t-1}) > x... q-= 1, at most two times */
        (rl, rh, rtop) = mul512x256(norm_p_381_l, norm_p_381_h, q1);
        if (cmp(rl, rh, rtop, tm, th, xyl) > 0) {
            q1--;
            (rl, rh, rtop) = sub(rl, rh, rtop, norm_p_381_l, norm_p_381_h, 0); /* room for optimization */
        }
        if (cmp(rl, rh, rtop, tm, th, xyl) > 0) {
            q1--;
            (rl, rh, rtop) = sub(rl, rh, rtop, norm_p_381_l, norm_p_381_h, 0); /* room for optimization */
        }

        /* 3.3 + 3.4 */
        if (lt(tm, th, xyl, rl, rh, rtop)) {
            q1--;
            (tm, th, xyl) = sub(tm, th, xyl, rl, rh, rtop);
            (tm, th, xyl) = add(tm, th, xyl, norm_p_381_l, norm_p_381_h, 0);

        } else {
            (tm, th, xyl) = sub(tm, th, xyl, rl, rh, rtop);
        }

        /* repeat step 3 for i = 1 */
        /* 3.1 */
        if (th == norm_p_381_h) {
            q0 = not0;
        } else {
            /* The hardest at EVM */
            (q0, rtop/*high part discarded, should be zero*/) = div512(tm, th, norm_p_381_h);
        }

        /* 3.2 while q*(y_t*b + y_{t-1}) > x... q-= 1, at most two times */
        (rl, rh, rtop) = mul512x256(norm_p_381_l, norm_p_381_h, q0);
        if (cmp(rl, rh, rtop, tl, tm, th) > 0) {
            q0--;
            (rl, rh, rtop) = sub(rl, rh, rtop, norm_p_381_l, norm_p_381_h, 0); /* room for optimization */
        }
        if (cmp(rl, rh, rtop, tl, tm, th) > 0) {
            q0--;
            (rl, rh, rtop) = sub(rl, rh, rtop, norm_p_381_l, norm_p_381_h, 0); /* room for optimization */
        }

        /* 3.3 + 3.4 */
        if (lt(tl, tm, th, rl, rh, rtop)) {
            q0--;
            (tl, tm, th) = sub(tl, tm, th, rl, rh, rtop);
            (tl, tm, th) = add(tl, tm, th, norm_p_381_l, norm_p_381_h, 0);

        } else {
            (tl, tm, th) = sub(tl, tm, th, rl, rh, rtop);
        }

        /* renormalization, shr 131 */
        assembly {
            rh := shr(131, tm)
            rl := or(shl(125, tm), shr(131, tl)) 
        }

    } /* unchecked */
    }

}

