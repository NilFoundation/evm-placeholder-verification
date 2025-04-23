// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestSCMP {

    // Function to test SCMP with two signed integers
    function compareSigned(int256 a, int256 b) public returns (bool) {
        // Perform a signed greater-than comparison
        bool test1 = a < b;
        bool test2 = -a < b;
        bool test3 = a < -b;
        bool test4 = -a < -b;

        bool test5 = a > b;
        bool test6 = -a > b;
        bool test7 = a > -b;
        bool test8 = -a > -b;

        return test1;
    }
}