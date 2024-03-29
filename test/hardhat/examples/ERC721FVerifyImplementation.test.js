const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721FVerifyImplementation", function () {
  async function deployTokenFixture() {
    const DelegationRegistry = await ethers.getContractFactory(
      "DelegationRegistry"
    );
    const HotWalletProxy = await ethers.getContractFactory("HotWalletProxy");
    const FreeMint = await ethers.getContractFactory("FreeMint");
    const Token = await ethers.getContractFactory(
      "ERC721FVerifyImplementation"
    );
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const delegationRegistry = await DelegationRegistry.deploy();
    const hotWalletProxy = await HotWalletProxy.deploy();
    const freeMint = await FreeMint.deploy();
    const token = await Token.deploy(
      hotWalletProxy.address,
      delegationRegistry.address,
      freeMint.address
    );

    await freeMint.flipSaleState();
    await freeMint.mint(1);

    await hotWalletProxy.setHotWallet(addr1.address, 9999999999, false);
    await delegationRegistry.delegateForToken(
      addr2.address,
      freeMint.address,
      0,
      true
    );

    return {
      freeMint,
      token,
      owner,
      addr1,
      addr2,
      addr3,
      hotWalletProxy,
      delegationRegistry,
    };
  }

  describe("mint", function () {
    it("Doesn't allow mints when address does not have any tokens in freeMint or isn't delegated by vault", async function () {
      const { token, addr3 } = await loadFixture(deployTokenFixture);

      await expect(token.connect(addr3).mint(0)).to.be.rejectedWith(
        "Must have tokens in FreeMint"
      );
    });

    it("Allows minting when owner of token", async function () {
      const { token } = await loadFixture(deployTokenFixture);

      await expect(token.mint(0)).to.not.be.rejected;
    });

    it("Allows minting when owning tokens in FreeMint", async function () {
      const { token, addr1 } = await loadFixture(deployTokenFixture);

      await expect(token.connect(addr1).mint(0)).to.not.be.rejected;
    });

    it("Allows minting when delegated", async function () {
      const { token, addr2 } = await loadFixture(deployTokenFixture);

      await expect(token.connect(addr2).mint(0)).to.not.be.rejected;
    });
  });
});
