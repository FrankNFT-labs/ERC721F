import { extensions } from "./config.js";
import { setupDeployScripts } from "rocketh";

// Re-export the generated artifacts so deploy scripts can reference facets.
// `generated/artifacts` is produced by hardhat-deploy on `hardhat compile`.
import * as artifacts from "../generated/artifacts/index.js";
export { artifacts };

const { deployScript } = setupDeployScripts(extensions);
export { deployScript };
