// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Logger {
    event Log1(bytes32 indexed data1);  // LOG1 (1 indexed topic)
    event Log4(bytes32 indexed data1, bytes32 indexed data2, bytes32 indexed data3, bytes32 data4); // LOG4 (3 indexed topics + 1 data)

    function logMultiple(bytes32 data1, bytes32 data2, bytes32 data3, bytes32 data4) external {
        emit Log1(data1);  // Triggers LOG1
        emit Log4(data1, data2, data3, data4);  // Triggers LOG4
    }
}
