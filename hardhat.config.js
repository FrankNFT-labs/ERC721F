require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");

const {
    TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS,
} = require("hardhat/builtin-tasks/task-names");
const path = require("path");

subtask(
    TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS,
    async (_, { config }, runSuper) => {
        const paths = await runSuper();

        return paths.filter((solidityFilePath) => {
            const relativePath = path.relative(
                config.paths.sources,
                solidityFilePath
            );

            if (
                relativePath.includes("node_modules") ||
                relativePath.startsWith("lib") ||
                relativePath.startsWith(".deps") ||
                relativePath.startsWith("test/foundry")
            ) {
                return false;
            } else if (process.env.WHITELIST_PATH) {
                return (
                    relativePath === process.env.WHITELIST_PATH ||
                    solidityFilePath === process.env.WHITELIST_PATH
                );
            } else {
                console.log(relativePath);
                return true;
            }
        });
    }
);

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        version: "0.8.20",
        settings: {
            optimizer: {
                enabled: true,
                runs: 1000,
            },
        },
    },
    paths: {
        sources: "./",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts",
    },
    gasReporter: {
        enabled: process.env.REPORT_GAS === "true" ? true : false,
        //outputFile: "gas-report.txt",
        noColors: true,
        currency: "USD",
        //coinmarketcap: process.env.COINMARKET_API_KEY,
        //gasPrice: 50,
    },
};
