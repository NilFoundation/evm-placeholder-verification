pragma solidity >=0.8.4;

contract zkEVMModular {
    uint256 a = 0x1234567890;
    uint256 m = 0x1234878991;
    uint256 x = 0x1235789091;

   function test_modular(uint256 input) public returns (uint256 result)  {
        uint256 modulus = 0x1b70726fb8d3a24da9ff9647225a18412b8f010425938504d73ebc8801e2e016;

        a = addmod(a, input, modulus);
        m = mulmod(a, input, modulus);
        x = x ^ input;

        return a + m + x;
    }
}