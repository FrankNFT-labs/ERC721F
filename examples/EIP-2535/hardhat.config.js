import "dotenv/config";
import hardhatToolboxMochaEthers from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import hardhatDeploy from "hardhat-deploy";
import { defineConfig } from "hardhat/config";

// If not set, it uses ours Alchemy's default API key.
// You can get your own at https://dashboard.alchemyapi.io
const providerApiKey =
    process.env.ALCHEMY_API_KEY || "oKxs-03sij-U_N0iOlrSsZFr29-IqbuF";
// If not set, it uses ours Etherscan default API key.
const etherscanApiKey =
    process.env.ETHERSCAN_API_KEY || "DNXJA8RX2Q3VZ4URQIWP7Z68CJXQZSC6AW";

export default defineConfig({
    plugins: [hardhatToolboxMochaEthers, hardhatDeploy],
    solidity: {
        profiles: {
            default: {
                version: "0.8.24",
                settings: {
                    evmVersion: "cancun",
                    optimizer: {
                        enabled: true,
                        runs: 1000,
                    },
                },
            },
            production: {
                version: "0.8.24",
                settings: {
                    evmVersion: "cancun",
                    optimizer: {
                        enabled: true,
                        runs: 1000,
                    },
                },
            },
        },
    },
    paths: {
        sources: "./contracts",
        tests: {
            mocha: "./test",
            solidity: "./test",
        },
        cache: "./cache",
        artifacts: "./artifacts",
    },
    networks: {
        hardhat: {
            type: "edr-simulated",
            chainType: "l1",
            forking: {
                url: `https://eth-mainnet.alchemyapi.io/v2/${providerApiKey}`,
                enabled: process.env.MAINNET_FORKING_ENABLED === "true",
            },
        },
    },
    verify: {
        etherscan: {
            apiKey: `${etherscanApiKey}`,
        },
    },
});
