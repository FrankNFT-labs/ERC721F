module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("Diamond", {
    from: deployer,
    facets: ["InitFacet", "ERC721FUpgradeable"],
    waitConfirmations: 1,
    autoMine: true,
    execute: {
      contract: "InitFacet",
      methodName: "init",
      args: [],
    },
  });
};
