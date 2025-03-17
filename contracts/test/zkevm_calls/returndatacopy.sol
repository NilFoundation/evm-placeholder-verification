// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ReturnDataCopy {
    event DataCopied(bytes copiedData);

    function copyReturnData(address targetContract, bytes memory callData) public returns (bytes memory) {
        bytes memory copied;

        // Make an external call and store the return data in the memory
        (bool success, bytes memory returnData) = targetContract.call(callData);

        if (success) {
            // Prepare the memory for the copied return data
            copied = new bytes(returnData.length);

            assembly {
                // Set up the memory locations for returndatacopy
                let dest := add(copied, 0x20) // Skip the length field (0x20 bytes)
                let len := mload(returnData)  // Length of the return data

                // Copy the return data to memory
                returndatacopy(dest, 0, len)
            }

            emit DataCopied(copied);
        }

        return copied;
    }
}
