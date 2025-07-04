pragma solidity >=0.8.4;

interface ILargeMstoreKey{
    function mstoreKey(uint256 key) external;
    function mstore8Key(uint256 key) external;
}

contract zkEVMCallLargeMstoreKey {
    address LargeMemoryKeyAddr;

    uint256 success;
    uint256 failure;

    constructor(address _largeMemoryKeyAddr){
        LargeMemoryKeyAddr = _largeMemoryKeyAddr;
    }

    function callLargeMstoreKey() public{
        ILargeMstoreKey ct = ILargeMstoreKey(LargeMemoryKeyAddr);
        bool call_success;
        bytes memory data;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstoreKey(uint256)", 0xF)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstoreKey(uint256)", 0x0000000000000000000000000000000000000000000000000000000001FFFFE0)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstoreKey(uint256)", 0x0000000000000000000000000000000000000000000000000000000001FFFFE1)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstoreKey(uint256)", 0x0000000000000000000000000000000000000000000000000000000001fffffe)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstoreKey(uint256)", 0x0000000000000000000000000000000000000000000000000000000001ffffff)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstoreKey(uint256)", 0x0000000000000000000000000000000000000000000000000000000002000000)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstoreKey(uint256)", 0xFF00000000000000000000000000000000000000000000000000000000000000)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstoreKey(uint256)", 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        );
        if(call_success) success++; else  failure++;
    }

    function callLargeMstore8Key() public{
        ILargeMstoreKey ct = ILargeMstoreKey(LargeMemoryKeyAddr);
        bool call_success;
        bytes memory data;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstoreKey(uint256)", 0xF)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstore8Key(uint256)", 0x0000000000000000000000000000000000000000000000000000000001FFFFE0)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstore8Key(uint256)", 0x0000000000000000000000000000000000000000000000000000000001FFFFE1)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstore8Key(uint256)", 0x0000000000000000000000000000000000000000000000000000000001fffffe)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstore8Key(uint256)", 0x0000000000000000000000000000000000000000000000000000000001ffffff)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstore8Key(uint256)", 0x0000000000000000000000000000000000000000000000000000000002000000)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstore8Key(uint256)", 0xFF00000000000000000000000000000000000000000000000000000000000000)
        );
        if(call_success) success++; else  failure++;

        (call_success, data) = LargeMemoryKeyAddr.call{gas:1000000}(
            abi.encodeWithSignature("mstore8Key(uint256)", 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        );
        if(call_success) success++; else  failure++;
    }
}
