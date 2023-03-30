pragma solidity >=0.8.4;

import "../types.sol";

interface IGateArgument {
    function evaluate_gates_be(
        bytes calldata blob,
        types.gate_argument_local_vars memory gate_params,
        uint256 eval_proof_combined_value_offset,
        types.arithmetization_params memory ar_params,
        int256[][] calldata columns_rotations
    ) external view returns (uint256 gates_evaluation);
}
