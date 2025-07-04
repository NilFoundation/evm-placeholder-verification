pragma solidity >=0.8.4;

contract zkEVMLargeMstoreKey {
    uint256 counter;
    function mstoreKey(uint256 key) external {
        assembly{
            mstore(key, 0xAABB)
        }
        counter++;
    }

    function mstore8Key(uint256 key) external {
        assembly{
            mstore8(key, 0xDE)
        }
        counter++;
    }
}
