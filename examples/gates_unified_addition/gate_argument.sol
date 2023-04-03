pragma solidity >=0.8.4;

import "../contracts/types.sol";
import "../contracts/basic_marshalling.sol";
import "../contracts/commitments/batched_lpc_verifier.sol";
import "../contracts/logging.sol";

contract gate_argument_split_gen {
    uint256 constant WITNESSES_N = 11;
    uint256 constant GATES_N = 1;

    uint256 constant MODULUS_OFFSET = 0x0;
    uint256 constant THETA_OFFSET = 0x20;
    uint256 constant CONSTRAINT_EVAL_OFFSET = 0x40;
    uint256 constant GATE_EVAL_OFFSET = 0x60;
    uint256 constant WITNESS_EVALUATIONS_OFFSET = 0x80;
    uint256 constant SELECTOR_EVALUATIONS_OFFSET = 0xa0;
    uint256 constant EVAL_PROOF_WITNESS_OFFSET_OFFSET = 0xc0;
    uint256 constant EVAL_PROOF_SELECTOR_OFFSET_OFFSET = 0xe0;
    uint256 constant GATES_EVALUATION_OFFSET = 0x100;
    uint256 constant THETA_ACC_OFFSET = 0x120;
    uint256 constant SELECTOR_EVALUATIONS_OFFSET_OFFSET = 0x140;
    uint256 constant OFFSET_OFFSET = 0x160;

    // TODO: columns_rotations could be hard-coded
    function evaluate_gates_be(
        bytes calldata blob,
        types.gate_argument_local_vars memory gate_params,
        types.arithmetization_params memory ar_params,
        int256[][] memory columns_rotations
    ) external pure returns (uint256 gates_evaluation) {
        // TODO: check witnesses number in proof

        gate_params.offset = basic_marshalling.skip_length(
            batched_lpc_verifier.skip_to_z(
                blob,
                gate_params.eval_proof_witness_offset
            )
        );
        gate_params.witness_evaluations_offsets = new uint256[](WITNESSES_N);
        for (uint256 i = 0; i < WITNESSES_N; i++) {
            gate_params.witness_evaluations_offsets[i] = basic_marshalling
                .get_i_uint256_ptr_from_vector(blob, gate_params.offset, 0);
            gate_params.offset = basic_marshalling.skip_vector_of_uint256_be(
                blob,
                gate_params.offset
            );
        }
        gate_params.selector_evaluations = new uint256[](GATES_N);
        for (uint256 i = 0; i < GATES_N; i++) {
            gate_params.selector_evaluations[i] = batched_lpc_verifier
                .get_z_i_j_from_proof_be(
                    blob,
                    gate_params.eval_proof_selector_offset,
                    i + ar_params.permutation_columns + ar_params.permutation_columns + ar_params.constant_columns,
                    0
                );
        }

        uint256 t = 0;
        assembly {
            let modulus := mload(gate_params)
            let theta_acc := 1
            mstore(add(gate_params, GATE_EVAL_OFFSET), 0)

            function get_eval_i_by_rotation_idx(idx, rot_idx, ptr) -> result {
                result := calldataload(
                    add(
                        mload(add(add(ptr, 0x20), mul(0x20, idx))),
                        mul(0x20, rot_idx)
                    )
                )
            }

            function get_selector_i(idx, ptr) -> result {
                result := mload(add(add(ptr, 0x20), mul(0x20, idx)))
            }
            let x1 := add(gate_params, CONSTRAINT_EVAL_OFFSET)
            let x2 := add(gate_params, WITNESS_EVALUATIONS_OFFSET)
            let x3 := get_eval_i_by_rotation_idx(0,0,mload(x2))
            let x4 := get_eval_i_by_rotation_idx(2,0,mload(x2))
            mstore(add(gate_params, GATE_EVAL_OFFSET), 0)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x3,get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,get_eval_i_by_rotation_idx(1,0,mload(x2)),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,get_eval_i_by_rotation_idx(3,0,mload(x2)),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x4,mulmod(x3,get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x4,mulmod(x4,get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x4,get_eval_i_by_rotation_idx(1,0,mload(x2)),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x4,get_eval_i_by_rotation_idx(3,0,mload(x2)),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),mulmod(0x2,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffe,mulmod(x3,x3,modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x2,mulmod(x3,mulmod(get_eval_i_by_rotation_idx(8,0,mload(x2)),mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ecfffffffe,mulmod(x3,mulmod(get_eval_i_by_rotation_idx(8,0,mload(x2)),mulmod(x3,x3,modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ecffffffff,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(8,0,mload(x2)),mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(8,0,mload(x2)),mulmod(x3,x3,modulus),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(10,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(x4,x3,modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(x4,x4,modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(x4,get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(x3,mulmod(get_eval_i_by_rotation_idx(10,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(x3,x3,modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(x3,x4,modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(x3,get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(4,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(x4,mulmod(x3,get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(x4,get_eval_i_by_rotation_idx(1,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(x4,get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(x3,mulmod(get_eval_i_by_rotation_idx(4,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(x3,mulmod(x3,get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(x3,get_eval_i_by_rotation_idx(1,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(x3,get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(3,0,mload(x2)),mulmod(get_eval_i_by_rotation_idx(10,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(3,0,mload(x2)),x3,modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(3,0,mload(x2)),x4,modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(3,0,mload(x2)),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),mulmod(get_eval_i_by_rotation_idx(10,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),x3,modulus),modulus),modulus),modulus),modulus))

            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),x4,modulus),modulus),modulus),modulus),modulus))
            // Last working string
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(3,0,mload(x2)),mulmod(get_eval_i_by_rotation_idx(4,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(3,0,mload(x2)),mulmod(x3,get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(3,0,mload(x2)),get_eval_i_by_rotation_idx(1,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(3,0,mload(x2)),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),mulmod(get_eval_i_by_rotation_idx(4,0,mload(x2)),get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),mulmod(x3,get_eval_i_by_rotation_idx(10,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),get_eval_i_by_rotation_idx(1,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,x4,modulus),modulus))
            mstore(x1,addmod(mload(x1),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(get_eval_i_by_rotation_idx(6,0,mload(x2)),x4,modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(get_eval_i_by_rotation_idx(6,0,mload(x2)),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,get_eval_i_by_rotation_idx(3,0,mload(x2)),modulus),modulus))
            mstore(x1,addmod(mload(x1),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(get_eval_i_by_rotation_idx(6,0,mload(x2)),get_eval_i_by_rotation_idx(3,0,mload(x2)),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x3,mulmod(get_eval_i_by_rotation_idx(6,0,mload(x2)),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,x3,modulus),modulus))
            mstore(x1,addmod(mload(x1),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x4,mulmod(get_eval_i_by_rotation_idx(7,0,mload(x2)),x3,modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(7,0,mload(x2)),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,get_eval_i_by_rotation_idx(1,0,mload(x2)),modulus),modulus))
            mstore(x1,addmod(mload(x1),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x4,mulmod(get_eval_i_by_rotation_idx(7,0,mload(x2)),get_eval_i_by_rotation_idx(1,0,mload(x2)),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(7,0,mload(x2)),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            mstore(x1,addmod(mload(x1),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(get_eval_i_by_rotation_idx(8,0,mload(x2)),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(8,0,mload(x2)),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),mulmod(get_eval_i_by_rotation_idx(9,0,mload(x2)),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(get_eval_i_by_rotation_idx(3,0,mload(x2)),mulmod(get_eval_i_by_rotation_idx(9,0,mload(x2)),get_eval_i_by_rotation_idx(4,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(x1, 0)
            //1st
            mstore(x1,addmod(mload(x1),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus))
            mstore(x1,addmod(mload(x1),mulmod(x3,mulmod(get_eval_i_by_rotation_idx(8,0,mload(x2)),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(x4,mulmod(get_eval_i_by_rotation_idx(8,0,mload(x2)),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(get_eval_i_by_rotation_idx(1,0,mload(x2)),mulmod(get_eval_i_by_rotation_idx(9,0,mload(x2)),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(x1,addmod(mload(x1),mulmod(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000000,mulmod(get_eval_i_by_rotation_idx(3,0,mload(x2)),mulmod(get_eval_i_by_rotation_idx(9,0,mload(x2)),get_eval_i_by_rotation_idx(5,0,mload(x2)),modulus),modulus),modulus),modulus))
            mstore(add(gate_params, GATE_EVAL_OFFSET),addmod(mload(add(gate_params, GATE_EVAL_OFFSET)),mulmod(mload(x1),theta_acc,modulus),modulus))
            theta_acc := mulmod(theta_acc,mload(add(gate_params, THETA_OFFSET)),modulus)
            mstore(add(gate_params, GATE_EVAL_OFFSET),mulmod(mload(add(gate_params, GATE_EVAL_OFFSET)),get_selector_i(0,mload(add(gate_params, SELECTOR_EVALUATIONS_OFFSET))),modulus))

            gates_evaluation := mload(add(gate_params, GATE_EVAL_OFFSET))
        }
    }
}
