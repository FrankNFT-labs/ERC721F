import { expect } from "chai";
import { shouldBehaveLikeERC721F } from "../../behaviours/index.js";
import { ethers, loadFixture } from "../../helpers/connection.js";

const deployTokenFixture = async () => {
  const Token = await ethers.getContractFactory("ERC721FMock");
  const [owner, addr1] = await ethers.getSigners();

  const hardhatToken = await Token.deploy("ERC721F", "ERC721F");

  await hardhatToken.waitForDeployment();

  return { Token, hardhatToken, owner, addr1 };
};

describe("ERC721F", function () {
  describe("Should behave like ERC721F", function () {
    shouldBehaveLikeERC721F(deployTokenFixture);
  });
});
