const { shouldBehaveLikeFreeMint } = require("./behaviours");
const { ethers } = require("hardhat");

const deployTokenFixture = async () => {
  const Token = await ethers.getContractFactory("FreeMint");
  const [owner] = await ethers.getSigners();

  const hardhatToken = await Token.deploy();

  await hardhatToken.deployed();

  return { Token, hardhatToken, owner };
};

describe("FreeMint", function () {
  describe("should behave like FreeMint", function () {
    shouldBehaveLikeFreeMint(deployTokenFixture);
  });
});
