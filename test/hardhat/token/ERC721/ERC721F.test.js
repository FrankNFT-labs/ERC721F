const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { shouldBehaveLikeERC721F } = require("../../behaviours");

const deployTokenFixture = async () => {
  const Token = await ethers.getContractFactory("ERC721FMock");
  const [owner, addr1] = await ethers.getSigners();

  const hardhatToken = await Token.deploy("ERC721F", "ERC721F");

  await hardhatToken.deployed();

  return { Token, hardhatToken, owner, addr1 };
};

describe("ERC721F", function () {
  describe("Should behave like ERC721F", function () {
    shouldBehaveLikeERC721F(deployTokenFixture);
  });
});
