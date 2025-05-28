const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with account:", deployer.address);
    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

    const Contract = await ethers.getContractFactory("Claim");
    const contract = await Contract.deploy(
        process.env.TOKEN_CONTRACT,           // Token address
        "0x0A5b28689FF9A846844FF141828773D170107198",               // backendwallet
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