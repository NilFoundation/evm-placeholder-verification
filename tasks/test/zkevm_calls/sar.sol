pragma solidity ^0.8.0;

contract SarTest {
    int256 public lastResult; // Store the result to make it state-changing
    function testSar(int256 a, uint256 shift) public returns (int256) {
        lastResult = a >> shift; // This writes to storage, triggering a transaction
        return lastResult;
    }
}