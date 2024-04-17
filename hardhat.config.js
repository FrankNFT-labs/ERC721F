require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");

const {
    TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS,
    TASK_TEST_GET_TEST_FILES,
} = require("hardhat/builtin-tasks/task-names");
const { subtask } = require("hardhat/config");
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
                const paths = process.env.WHITELIST_PATH.split(" ");
                return (
                    paths.includes(relativePath) ||
                    paths.includes(solidityFilePath)
                );
            } else {
                return true;
            }
        });
    }
);

subtask(TASK_TEST_GET_TEST_FILES, async (_, { config }, runSuper) => {
    const paths = await runSuper();

    return paths.filter((testFilePath) => {
        const relativePath = path.relative(config.paths.sources, testFilePath);

        if (process.env.WHITELIST_CONTRACT) {
            return relativePath.endsWith(
                `/${process.env.WHITELIST_CONTRACT}.test.js`
            );
        } else {
            return true;
        }
    });
});

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
