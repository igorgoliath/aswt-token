require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
const private_key = require("./keys/private_key.json");

const PRIVATE_KEY = private_key.key;

module.exports = {
  solidity: "0.8.2",
  networks: {
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [`${PRIVATE_KEY}`]
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 20000000000,
      accounts: [`${PRIVATE_KEY}`]
    }
  },
};