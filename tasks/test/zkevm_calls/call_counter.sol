pragma solidity >=0.8.4;

interface ICounter{
    event Result(uint256 result);
    function inc() external returns (uint256 result);
}

contract zkEVMCallCounter {
    address CounterAddr;

    constructor(address _counterAddr){
        CounterAddr = _counterAddr;
    }

    function callInc() public returns (uint256 result){
        ICounter counter = ICounter(CounterAddr);
        result = counter.inc();
        result = counter.inc();
        return result;
    }
}
