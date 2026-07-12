// Rocketh configuration (hardhat-deploy v2): named accounts and the
// extension functions available on the deploy environment.
// Replaces the Hardhat 2 `namedAccounts` config entry.

export const config = {
    accounts: {
        deployer: {
            // By default, it will take the first Hardhat account as the deployer
            default: 0,
        },
    },
};

// Each extension contributes functions to the deploy environment:
// - @rocketh/deploy: env.deploy
// - @rocketh/read-execute: env.read / env.execute
// - @rocketh/diamond: env.diamond (EIP-2535 declarative deployment)
import * as deployExtension from "@rocketh/deploy";
import * as readExecuteExtension from "@rocketh/read-execute";
import * as diamondExtension from "@rocketh/diamond";

const extensions = {
    ...deployExtension,
    ...readExecuteExtension,
    ...diamondExtension,
};
export { extensions };
