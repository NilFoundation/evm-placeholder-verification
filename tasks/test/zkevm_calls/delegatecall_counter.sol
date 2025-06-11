pragma solidity >=0.8.4;

interface ICounter{
    event Result(uint256 result);
    function inc() external returns (uint256 result);
}

contract zkEVMDelegateCall {
    event Result(uint256 result);

    uint256 a;
    address CounterAddr;


    constructor(address _counterAddr){
        a = 16;
        CounterAddr = _counterAddr;
    }

    function call_and_delegate_call() public returns (uint256 result){
        ICounter counter = ICounter(CounterAddr);
        uint256 num;

        result = counter.inc();
        (bool success, bytes memory data) = CounterAddr.delegatecall(
            abi.encodeWithSignature("inc()", num)
        );
        emit Result(a);
        return result;
    }
}
