pragma solidity ^0.8.0;

interface IPlaceholderVerifier {
    function verify(bytes calldata blob, uint256[][] calldata init_params,
        int256[][][] calldata columns_rotations, address gate_argument) external returns (bool);
}
