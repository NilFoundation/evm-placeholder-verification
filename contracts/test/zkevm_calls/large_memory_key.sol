pragma solidity >=0.8.4;

contract zkEVMLargeMemoryKey {
    uint256 counter;
    function memoryKey(uint256 key) external returns (uint256 data) {
        bytes memory m = hex"112233445566778899FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
        uint256 d1;
        assembly{
            d1:= mload(key)
        }
        counter++;
        return d1;
    }
}
