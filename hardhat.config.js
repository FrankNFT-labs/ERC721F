require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: false,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  gasReporter: {
    enabled: (process.env.REPORT_GAS === "true") ? true : false,
    //outputFile: "gas-report.txt",
    noColors: true,
    currency: "TRX",
    //coinmarketcap: process.env.COINMARKET_API_KEY,
    gasPrice: 50,
  },
};
