module.exports = async ({ getNamedAccounts, deployments }) => {
  const { diamond } = deployments;
  const { deployer } = await getNamedAccounts();

  await diamond.deploy("EIP-2535", {
    from: deployer,
    facets: ["InitFacet", "MintFacet", "SaleControl", "ERC721FUpgradeable"],
    log: true,
    waitConfirmations: 1,
    autoMine: true,
    execute: {
      contract: "InitFacet",
      methodName: "init",
      args: [],
    },
  });
};
module.exports.tags = ["EIP-2535"];
