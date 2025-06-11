pragma solidity >=0.8.4;

interface IRevertCold{
    function access(uint256 key, uint256 value) external returns (uint256 result);
}

interface IDynamicStorage{
    event Result(uint256 result);
    function set(uint256 key, uint256 value) external;
    function add(uint256 key, uint256 value) external;
    function get(uint256 key) external returns (uint256 result);
    function get_max() external returns (uint256 result);
}

contract zkEVMTryCatchCold {
    address RevertAddr;
    address DynamicStorageAddr;

    event Success(string log);
    event Reverted(string log);

    constructor(address _dynamicStorageAddr, address _revertAddr){
        RevertAddr = _revertAddr;
        DynamicStorageAddr = _dynamicStorageAddr;
    }

    function access(uint256 key, uint256 value) public returns (uint256 result){
        IRevertCold r = IRevertCold(RevertAddr);
        IDynamicStorage dynamic_storage = IDynamicStorage(DynamicStorageAddr);

        try r.access(key, value) {
            emit Success("Success");
        } catch Panic(uint256 errorCode) {
            // handle illegal operation and `assert` errors
            emit Success("Panic occurred with some error code");
        } catch Error(string memory reason) {
            // handle revert with a reason
            emit Reverted(reason);
        }
        dynamic_storage.set(key, value+1);
        return result;
    }
}
