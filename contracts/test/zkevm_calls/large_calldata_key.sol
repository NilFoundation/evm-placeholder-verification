pragma solidity >=0.8.4;

contract zkEVMLargeCalldataKey {
    uint256 data;

    function callDataKey(bytes calldata input) public {
        uint256 d1;
        uint256 d2;
        uint256 d3;
        uint256 d4;
        uint256 d5;
        uint256 d6;
        uint256 d7;
        assembly{
            d1:= calldataload(0xF)
            d2:= calldataload(0x0000000000000000000000000000000000000000000000000000000001FFFFE0)
            d2:= calldataload(0x0000000000000000000000000000000000000000000000000000000001FFFFE1)
            d3:= calldataload(0x0000000000000000000000000000000000000000000000000000000001fffffe)
            d4:= calldataload(0x0000000000000000000000000000000000000000000000000000000001ffffff)
            d5:= calldataload(0x0000000000000000000000000000000000000000000000000000000002000000)
            d6:= calldataload(0xFF00000000000000000000000000000000000000000000000000000000000000)
            d7:= calldataload(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        }
        data = d1 + d2 + d3 + d4 + d5 + d6 + d7;
    }
}
