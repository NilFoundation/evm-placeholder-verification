pragma solidity >=0.8.4;

interface IExponentiator{
    function test_exp(uint256 d) external view returns (uint256 r);
}

contract zkEVMStaticCall {
    event Result(uint256 result);

    address ExpAddr;
    uint256 a;


    constructor(address _expAddr){
        ExpAddr = _expAddr;
    }

    function static_call(uint256 n) public returns (uint256 result){
        (bool success, bytes memory data) = ExpAddr.staticcall(
            abi.encodeWithSignature("test_exp(uint256)", n)
        );
        a = a + 1;
        return result;
    }
}
