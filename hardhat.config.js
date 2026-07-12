import "dotenv/config";
import hardhatToolboxMochaEthers from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import { defineConfig } from "hardhat/config";

// Compilation scope: explicit source directories replace the Hardhat 2
// TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS filter (node_modules, lib, .deps and
// test/foundry are no longer reachable because sources are opt-in).
// Focused runs use Hardhat 3 built-ins instead of WHITELIST_* env vars:
//   npx hardhat compile contracts/token/ERC721/ERC721F.sol
//   npx hardhat test test/hardhat/token/ERC721/ERC721F.test.js
export default defineConfig({
    plugins: [hardhatToolboxMochaEthers],
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
        },
        // Dependency contracts that tests instantiate by name; replaces the
        // Hardhat 2 shim imports in contracts/mocks and examples/mocks.
        npmFilesToBuild: [
            "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2Mock.sol",
        ],
    },
    paths: {
        sources: ["contracts", "examples"],
        tests: {
            mocha: "./test/hardhat",
            // Foundry (forge) remains the runner for test/foundry; keep
            // Hardhat's built-in solidity test runner away from those files.
            solidity: "./test/hardhat",
        },
        cache: "./cache",
        artifacts: "./artifacts",
    },
});
