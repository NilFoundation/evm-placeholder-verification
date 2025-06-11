pragma solidity >=0.8.4;

contract zkEVMIndexedLog {
    uint256 counter = 0;
    event Result(uint256 result);
    event Indexed2(
        uint256 indexed index1,
        uint256 result
    );
    event Indexed3(
        uint256 indexed index1,
        uint256 indexed index2,
        uint256 result
    );
    event Indexed4(
        uint256 indexed index1,
        uint256 indexed index2,
        uint256 indexed index3,
        uint256 result
    );

   function inc(uint256 index1, uint256 index2, uint256 index3) external returns (uint256 result)  {
        counter = counter + 1;
        emit Result(counter);
        emit Indexed2(index1, counter);
        emit Indexed3(index1, index2, counter);
        emit Indexed4(index1, index2, index3, counter);
        return counter;
    }
}
