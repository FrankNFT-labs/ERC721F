const { deployments } = require("hardhat");

const setupTest = deployments.createFixture(
  async ({ deployments, getNamedAccounts, ethers }, options) => {
    await deployments.fixture(); // ensure you start from a fresh deployments
    const { tokenOwner } = await getNamedAccounts();
    const TokenContract = await ethers.getContract("Token", tokenOwner);
    await TokenContract.mint(10).then((tx) => tx.wait()); //this mint is executed once and then `createFixture` will ensure it is snapshotted
    return {
      tokenOwner: {
        address: tokenOwner,
        TokenContract,
      },
    };
  }
);
describe("Token", () => {
  it("testing 1 2 3", async function () {
    const { tokenOwner } = await setupTest();
    await tokenOwner.TokenContract.mint(2);
  });
});
