const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Claim Contract", function () {
    // Deploy fixture for test setup
    async function deployClaimFixture() {
        const [owner, backendWallet, user, otherUser] = await ethers.getSigners();

        // Deploy mock ERC20 token
        const MockERC20 = await ethers.getContractFactory("MockERC20");
        const token = await MockERC20.deploy("Test Token", "TEST", ethers.parseUnits("1000000", 18));
        await token.waitForDeployment();

        // Deploy Claim contract
        const Claim = await ethers.getContractFactory("Claim");
        const claim = await Claim.deploy(await token.getAddress(), backendWallet.address);
        await claim.waitForDeployment();

        // Fund the claim contract with tokens
        const contractBalance = ethers.parseUnits("100000", 18);
        await token.transfer(await claim.getAddress(), contractBalance);

        return { claim, token, owner, backendWallet, user, otherUser };
    }

    describe("Deployment", function () {
        it("Should set the correct token address", async function () {
            const { claim, token } = await loadFixture(deployClaimFixture);
            expect(await claim.token()).to.equal(await token.getAddress());
        });

        it("Should set the correct backend wallet", async function () {
            const { claim, backendWallet } = await loadFixture(deployClaimFixture);
            expect(await claim.backendWallet()).to.equal(backendWallet.address);
        });

        it("Should set the deployer as owner", async function () {
            const { claim, owner } = await loadFixture(deployClaimFixture);
            expect(await claim.owner()).to.equal(owner.address);
        });

        it("Should revert if token address is zero", async function () {
            const { backendWallet } = await loadFixture(deployClaimFixture);
            const Claim = await ethers.getContractFactory("Claim");
            await expect(
                Claim.deploy(ethers.ZeroAddress, backendWallet.address)
            ).to.be.revertedWith("Invalid token address");
        });

        it("Should revert if backend wallet is zero", async function () {
            const { token } = await loadFixture(deployClaimFixture);
            const Claim = await ethers.getContractFactory("Claim");
