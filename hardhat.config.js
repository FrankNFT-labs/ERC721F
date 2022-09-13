require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  paths: {
    sources: "./examples",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  gasReporter: {
    enabled: (process.env.REPORT_GAS === "true") ? true : false,
    outputFile: "gas-report.txt",
    noColors: true,
    currency: "USD",
  },
};
