pragma solidity >=0.8.4;

contract zkEVMPrecompiles {
    uint256 constant modulus = 4294967291;
    uint256 s;

    function test_expmod(uint256 x,uint256[] calldata degrees) public  {
        uint256 r;

        for( uint8 i = 0; i < degrees.length; i++){
            uint256 d = degrees[i];
            assembly{
                let p := mload(0x40)
                mstore(p, 0x20) // Length of Base.
                mstore(add(p, 0x20), 0x20) // Length of Exponent.
                mstore(add(p, 0x40), 0x20) // Length of Modulus.
                mstore(add(p, 0x60), x) // Base.
                mstore(add(p, 0x80), sub(modulus, 0x02)) // Exponent.
                mstore(add(p, 0xa0), modulus) // Modulus.
                // Call modexp precompile.
                if iszero(staticcall(gas(), 0x05, p, 0xc0, p, 0x20)) {
                    revert(0, 0)
                }
                r := mload(p)
            }
            s = addmod(s, r, modulus);
        }
    }
}
