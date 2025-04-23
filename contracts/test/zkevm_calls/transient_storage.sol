// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TransientStorageDemo {
    uint256 public permanentCounter;
    
    uint256 constant TRANSIENT_COUNTER_SLOT = 1;

    error TransientCounterOverflow(uint256 maxAllowed, uint256 currentValue);

    function incrementCounters() external {
        permanentCounter += 1;

        uint256 transientCounter;
        assembly {
            transientCounter := tload(TRANSIENT_COUNTER_SLOT)
            transientCounter := add(transientCounter, 1)
            tstore(TRANSIENT_COUNTER_SLOT, transientCounter)
        }

        if (transientCounter > 5) {
            revert TransientCounterOverflow(5, transientCounter);
        }
    }
}

interface ITransientStorageDemo {
    function incrementCounters() external;
}

contract TransientStorageTester {
    ITransientStorageDemo public target;

    constructor(address _target) {
        target = ITransientStorageDemo(_target);
    }

    function testOverflow(uint256 times) external {
        for (uint256 i = 0; i < times; i++) {
            try target.incrementCounters(){ }
            catch {}
        }
    }
}

