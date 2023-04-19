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
      freeMint.address,
      true
    );
    await freeMint.flipSaleState();
    await freeMint.mint(5);
    await freeMint.flipSaleState();

    return { hotWalletProxy, token, owner, addr1, addr2 };
  }

  describe("claim", function () {
    it("does something", async function () {
      const { delegationRegistry } = await loadFixture(deployTokenFixture);
    });
  });
});
