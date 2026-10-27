import "dotenv/config";
import path from "node:path";
import hardhatToolboxMochaEthers from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import { defineConfig } from "hardhat/config";

// Hardhat 3 walks source directories recursively, node_modules included, and
// npm nests packages under examples/EIP-2535/node_modules when it cannot hoist
// them. Keep those dependency .sol files (e.g. hardhat-deploy's templates) out
// of the root build; npm: roots from npmFilesToBuild pass through untouched.
const skipNestedNodeModules = {
    id: "skip-nested-node-modules",
    npmPackage: null,
    hookHandlers: {
        solidity: async () => ({
            default: async () => ({
                build: (context, rootFilePaths, options, next) =>
                    next(
                        context,
                        rootFilePaths.filter(
                            (rootFilePath) =>
                                rootFilePath.startsWith("npm:") ||
                                !path
                                    .relative(
                                        context.config.paths.root,
                                        rootFilePath,
                                    )
                                    .split(path.sep)
                                    .includes("node_modules"),
                        ),
                        options,
                    ),
            }),
        }),
    },
};

// Compilation scope: explicit source directories replace the Hardhat 2
// TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS filter (lib, .deps and test/foundry
// are no longer reachable because sources are opt-in; node_modules nested in a
// source directory still is, hence skipNestedNodeModules).
// Focused runs use Hardhat 3 built-ins instead of WHITELIST_* env vars:
//   npx hardhat compile contracts/token/ERC721/ERC721F.sol
//   npx hardhat test test/hardhat/token/ERC721/ERC721F.test.js
export default defineConfig({
    plugins: [hardhatToolboxMochaEthers, skipNestedNodeModules],
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
