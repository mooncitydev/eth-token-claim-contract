const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with account:", deployer.address);
    
    const balance = await ethers.provider.getBalance(deployer.address);
    console.log("Account balance:", ethers.formatEther(balance), "ETH");

    // Validate environment variables
    if (!process.env.TOKEN_CONTRACT) {
        throw new Error("TOKEN_CONTRACT environment variable is not set");
    }
    if (!process.env.BACKEND_WALLET) {
        throw new Error("BACKEND_WALLET environment variable is not set");
    }

    const tokenAddress = process.env.TOKEN_CONTRACT;
    const backendWallet = process.env.BACKEND_WALLET;

    // Validate addresses
    if (!ethers.isAddress(tokenAddress)) {
        throw new Error("Invalid TOKEN_CONTRACT address");
    }
    if (!ethers.isAddress(backendWallet)) {
        throw new Error("Invalid BACKEND_WALLET address");
    }

    console.log("\nDeployment parameters:");
    console.log("  Token Address:", tokenAddress);
    console.log("  Backend Wallet:", backendWallet);

    // Deploy contract
    console.log("\nDeploying Claim contract...");
    const Claim = await ethers.getContractFactory("Claim");
    const claim = await Claim.deploy(tokenAddress, backendWallet);

    await claim.waitForDeployment();
    const contractAddress = await claim.getAddress();

    console.log("\n✅ Claim contract deployed successfully!");
    console.log("  Contract Address:", contractAddress);
    console.log("\nTo verify the contract, run:");
    console.log(`  npx hardhat verify --network <network> ${contractAddress} ${tokenAddress} ${backendWallet}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("\n❌ Deployment failed:");
        console.error(error);
        process.exit(1);
    });
