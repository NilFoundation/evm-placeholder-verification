// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MinimalCodeCopy {
    uint256 n;

    function copyCode() external returns (bytes memory) {
        bytes memory code = new bytes(32); // Allocate 32 bytes
        assembly {
            codecopy(add(code, 32), 0, 32) // Copy first 32 bytes of contract code
        }
        n = n+1;
        return code;
    }

    function zeroLength() external {
        assembly {
            codecopy(0xFFFF0000, 0, 0)
            codecopy(0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000, 0, 0)
            codecopy(0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000, 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000, 0)
        }
        n = n+1;
    }
}
