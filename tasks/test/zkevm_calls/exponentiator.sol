pragma solidity >=0.8.4;

contract zkEVMExponentiator {
    uint256 key;

    constructor (uint256 k){
        key = k;
    }

    function test_exp(uint256 d) external view returns (uint256 r) {
        uint256 x = key;
        unchecked {
            assembly {
                r :=  exp(x, d)
            }
        }
    }
}
