pragma solidity >=0.8.4;

contract zkEVMExp {
    uint256 s;

    function test_exp(uint256 x,uint256[] calldata degrees) public  {
        uint256 r;
        unchecked {
            for( uint8 i = 0; i < degrees.length; i++){
                uint256 d = degrees[i];
                assembly {
                    r :=  exp(x, d)
                }
                s += r;
            }
        }
    }
}
