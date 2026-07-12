import { extensions } from "./config.js";
import { setupEnvironmentFromFiles } from "@rocketh/node";
import { setupHardhatDeploy } from "hardhat-deploy/helpers";

// useful for test and scripts, uses file-system
const { loadAndExecuteDeploymentsFromFiles } =
    setupEnvironmentFromFiles(extensions);
const { loadEnvironmentFromHardhat } = setupHardhatDeploy(extensions);

export { loadEnvironmentFromHardhat, loadAndExecuteDeploymentsFromFiles };
