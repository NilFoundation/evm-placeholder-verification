pragma solidity >=0.8.4;

interface IDynamicStorage{
    event Result(uint256 result);
    function set(uint256 key, uint256 value) external;
    function add(uint256 key, uint256 value) external;
    function get(uint256 key) external returns (uint256 result);
    function get_max() external returns (uint256 result);
}

contract zkEVMRevertCold {
    address DynamicStorageAddr;
    uint256 revert_counter = 0;

    constructor(address _dynamicStorageAddr){
        DynamicStorageAddr = _dynamicStorageAddr;
    }

    function access(uint256 key, uint256 value) external returns (uint256 result){
        IDynamicStorage dynamic_storage = IDynamicStorage(DynamicStorageAddr);
        dynamic_storage.set(key, value);
        revert_counter += 1;
        require(false, "Wrong operation");
        return revert_counter;
    }
}
