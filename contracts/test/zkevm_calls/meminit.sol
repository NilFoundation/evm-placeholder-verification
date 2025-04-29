pragma solidity >=0.8.4;

contract zkEVMMemInit {
    uint256 size;

    function test_memory(uint256 offset1, uint256 offset2, uint256 value) public returns (uint256 result)  {
        uint256 memory_size;
        assembly{
            mstore8(offset1, value)
            memory_size := msize()
            result := mload(offset2)
        }
        size = memory_size;
    }
}
