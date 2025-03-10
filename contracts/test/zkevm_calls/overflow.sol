pragma solidity >=0.8.4;

contract zkEVMOverflow{
    event Result(uint256 result);

    uint256 overflows;

    function uncheckedAddition(uint256 a, uint256 b) public returns (bool result){
        uint256 sum;
        unchecked{
            sum = a+b;
        }
        if( sum < a || sum < b) {
            overflows++;
            result = true;
        }
        emit Result(sum);
        return result;
    }
}
