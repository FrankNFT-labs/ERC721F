/**
 * Script for the initial deployment of the EIP-2535 contract which is built using 4 facets
 * The init function of InitFacet gets executed during the deployment/upgrade
 */

import { deployScript, artifacts } from "../rocketh/deploy.js";

export default deployScript(
    async (env) => {
        const { deployer } = env.namedAccounts;

        await env.diamond(
            "EIP-2535",
            { account: deployer },
            {
                facets: [
                    { artifact: artifacts.InitFacet },
                    { artifact: artifacts.MintFacet },
                    { artifact: artifacts.SaleControl },
                    { artifact: artifacts.ERC721FUpgradeable },
                ],
                execute: {
                    type: "facet",
                    functionName: "init",
                    args: [],
                },
            },
        );
    },
    { tags: ["EIP-2535"] },
);
