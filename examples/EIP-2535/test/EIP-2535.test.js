const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect, should } = require("chai");
const { ethers, deployments } = require("hardhat");
const { shouldBehaveLikeERC721F } = require("../../../test/hardhat/behaviours");

const deployTokenFixture = async () => {
  await deployments.fixture();
  const [owner, addr1] = await ethers.getSigners();

  const hardhatToken = await ethers.getContract("EIP-2535", owner);
  await hardhatToken.flipSaleState();
  return { hardhatToken, owner, addr1 };
};

describe("EIP-2535", function () {
  describe("Should behave like ERC72F", function () {
    shouldBehaveLikeERC721F(deployTokenFixture);
  });
});
