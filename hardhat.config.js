require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { ALCHEMY_API_KEY_URL, RINKEBY_PRIVATE_KEY, ETHERSCAN_API_KEY } =
  process.env;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    rinkeby: {
      url: ALCHEMY_API_KEY_URL,
      accounts: [RINKEBY_PRIVATE_KEY],
    },
    bsc: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      accounts: [RINKEBY_PRIVATE_KEY],
    },
    mumbai: {
      url: "",
      accounts: [RINKEBY_PRIVATE_KEY],
    },
    avax: {
      url: "https://avalanche-fuji-c-chain.publicnode.com",
      chainId: 43113,
      accounts: [RINKEBY_PRIVATE_KEY],
    },
    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts: [RINKEBY_PRIVATE_KEY],
      chainId: 44787,
    },
  },
  etherscan: {
    apiKey: {
      avalancheFujiTestnet: "",
    },
  },
};
