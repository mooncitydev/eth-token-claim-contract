const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with account:", deployer.address);
    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

    const Airdrop = await ethers.getContractFactory("Airdrop");
    const airdrop = await Airdrop.deploy(
        process.env.TOKEN_CONTRACT,           // Token address
        "0x0A5b28689FF9A846844FF141828773D170107198",               // backendwallet
        1748444400     //5/18/utc3pm
    );

    await airdrop.waitForDeployment();
    const address = await airdrop.getAddress();

    console.log("Token deployed to:", address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });