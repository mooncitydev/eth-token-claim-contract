const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SignatureVerifier", function () {
  it("should emit log events", async function () {
    const [owner] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("VestingTokenClaim");
    const contract = await Contract.deploy();
    await contract.waitForDeployment();

    const tx = await contract.testLog(owner.address, 123);
    const receipt = await tx.wait();

    // 🔍 Print logs
    for (const event of receipt.logs) {
      try {
        const parsed = contract.interface.parseLog(event);
        console.log(`📢 ${parsed.name}:`, parsed.args);
      } catch (e) {
        // Skip non-matching logs (like internal transactions)
      }
    }
  });
});
