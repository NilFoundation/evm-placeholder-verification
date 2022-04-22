const TestMerkleProofVerifier = artifacts.require("TestMerkleProofVerifier");
const TestFriVerifier = artifacts.require("TestFriVerifier");
const TestLpcVerifier = artifacts.require("TestLpcVerifier");
const TestPermutationArgument = artifacts.require("TestPermutationArgument");
const TestUnifiedAdditionComponent = artifacts.require("TestUnifiedAdditionComponent");

// const PoseidonComponentSplitLib0 = artifacts.require("poseidon_gate0");
// const PoseidonComponentSplitLib1 = artifacts.require("poseidon_gate1");
// const PoseidonComponentSplitLib2 = artifacts.require("poseidon_gate2");
// const PoseidonComponentSplitLib3 = artifacts.require("poseidon_gate3");
// const PoseidonComponentSplitLib4 = artifacts.require("poseidon_gate4");
// const PoseidonComponentSplitLib5 = artifacts.require("poseidon_gate5");
// const PoseidonComponentSplitLib6 = artifacts.require("poseidon_gate6");
// const PoseidonComponentSplitLib7 = artifacts.require("poseidon_gate7");
// const PoseidonComponentSplitLib8 = artifacts.require("poseidon_gate8");
// const PoseidonComponentSplitLib9 = artifacts.require("poseidon_gate9");
// const PoseidonComponentSplitLib10 = artifacts.require("poseidon_gate10");
// const TestPoseidonComponentSplitGen = artifacts.require("TestPoseidonComponentSplitGen");

const TestPlaceholderVerifierUnifiedAddition = artifacts.require("TestPlaceholderVerifierUnifiedAddition");
// const TestPlaceholderVerifierPoseidonGen = artifacts.require("TestPlaceholderVerifierPoseidonGen");

module.exports = function (deployer) {
  deployer.deploy(TestMerkleProofVerifier);
  deployer.deploy(TestFriVerifier);
  deployer.deploy(TestLpcVerifier);
  deployer.deploy(TestPermutationArgument);
  deployer.deploy(TestUnifiedAdditionComponent);
  
  // deployer.deploy(PoseidonComponentSplitLib0);
  // deployer.deploy(PoseidonComponentSplitLib1);
  // deployer.deploy(PoseidonComponentSplitLib2);
  // deployer.deploy(PoseidonComponentSplitLib3);
  // deployer.deploy(PoseidonComponentSplitLib4);
  // deployer.deploy(PoseidonComponentSplitLib5);
  // deployer.deploy(PoseidonComponentSplitLib6);
  // deployer.deploy(PoseidonComponentSplitLib7);
  // deployer.deploy(PoseidonComponentSplitLib8);
  // deployer.deploy(PoseidonComponentSplitLib9);
  // deployer.deploy(PoseidonComponentSplitLib10);
  // deployer.link(PoseidonComponentSplitLib0, TestPoseidonComponentSplitGen);
  // deployer.link(PoseidonComponentSplitLib1, TestPoseidonComponentSplitGen);
  // deployer.link(PoseidonComponentSplitLib2, TestPoseidonComponentSplitGen);
  // deployer.link(PoseidonComponentSplitLib3, TestPoseidonComponentSplitGen);
  // deployer.link(PoseidonComponentSplitLib4, TestPoseidonComponentSplitGen);
  // deployer.link(PoseidonComponentSplitLib5, TestPoseidonComponentSplitGen);
  // deployer.link(PoseidonComponentSplitLib6, TestPoseidonComponentSplitGen);
  // deployer.link(PoseidonComponentSplitLib7, TestPoseidonComponentSplitGen);
  // deployer.link(PoseidonComponentSplitLib8, TestPoseidonComponentSplitGen);
  // deployer.link(PoseidonComponentSplitLib9, TestPoseidonComponentSplitGen);
  // deployer.link(PoseidonComponentSplitLib10, TestPoseidonComponentSplitGen);
  // deployer.deploy(TestPoseidonComponentSplitGen);
  
  deployer.deploy(TestPlaceholderVerifierUnifiedAddition);
  
  // deployer.link(PoseidonComponentSplitLib0, TestPlaceholderVerifierPoseidonGen);
  // deployer.link(PoseidonComponentSplitLib1, TestPlaceholderVerifierPoseidonGen);
  // deployer.link(PoseidonComponentSplitLib2, TestPlaceholderVerifierPoseidonGen);
  // deployer.link(PoseidonComponentSplitLib3, TestPlaceholderVerifierPoseidonGen);
  // deployer.link(PoseidonComponentSplitLib4, TestPlaceholderVerifierPoseidonGen);
  // deployer.link(PoseidonComponentSplitLib5, TestPlaceholderVerifierPoseidonGen);
  // deployer.link(PoseidonComponentSplitLib6, TestPlaceholderVerifierPoseidonGen);
  // deployer.link(PoseidonComponentSplitLib7, TestPlaceholderVerifierPoseidonGen);
  // deployer.link(PoseidonComponentSplitLib8, TestPlaceholderVerifierPoseidonGen);
  // deployer.link(PoseidonComponentSplitLib9, TestPlaceholderVerifierPoseidonGen);
  // deployer.link(PoseidonComponentSplitLib10, TestPlaceholderVerifierPoseidonGen);
  // deployer.deploy(TestPlaceholderVerifierPoseidonGen);
};
