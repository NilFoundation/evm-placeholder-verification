pragma solidity >=0.8.4;

interface ICounter{
    event Result(uint256 result);
    function inc() external returns (uint256 result);
}
interface IRevert{
    function callInc() external returns (uint256 result);
}

contract zkEVMTryCatch {
    address CounterAddr;
    address RevertAddr;

    event Success(string log);
    event Reverted(string log);

    constructor(address _counterAddr, address _revertAddr){
        CounterAddr = _counterAddr;
        RevertAddr = _revertAddr;
    }

    function callInc() public returns (uint256 result){
        ICounter counter = ICounter(CounterAddr);
        result = counter.inc();
        IRevert r = IRevert(RevertAddr);
        try r.callInc() {
            emit Success("Success");
        } catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            emit Success("Panic occurred with some error code");
        } catch Error(string memory reason) {
            // handle revert with a reason
            emit Reverted(reason);
        }
        result = counter.inc();
        return result;
    }
}
