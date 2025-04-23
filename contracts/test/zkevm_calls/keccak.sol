pragma solidity >=0.8.4;

contract zkEVMKeccak {
    bytes32 private h;
    event Result(bytes32 result);

    function hash(string memory input) external returns (bytes32 result)  {
        h = keccak256(bytes(input));
        result = h;
        emit Result(h);
    }
}
