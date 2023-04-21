const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers, deployments } = require("hardhat");

describe("EIP-2535", function () {
  async function deployTokenFixture() {
    await deployments.fixture();
    const [owner] = await ethers.getSigners();

    const hardhatToken = await ethers.getContract("EIP-2535", owner);
    return { hardhatToken, owner };
  }

  describe("owner", function () {
    it("Owner is owner", async function () {
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
      expect(await hardhatToken.owner()).to.be.equals(owner.address);
    });
  });
});
