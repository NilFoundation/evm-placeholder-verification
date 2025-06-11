pragma solidity >=0.8.4;

contract zkEVMMinimalMath {
    uint256 counter = 15;
    uint256 previous_result = 333;

   function test_addition(uint256 a, uint256 b) public returns (uint256 result)  {
        counter = counter + 1;
        previous_result = a + b + counter;
        return previous_result;
    }
}
