require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  paths: {
    sources: "./examples",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};
