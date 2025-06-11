pragma solidity >=0.8.4;

contract zkEVMCounter {
    uint256 counter = 0;
    event Result(uint256 result);

   function inc() external returns (uint256 result)  {
        counter = counter + 1;
        emit Result(counter);
        return counter;
    }
}
