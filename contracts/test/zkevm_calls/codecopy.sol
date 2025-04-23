// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MinimalCodeCopy {
    function copyCode() external pure returns (bytes memory) {
        bytes memory code = new bytes(32); // Allocate 32 bytes
        assembly {
            codecopy(add(code, 32), 0, 32) // Copy first 32 bytes of contract code
        }
        return code;
    }
}
