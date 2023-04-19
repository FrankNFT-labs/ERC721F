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
    const [owner, addr1, addr2] = await ethers.getSigners();

    const delegationRegistry = await DelegationRegistry.deploy();
    const hotWalletProxy = await HotWalletProxy.deploy();
    const freeMint = await FreeMint.deploy();
    const token = await Token.deploy(
      hotWalletProxy.address,
      delegationRegistry.address,
      freeMint.address
    );

    await hotWalletProxy.setHotWallet(addr1.address, 9999999999, false);
    await delegationRegistry.delegateForContract(
      addr1.address,
      token.address,
      true
    );
    await freeMint.flipSaleState();
    await freeMint.mint(5);
    await freeMint.flipSaleState();

    return { token, owner, addr1, addr2 };
  }

  describe("mint", function () {
    it("Doesn't allow minting when sale is inactive", async function () {
      const { token, owner } = await loadFixture(deployTokenFixture);

      await expect(token.mint(1)).to.be.rejectedWith("SALE is not active yet");
    });

    it("Allows minting when sale is active", async function () {
      const { token, owner } = await loadFixture(deployTokenFixture);

      await token.flipSaleState();
      await expect(token.mint(1)).to.not.be.rejected;
    });

    it("Doesn't allow minting for someone else without delegation", async function () {
      const { token, owner, addr2 } = await loadFixture(deployTokenFixture);

      await token.flipSaleState();
      await expect(
        token.connect(addr2).mintDelegated(1, owner.address)
      ).to.be.rejectedWith("Not delegated by recipient");
    });

    it("Allows minting for someone else when delegated", async function () {
      const { token, owner, addr1 } = await loadFixture(deployTokenFixture);

      await token.flipSaleState();
      await expect(token.connect(addr1).mintDelegated(1, owner.address)).to.not
        .be.rejected;
      expect(await token.ownerOf(1)).to.be.equals(owner.address);
    });
  });
});
