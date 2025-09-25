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
            await expect(
                Claim.deploy(await token.getAddress(), ethers.ZeroAddress)
            ).to.be.revertedWith("Invalid backend wallet address");
        });
    });

    describe("Token Claiming", function () {
        it("Should allow user to claim tokens with valid signature", async function () {
            const { claim, token, backendWallet, user } = await loadFixture(deployClaimFixture);
            
            const amount = ethers.parseUnits("100", 18);
            const nonce = 1;
            const deadline = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now

            // Create message hash (same as contract)
            const packedData = ethers.solidityPacked(
                ["address", "uint256", "uint256", "uint256"],
                [user.address, amount, nonce, deadline]
            );
            const messageHash = ethers.keccak256(packedData);

            // Sign message with backend wallet
            const signature = await backendWallet.signMessage(ethers.getBytes(messageHash));

            // Get initial balances
            const initialUserBalance = await token.balanceOf(user.address);
            const initialContractBalance = await token.balanceOf(await claim.getAddress());

            // Claim tokens
            await expect(claim.connect(user).claimTokens(amount, nonce, deadline, signature))
                .to.emit(claim, "TokensClaimed")
                .withArgs(user.address, amount, messageHash);

            // Verify balances
            expect(await token.balanceOf(user.address)).to.equal(initialUserBalance + amount);
            expect(await token.balanceOf(await claim.getAddress())).to.equal(initialContractBalance - amount);
        });

        it("Should prevent reuse of the same signature", async function () {
            const { claim, backendWallet, user } = await loadFixture(deployClaimFixture);
            
            const amount = ethers.parseUnits("100", 18);
            const nonce = 2;
            const deadline = Math.floor(Date.now() / 1000) + 3600;

            const packedData = ethers.solidityPacked(
                ["address", "uint256", "uint256", "uint256"],
                [user.address, amount, nonce, deadline]
            );
            const messageHash = ethers.keccak256(packedData);
            const signature = await backendWallet.signMessage(ethers.getBytes(messageHash));

            // First claim should succeed
            await claim.connect(user).claimTokens(amount, nonce, deadline, signature);

            // Second claim with same signature should fail
            await expect(
                claim.connect(user).claimTokens(amount, nonce, deadline, signature)
            ).to.be.revertedWith("Signature already used");
        });

        it("Should revert if signature is expired", async function () {
            const { claim, backendWallet, user } = await loadFixture(deployClaimFixture);
            
            const amount = ethers.parseUnits("100", 18);
            const nonce = 3;
            const deadline = Math.floor(Date.now() / 1000) - 100; // Already expired

            const packedData = ethers.solidityPacked(
                ["address", "uint256", "uint256", "uint256"],
                [user.address, amount, nonce, deadline]
            );
            const messageHash = ethers.keccak256(packedData);
            const signature = await backendWallet.signMessage(ethers.getBytes(messageHash));

            await expect(
                claim.connect(user).claimTokens(amount, nonce, deadline, signature)
            ).to.be.revertedWith("Signature expired");
        });

        it("Should revert if amount is zero", async function () {
            const { claim, backendWallet, user } = await loadFixture(deployClaimFixture);
            
            const amount = 0;
            const nonce = 4;
            const deadline = Math.floor(Date.now() / 1000) + 3600;

            const packedData = ethers.solidityPacked(
                ["address", "uint256", "uint256", "uint256"],
                [user.address, amount, nonce, deadline]
            );
            const messageHash = ethers.keccak256(packedData);
            const signature = await backendWallet.signMessage(ethers.getBytes(messageHash));

            await expect(
                claim.connect(user).claimTokens(amount, nonce, deadline, signature)
            ).to.be.revertedWith("Amount must be greater than 0");
        });

        it("Should revert if signature is invalid", async function () {
            const { claim, user, otherUser } = await loadFixture(deployClaimFixture);
            
            const amount = ethers.parseUnits("100", 18);
            const nonce = 5;
            const deadline = Math.floor(Date.now() / 1000) + 3600;
