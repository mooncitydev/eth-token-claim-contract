const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VestingTokenClaim - Signature Verification", function () {
    let contract, backendWallet, signer, token;
    const totalAmount = ethers.parseUnits("1000", 18); // 1000 tokens
    const nonce = 1;
    const deadline = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now

    beforeEach(async () => {
        [signer, backendWallet] = await ethers.getSigners();
        console.log("🚀 ~ beforeEach ~ backendWallet:", backendWallet)
        console.log("🚀 ~ beforeEach ~ signer:", signer)

        // Deploy dummy token
        // const Token = await ethers.getContractFactory("ERC20");
        // token = await Token.deploy("TestToken", "TT");
        // await token.waitForDeployment();

        // Deploy vesting contract
        const Vesting = await ethers.getContractFactory("VestingTokenClaim");
        const vestingStartTime = Math.floor(Date.now() / 1000) + 60; // in 1 minute
        contract = await Vesting.deploy(
            "0xD402f420e7Cd39b6D66345CC4f3C2cf86D3d2BF2",
            backendWallet.address,
            vestingStartTime
        );
        await contract.waitForDeployment();
        console.log(await contract.getAddress());
    });

    it("should verify a valid signature", async () => {
        // Create message hash
        const packedData = ethers.solidityPacked(
            ["address", "uint256", "uint256", "uint256"],
            [signer.address, totalAmount, nonce, deadline]
        );
        console.log("🚀 ~ it ~ packedData:", packedData)
        const messageHash = ethers.keccak256(packedData);
        console.log("🚀 ~ it ~ messageHash:", messageHash)

        // Sign messageHash with backend wallet (which was set as backendWallet)
        const signature = await backendWallet.signMessage(
            ethers.getBytes(messageHash)
        );
        console.log("🚀 ~ it ~ signature:", signature)

        // Call verifySignature on contract
        const result = await contract.callStatic.verifySignature(
            signer.address,
            totalAmount,
            nonce,
            deadline,
            signature
        );


        expect(result).to.equal(true);
    });
});
