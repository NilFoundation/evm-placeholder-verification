pragma solidity >=0.8.4;

interface ICounter{
    event Result(uint256 result);
    function inc() external returns (uint256 result);
}

contract zkEVMRevert {
    address CounterAddr;
    uint256 revert_counter = 0;

    constructor(address _counterAddr){
        CounterAddr = _counterAddr;
    }

    function callInc() external returns (uint256 result){
        ICounter counter = ICounter(CounterAddr);
        result = counter.inc();
        result = counter.inc();
        revert_counter += 1;
        require(false, "Wrong operation");
        return revert_counter;
    }
}
