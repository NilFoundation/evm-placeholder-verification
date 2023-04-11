pragma solidity >=0.8.4;

import "../types.sol";

interface IGateArgument {
    function evaluate_gates_be(bytes calldata blob,
        uint256 eval_proof_combined_value_offset,
        types.gate_argument_params memory gate_params,
        types.arithmetization_params memory ar_params,
        int256[][] calldata columns_rotations
    ) external pure returns (uint256 gates_evaluation);
}