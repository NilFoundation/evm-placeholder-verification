pragma solidity >=0.8.4;

import "../contracts/types.sol";
import "../contracts/basic_marshalling.sol";
import "../contracts/commitments/batched_lpc_verifier.sol";

interface IGateArgument {
    function evaluate_gates_be(bytes calldata blob,
        types.gate_argument_local_vars memory gate_params,
        types.arithmetization_params memory ar_params,
        int256[][] memory columns_rotations
    ) external view returns (uint256 gates_evaluation);
}
