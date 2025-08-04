const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with account:", deployer.address);
    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

    const Contract = await ethers.getContractFactory("Claim");
    const contract = await Contract.deploy(
        process.env.TOKEN_CONTRACT,           // Token address
        "0x025478cBF253aa7f6e9464cFbb6Ce436419115C2",               // backendwallet
    );

    await contract.waitForDeployment();
    const address = await contract.getAddress();

    console.log("claim contract deployed to:", address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
