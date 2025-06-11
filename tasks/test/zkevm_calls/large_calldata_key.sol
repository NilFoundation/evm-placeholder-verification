pragma solidity >=0.8.4;

contract zkEVMLargeCalldataKey {
    uint256 data;

    function callDataKey(uint256 key, bytes calldata input) public {
        uint256 d;
        assembly{
            d:= calldataload(key)
        }
        data = d;
    }
}
