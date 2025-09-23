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
