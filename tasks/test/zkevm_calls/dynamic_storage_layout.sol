pragma solidity >=0.8.4;

contract zkEVMDynamicStorageLayout {
    event Result(uint256 result);
    uint256 max;

    function set(uint256 key, uint256 value) external{
        if( key > max ) max = key;
        assembly{
            sstore(key, value)
        }
    }
    function add(uint256 key, uint256 value) external{
        if( key > max ) max = key;
        uint256 value_before;
        assembly{
            value_before := sload(key)
        }
        value = value + value_before;
        assembly{
            sstore(key, value)
        }
    }
    function get(uint256 key) external returns (uint256 result){
        assembly{
            result := sload(key)
        }
        emit Result(result);
    }
    function get_max() external returns (uint256 result){
        emit Result(max);
        result =  max;
    }
}
