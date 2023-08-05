// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  /*
  A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
  so whitelistContract here is a factory for instances of our Whitelist contract.
  */

  const deployedContract = await hre.ethers.deployContract("Receive", [
    "0xC249632c2D40b9001FE907806902f63038B737Ab",
    "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
  ]);

  // Wait for it to finish deploying
  await deployedContract.waitForDeployment();

  // print the address of the deployed contract
  console.log("Contract Address:", deployedContract.target);

  console.log("Sleeping.....");
  // Wait for etherscan to notice that the contract has been deployed
  await sleep(30000);

  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: deployedContract.target,
    constructorArguments: [
      "0xC249632c2D40b9001FE907806902f63038B737Ab",
      "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6",
    ],
    contract: "contracts/Receive.sol:Receive",
  });

  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
