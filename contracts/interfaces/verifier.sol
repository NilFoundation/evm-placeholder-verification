pragma solidity ^0.8.0;

interface IVerifier {
    function verify(bytes calldata blob, uint256[][] calldata init_params,
        int256[][][] calldata columns_rotations) external returns (bool);
}
