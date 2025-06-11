pragma solidity >=0.8.4;

interface IKeccak{
    event Result(bytes32 result);
    function hash(string memory input) external returns (bytes32 result);
}

contract zkEVMCallKeccak {
    address KeccakAddr;
    event Result(bytes32 result);

    constructor(address _addr){
        KeccakAddr = _addr;
    }

    function callHash(string memory input) public returns (bytes32 result){
        IKeccak keccak_contract = IKeccak(KeccakAddr);
        result = keccak_contract.hash(input);
        emit Result(result);
    }
}
