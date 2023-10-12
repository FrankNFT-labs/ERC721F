const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Soulbound", function () {
  async function deployTokenFixture() {
    const Token = await ethers.getContractFactory("SoulboundMock");
    const [owner, addr1, addr2] = await ethers.getSigners();

    const hardhatToken = await Token.deploy("Soulbound", "Soulbound");

    await hardhatToken.deployed();

    return { Token, hardhatToken, owner, addr1, addr2 };
  }

  describe("supportsInterface", function () {
    it("Should return true with interfaceId=0xb45a3c0e", async function () {
      const { hardhatToken } = await loadFixture(deployTokenFixture);

      expect(await hardhatToken.supportsInterface(0xb45a3c0e)).to.be.true;
    });
  });

  describe("approve", function () {
    it("Should only be executable by owner of the contract", async function () {
      const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

      await hardhatToken.mint(addr1.address);

      await expect(hardhatToken.approve(addr1.address, 0)).to.not.be.reverted;
      await expect(
        hardhatToken.connect(addr1).approve(addr1.address, 0)
      ).to.be.revertedWithCustomError(
        hardhatToken,
        "OwnableUnauthorizedAccount"
      );
    });

    it("Should set the address as the approved of the token", async function () {
      const { hardhatToken, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );

      await hardhatToken.mint(addr1.address);
      await hardhatToken.approve(addr2.address, 0);

      expect(await hardhatToken.getApproved(0)).to.be.equal(addr2.address);
    });

    it("Should allow that the owner of the token can be the ones being approved", async function () {
      const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

      await hardhatToken.mint(addr1.address);

      await expect(hardhatToken.approve(addr1.address, 0)).to.not.be.reverted;
      expect(await hardhatToken.getApproved(0)).to.be.equal(addr1.address);
    });

    it("Should remove the approval status when assigning another address to the token", async function () {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );

      await hardhatToken.mint(addr1.address);

      await hardhatToken.approve(owner.address, 0);
      expect(await hardhatToken.getApproved(0)).to.be.equal(owner.address);

      await hardhatToken.approve(addr2.address, 0);
      expect(await hardhatToken.getApproved(0)).to.be.equal(addr2.address);
    });
  });

  describe("setApprovalForAll", function () {
    it("should only be executable by the owner of the contract", async function () {
      const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

      await expect(hardhatToken.setApprovalForAll(addr1.address, true)).to.not
        .be.reverted;
      await expect(
        hardhatToken.connect(addr1).setApprovalForAll(addr1.address, true)
      ).to.be.revertedWithCustomError(
        hardhatToken,
        "OwnableUnauthorizedAccount"
      );
    });

    it("Should set the address as the approved of the owner address", async function () {
      const { hardhatToken, owner, addr1 } = await loadFixture(
        deployTokenFixture
      );

      expect(await hardhatToken.isApprovedForAll(owner.address, addr1.address))
        .to.be.false;

      await hardhatToken.setApprovalForAll(addr1.address, true);

      expect(await hardhatToken.isApprovedForAll(owner.address, addr1.address))
        .to.be.true;
    });

    it("Should remove the approval status when setting approval to false", async function () {
      const { hardhatToken, owner, addr1 } = await loadFixture(
        deployTokenFixture
      );

      await hardhatToken.setApprovalForAll(addr1.address, true);

      expect(await hardhatToken.isApprovedForAll(owner.address, addr1.address))
        .to.be.true;

      await hardhatToken.setApprovalForAll(addr1.address, false);

      expect(await hardhatToken.isApprovedForAll(owner.address, addr1.address))
        .to.be.false;
    });
  });

  describe("setApprovalForAllOwner", function () {
    it("Should only be executable by the owner of the contract", async function () {
      const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

      await expect(
        hardhatToken.setApprovalForAllOwner(addr1.address, addr1.address, true)
      ).to.not.be.reverted;
      await expect(
        hardhatToken
          .connect(addr1)
          .setApprovalForAllOwner(addr1.address, addr1.address, true)
      ).to.be.revertedWithCustomError(
        hardhatToken,
        "OwnableUnauthorizedAccount"
      );
    });

    it("Should allow that the owner of the token can be the one being approved", async function () {
      const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

      await expect(
        hardhatToken.setApprovalForAllOwner(addr1.address, addr1.address, true)
      ).to.not.be.reverted;
      expect(await hardhatToken.isApprovedForAll(addr1.address, addr1.address))
        .to.be.true;
    });

    it("Should set the address as the approved of the token", async function () {
      const { hardhatToken, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );

      expect(await hardhatToken.isApprovedForAll(addr1.address, addr1.address))
        .to.be.false;

      await hardhatToken.setApprovalForAllOwner(
        addr1.address,
        addr2.address,
        true
      );

      expect(await hardhatToken.isApprovedForAll(addr1.address, addr2.address))
        .to.be.true;
    });

    it("Should remove the approval status when setting approval to false", async function () {
      const { hardhatToken, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );

      await hardhatToken.setApprovalForAllOwner(
        addr1.address,
        addr2.address,
        true
      );

      expect(await hardhatToken.isApprovedForAll(addr1.address, addr2.address))
        .to.be.true;

      await hardhatToken.setApprovalForAllOwner(
        addr1.address,
        addr2.address,
        false
      );

      expect(await hardhatToken.isApprovedForAll(addr1.address, addr2.address))
        .to.be.false;
    });
  });

  describe("allowBurn", function () {
    it("Should be only executable by the owner of the contract", async function () {
      const { hardhatToken, addr2 } = await loadFixture(deployTokenFixture);

      await hardhatToken.mint(addr2.address);

      await expect(hardhatToken.allowBurn(true)).to.not.be.reverted;
      await expect(
        hardhatToken.connect(addr2).allowBurn(true)
      ).to.be.revertedWithCustomError(
        hardhatToken,
        "OwnableUnauthorizedAccount"
      );
    });

    it("Should change the allowal of a tokenholder when setting to true/false", async function () {
      const { hardhatToken, addr2 } = await loadFixture(deployTokenFixture);

      await hardhatToken.mint(addr2.address);

      expect(await hardhatToken.tokenHolderIsAllowedToBurn()).to.be.false;

      await hardhatToken.allowBurn(true);

      expect(await hardhatToken.tokenHolderIsAllowedToBurn()).to.be.true;

      await hardhatToken.allowBurn(false);

      expect(await hardhatToken.tokenHolderIsAllowedToBurn()).to.be.false;
    });
  });

  describe("mint", function () {
    it("Should only be executable by the owner of the contract", async function () {
      const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

      await expect(hardhatToken.mint(addr1.address)).to.not.be.reverted;
      await expect(
        hardhatToken.connect(addr1).mint(addr1.address)
      ).to.be.revertedWithCustomError(
        hardhatToken,
        "OwnableUnauthorizedAccount"
      );
    });

    it("Should increase the tokenbalance of the recipient", async function () {
      const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

      await expect(hardhatToken.mint(addr1.address)).to.changeTokenBalance(
        hardhatToken,
        addr1.address,
        1
      );
    });

    it("Should set token to locked by default", async function () {
      const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

      await hardhatToken.mint(addr1.address);

      expect(await hardhatToken.locked(0)).to.be.true;
    });

    it("Should cause the Locked event to be emitted", async function () {
      const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

      await expect(hardhatToken.mint(addr1.address)).to.emit(
        hardhatToken,
        "Locked"
      );
    });
  });

  describe("unlockedStatus", function () {
    let token;
    let otherAddress;
    let addressToBeApproved;

    beforeEach(async () => {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      token = hardhatToken;
      otherAddress = addr1;
      addressToBeApproved = addr2;
      await token.mint(otherAddress.address);
    });

    it("Should only be executable by the owner of the conract", async function () {
      await expect(token.unlockedStatus(0, true)).to.not.be.reverted;
    });

    it("Shouldn't be executable by approved addresses", async function () {
      await token.approve(addressToBeApproved.address, 0);
      await expect(
        token.connect(addressToBeApproved).unlockedStatus(0, true)
      ).to.be.revertedWithCustomError(token, "OwnableUnauthorizedAccount");

      await token.approve(ethers.constants.AddressZero, 0);
      await token.setApprovalForAllOwner(
        otherAddress.address,
        addressToBeApproved.address,
        true
      );
      await expect(
        token.connect(addressToBeApproved).unlockedStatus(0, true)
      ).to.be.revertedWithCustomError(token, "OwnableUnauthorizedAccount");
    });

    it("Shouldn't be executable by other addresses", async function () {
      await expect(
        token.connect(otherAddress).unlockedStatus(0, true)
      ).to.be.revertedWithCustomError(token, "OwnableUnauthorizedAccount");
    });

    it("Should revert when token has yet to be minted", async function () {
      await expect(token.unlockedStatus(1, true)).to.be.revertedWith(
        "Token has yet to be minted"
      );
    });

    it("Should set the lockstatus of a minted token to false", async function () {
      await token.unlockedStatus(0, true);

      expect(await token.locked(0)).to.be.false;
    });

    it("Should set the lockstatus of a minted token to true when status is false", async function () {
      await token.unlockedStatus(0, true);

      expect(await token.locked(0)).to.be.false;

      await token.unlockedStatus(0, false);

      expect(await token.locked(0)).to.be.true;
    });

    it("Should emit the Unlocked event when set to true", async function () {
      await expect(token.unlockedStatus(0, true)).to.emit(token, "Unlocked");

      expect(await token.locked(0)).to.be.false;
    });

    it("Should emit the Locked event when set to false", async function () {
      await expect(token.unlockedStatus(0, false)).to.emit(token, "Locked");

      expect(await token.locked(0)).to.be.true;
    });
  });

  describe("locked", function () {
    let token;
    let otherAddress;
    let addressToBeApproved;

    beforeEach(async () => {
      const { hardhatToken, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      token = hardhatToken;
      otherAddress = addr1;
      addressToBeApproved = addr2;
      await token.mint(otherAddress.address);
    });

    it("Should be executable by anyone", async function () {
      await token.approve(addressToBeApproved.address, 0);

      await expect(token.locked(0)).to.not.be.reverted;
      await expect(token.connect(addressToBeApproved).locked(0)).to.not.be
        .reverted;
      await expect(token.connect(otherAddress).locked(0)).to.not.be.reverted;
    });

    it("Should revert when requesting a token owned by the zero address", async function () {
      await expect(token.locked(1)).to.be.revertedWith(
        "Token is owned by zero address"
      );

      await token.unlockedStatus(0, true);

      await expect(token.locked(0)).to.not.be.reverted;

      await token.burn(0);

      await expect(token.locked(0)).to.be.revertedWith(
        "Token is owned by zero address"
      );
    });
  });

  describe("transferFrom", function () {
    let token;
    let ownerAdress;
    let otherAddress;
    let addressToBeApproved;

    beforeEach(async () => {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      token = hardhatToken;
      ownerAdress = owner;
      otherAddress = addr1;
      addressToBeApproved = addr2;
      await token.mint(otherAddress.address);
    });

    context("Token is locked", function () {
      it("Shouldn't allow transfers done by anyone", async function () {
        await token.approve(addressToBeApproved.address, 0);

        await expect(
          token.transferFrom(otherAddress.address, ownerAdress.address, 0)
        ).to.be.revertedWith("Token can't be transferred");
        await expect(
          token
            .connect(otherAddress)
            .transferFrom(otherAddress.address, ownerAdress.address, 0)
        ).to.be.revertedWith("Token can't be transferred");
        await expect(
          token
            .connect(addressToBeApproved)
            .transferFrom(otherAddress.address, ownerAdress.address, 0)
        ).to.be.revertedWith("Token can't be transferred");

        await token.setApprovalForAllOwner(
          otherAddress.address,
          addressToBeApproved.address,
          true
        );
        await expect(
          token
            .connect(addressToBeApproved)
            .transferFrom(otherAddress.address, ownerAdress.address, 0)
        ).to.be.revertedWith("Token can't be transferred");
      });
    });

    context("Token is unlocked", function () {
      beforeEach(async () => {
        await token.unlockedStatus(0, true);
      });

      it("Should allow transfers done by owner", async function () {
        await expect(
          token.transferFrom(otherAddress.address, ownerAdress.address, 0)
        ).to.not.be.reverted;
      });

      it("Shouldn't allow transfers by unapproved addresses", async function () {
        await expect(
          token
            .connect(addressToBeApproved)
            .transferFrom(otherAddress.address, ownerAdress.address, 0)
        ).to.be.revertedWith(
          "Address is neither contractowner nor tokenapproved/tokenowner"
        );
      });

      it("Should allow transfers by approved addresses", async function () {
        await token.approve(addressToBeApproved.address, 0);

        await expect(
          token
            .connect(addressToBeApproved)
            .transferFrom(otherAddress.address, ownerAdress.address, 0)
        ).to.not.be.reverted;
      });

      it("Should allow transfers by approved-all addresses", async function () {
        await token.setApprovalForAllOwner(
          otherAddress.address,
          addressToBeApproved.address,
          true
        );

        await expect(
          token
            .connect(addressToBeApproved)
            .transferFrom(otherAddress.address, ownerAdress.address, 0)
        ).to.not.be.reverted;
      });

      it("Should transfer the token between addresses", async function () {
        await expect(
          token.transferFrom(otherAddress.address, ownerAdress.address, 0)
        ).to.changeTokenBalances(
          token,
          [otherAddress.address, ownerAdress.address],
          [-1, 1]
        );
        expect(await token.ownerOf(0)).to.be.equal(ownerAdress.address);
      });

      it("Should remove the approval status of approved address post transfer", async function () {
        await token.approve(addressToBeApproved.address, 0);
        expect(await token.getApproved(0)).to.equal(
          addressToBeApproved.address
        );

        await token
          .connect(addressToBeApproved)
          .transferFrom(otherAddress.address, ownerAdress.address, 0);

        expect(await token.getApproved(0)).to.not.equal(
          addressToBeApproved.address
        );
        expect(await token.getApproved(0)).to.equal(
          ethers.constants.AddressZero
        );
      });

      it("Shouldn't remove approval status of an approved-all address post transfer", async function () {
        await token.setApprovalForAllOwner(
          otherAddress.address,
          addressToBeApproved.address,
          true
        );

        await token
          .connect(addressToBeApproved)
          .transferFrom(otherAddress.address, ownerAdress.address, 0);

        expect(
          await token.isApprovedForAll(
            otherAddress.address,
            addressToBeApproved.address
          )
        ).to.be.true;
      });

      it("Shouldn't allow transfers from addresses which had their approved-all status removed", async function () {
        await token.setApprovalForAllOwner(
          otherAddress.address,
          addressToBeApproved.address,
          true
        );
        expect(
          await token.isApprovedForAll(
            otherAddress.address,
            addressToBeApproved.address
          )
        ).to.be.true;

        await token.setApprovalForAllOwner(
          otherAddress.address,
          addressToBeApproved.address,
          false
        );

        expect(
          await token.transferFrom(otherAddress.address, ownerAdress.address, 0)
        ).to.be.revertedWith(
          "Address is neither contractowner nor tokenapproved/tokenowner"
        );
      });

      it("Should lock the token post-transfer", async function () {
        await token.transferFrom(otherAddress.address, ownerAdress.address, 0);

        expect(await token.locked(0)).to.be.true;
      });
    });
  });

  describe("safeTransferFrom", function () {
    let token;
    let ownerAdress;
    let otherAddress;
    let addressToBeApproved;

    beforeEach(async () => {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      token = hardhatToken;
      ownerAdress = owner;
      otherAddress = addr1;
      addressToBeApproved = addr2;
      await token.mint(otherAddress.address);
    });

    context("Without data parameter", function () {
      context("Token is locked", function () {
        it("Shouldn't allow transfers by anyone", async function () {
          await token.approve(addressToBeApproved.address, 0);

          await expect(
            token.safeTransferFromHelperNonData(
              otherAddress.address,
              ownerAdress.address,
              0
            )
          ).to.be.revertedWith("Token can't be transferred");
          await expect(
            token
              .connect(otherAddress)
              .safeTransferFromHelperNonData(
                otherAddress.address,
                ownerAdress.address,
                0
              )
          ).to.be.revertedWith("Token can't be transferred");
          await expect(
            token
              .connect(addressToBeApproved)
              .safeTransferFromHelperNonData(
                otherAddress.address,
                ownerAdress.address,
                0
              )
          ).to.be.revertedWith("Token can't be transferred");

          await token.setApprovalForAllOwner(
            otherAddress.address,
            addressToBeApproved.address,
            true
          );
          await expect(
            token
              .connect(addressToBeApproved)
              .safeTransferFromHelperNonData(
                otherAddress.address,
                ownerAdress.address,
                0
              )
          ).to.be.revertedWith("Token can't be transferred");
        });
      });

      context("Token is unlocked", function () {
        beforeEach(async () => {
          await token.unlockedStatus(0, true);
        });

        it("Should allow transfers done by owner", async function () {
          await expect(
            token.safeTransferFromHelperNonData(
              otherAddress.address,
              ownerAdress.address,
              0
            )
          ).to.not.be.reverted;
        });

        it("Shouldn't allow transfers by unapproved addresses", async function () {
          await expect(
            token
              .connect(addressToBeApproved)
              .safeTransferFromHelperNonData(
                otherAddress.address,
                ownerAdress.address,
                0
              )
          ).to.be.revertedWith(
            "Address is neither contractowner nor tokenapproved/tokenowner"
          );
        });

        it("Should allow transfers by approved addresses", async function () {
          await token.approve(addressToBeApproved.address, 0);

          await expect(
            token
              .connect(addressToBeApproved)
              .safeTransferFromHelperNonData(
                otherAddress.address,
                ownerAdress.address,
                0
              )
          ).to.not.be.reverted;
        });

        it("Should allow transfers by approved-all addresses", async function () {
          await token.setApprovalForAllOwner(
            otherAddress.address,
            addressToBeApproved.address,
            true
          );

          await expect(
            token
              .connect(addressToBeApproved)
              .safeTransferFromHelperNonData(
                otherAddress.address,
                ownerAdress.address,
                0
              )
          ).to.not.be.reverted;
        });

        it("Should transfer the token between addresses", async function () {
          await expect(
            token.safeTransferFromHelperNonData(
              otherAddress.address,
              ownerAdress.address,
              0
            )
          ).to.changeTokenBalances(
            token,
            [otherAddress.address, ownerAdress.address],
            [-1, 1]
          );
          expect(await token.ownerOf(0)).to.be.equal(ownerAdress.address);
        });

        it("Should remove the approval status of approved address post transfer", async function () {
          await token.approve(addressToBeApproved.address, 0);
          expect(await token.getApproved(0)).to.equal(
            addressToBeApproved.address
          );

          await token
            .connect(addressToBeApproved)
            .safeTransferFromHelperNonData(
              otherAddress.address,
              ownerAdress.address,
              0
            );

          expect(await token.getApproved(0)).to.not.equal(
            addressToBeApproved.address
          );
          expect(await token.getApproved(0)).to.equal(
            ethers.constants.AddressZero
          );
        });

        it("Shouldn't remove approval status of an approved-all address post transfer", async function () {
          await token.setApprovalForAllOwner(
            otherAddress.address,
            addressToBeApproved.address,
            true
          );

          await token
            .connect(addressToBeApproved)
            .safeTransferFromHelperNonData(
              otherAddress.address,
              ownerAdress.address,
              0
            );

          expect(
            await token.isApprovedForAll(
              otherAddress.address,
              addressToBeApproved.address
            )
          ).to.be.true;
        });

        it("Shouldn't allow transfers from addresses which had their approved-all status removed", async function () {
          await token.setApprovalForAllOwner(
            otherAddress.address,
            addressToBeApproved.address,
            true
          );
          expect(
            await token.isApprovedForAll(
              otherAddress.address,
              addressToBeApproved.address
            )
          ).to.be.true;

          await token.setApprovalForAllOwner(
            otherAddress.address,
            addressToBeApproved.address,
            false
          );

          expect(
            await token.safeTransferFromHelperNonData(
              otherAddress.address,
              ownerAdress.address,
              0
            )
          ).to.be.revertedWith(
            "Address is neither contractowner nor tokenapproved/tokenowner"
          );
        });

        it("Should lock the token post-transfer", async function () {
          await token.safeTransferFromHelperNonData(
            otherAddress.address,
            ownerAdress.address,
            0
          );

          expect(await token.locked(0)).to.be.true;
        });
      });
    });

    context("With data parameter", function () {
      context("Token is locked", function () {
        it("Shouldn't allow transfers by anyone", async function () {
          await token.approve(addressToBeApproved.address, 0);

          await expect(
            token.safeTransferFromHelperWithData(
              otherAddress.address,
              ownerAdress.address,
              0,
              0x00
            )
          ).to.be.revertedWith("Token can't be transferred");
          await expect(
            token
              .connect(otherAddress)
              .safeTransferFromHelperWithData(
                otherAddress.address,
                ownerAdress.address,
                0,
                0x00
              )
          ).to.be.revertedWith("Token can't be transferred");
          await expect(
            token
              .connect(addressToBeApproved)
              .safeTransferFromHelperWithData(
                otherAddress.address,
                ownerAdress.address,
                0,
                0x00
              )
          ).to.be.revertedWith("Token can't be transferred");

          await token.setApprovalForAllOwner(
            otherAddress.address,
            addressToBeApproved.address,
            true
          );
          await expect(
            token
              .connect(addressToBeApproved)
              .safeTransferFromHelperWithData(
                otherAddress.address,
                ownerAdress.address,
                0,
                0x00
              )
          ).to.be.revertedWith("Token can't be transferred");
        });
      });

      context("Token is unlocked", function () {
        beforeEach(async () => {
          await token.unlockedStatus(0, true);
        });

        it("Should allow transfers done by owner", async function () {
          await expect(
            token.safeTransferFromHelperWithData(
              otherAddress.address,
              ownerAdress.address,
              0,
              0x00
            )
          ).to.not.be.reverted;
        });

        it("Shouldn't allow transfers by unapproved addresses", async function () {
          await expect(
            token
              .connect(addressToBeApproved)
              .safeTransferFromHelperWithData(
                otherAddress.address,
                ownerAdress.address,
                0,
                0x00
              )
          ).to.be.revertedWith(
            "Address is neither contractowner nor tokenapproved/tokenowner"
          );
        });

        it("Should allow transfers by approved addresses", async function () {
          await token.approve(addressToBeApproved.address, 0);

          await expect(
            token
              .connect(addressToBeApproved)
              .safeTransferFromHelperWithData(
                otherAddress.address,
                ownerAdress.address,
                0,
                0x00
              )
          ).to.not.be.reverted;
        });

        it("Should allow transfers by approved-all addresses", async function () {
          await token.setApprovalForAllOwner(
            otherAddress.address,
            addressToBeApproved.address,
            true
          );

          await expect(
            token
              .connect(addressToBeApproved)
              .safeTransferFromHelperWithData(
                otherAddress.address,
                ownerAdress.address,
                0,
                0x00
              )
          ).to.not.be.reverted;
        });

        it("Should transfer the token between addresses", async function () {
          await expect(
            token.safeTransferFromHelperWithData(
              otherAddress.address,
              ownerAdress.address,
              0,
              0x00
            )
          ).to.changeTokenBalances(
            token,
            [otherAddress.address, ownerAdress.address],
            [-1, 1]
          );
          expect(await token.ownerOf(0)).to.be.equal(ownerAdress.address);
        });

        it("Should remove the approval status of approved address post transfer", async function () {
          await token.approve(addressToBeApproved.address, 0);
          expect(await token.getApproved(0)).to.equal(
            addressToBeApproved.address
          );

          await token
            .connect(addressToBeApproved)
            .safeTransferFromHelperWithData(
              otherAddress.address,
              ownerAdress.address,
              0,
              0x00
            );

          expect(await token.getApproved(0)).to.not.equal(
            addressToBeApproved.address
          );
          expect(await token.getApproved(0)).to.equal(
            ethers.constants.AddressZero
          );
        });

        it("Shouldn't remove approval status of an approved-all address post transfer", async function () {
          await token.setApprovalForAllOwner(
            otherAddress.address,
            addressToBeApproved.address,
            true
          );

          await token
            .connect(addressToBeApproved)
            .safeTransferFromHelperWithData(
              otherAddress.address,
              ownerAdress.address,
              0,
              0x00
            );

          expect(
            await token.isApprovedForAll(
              otherAddress.address,
              addressToBeApproved.address
            )
          ).to.be.true;
        });

        it("Shouldn't allow transfers from addresses which had their approved-all status removed", async function () {
          await token.setApprovalForAllOwner(
            otherAddress.address,
            addressToBeApproved.address,
            true
          );
          expect(
            await token.isApprovedForAll(
              otherAddress.address,
              addressToBeApproved.address
            )
          ).to.be.true;

          await token.setApprovalForAllOwner(
            otherAddress.address,
            addressToBeApproved.address,
            false
          );

          expect(
            await token.safeTransferFromHelperWithData(
              otherAddress.address,
              ownerAdress.address,
              0,
              0x00
            )
          ).to.be.revertedWith(
            "Address is neither contractowner nor tokenapproved/tokenowner"
          );
        });

        it("Should lock the token post-transfer", async function () {
          await token.safeTransferFromHelperWithData(
            otherAddress.address,
            ownerAdress.address,
            0,
            0x00
          );

          expect(await token.locked(0)).to.be.true;
        });
      });
    });
  });

  describe("burn", function () {
    let token;
    let otherAddress;
    let addressToBeApproved;

    beforeEach(async () => {
      const { hardhatToken, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      token = hardhatToken;
      otherAddress = addr1;
      addressToBeApproved = addr2;
      await token.mint(otherAddress.address);
    });

    context("Token is locked", async function () {
      it("Shouldn't allow burns by anyone", async function () {
        await token.approve(addressToBeApproved.address, 0);

        await expect(token.burn(0)).to.be.revertedWith(
          "Token can't be transferred"
        );
        await expect(token.connect(otherAddress).burn(0)).to.be.revertedWith(
          "Token can't be transferred"
        );
        await expect(
          token.connect(addressToBeApproved).burn(0)
        ).to.be.revertedWith("Token can't be transferred");

        await token.setApprovalForAllOwner(
          otherAddress.address,
          addressToBeApproved.address,
          true
        );
        await expect(
          token.connect(addressToBeApproved).burn(0)
        ).to.be.revertedWith("Token can't be transferred");
      });
    });

    context("Token is unlocked", async function () {
      beforeEach(async () => {
        await token.unlockedStatus(0, true);
      });

      it("Should allow burns done by owner", async function () {
        await expect(token.burn(0)).to.not.be.reverted;
      });

      it("Shouldn't allow burns by unapproved addresses and non-allowed owners", async function () {
        await expect(
          token.connect(addressToBeApproved).burn(0)
        ).to.be.revertedWith("Token can't be transferred");
      });

      it("Should allow burns by approved addresses", async function () {
        await token.approve(addressToBeApproved.address, 0);

        await expect(
          token.connect(addressToBeApproved).burn(0)
        ).to.not.be.reverted;
      });

      it("Should allow burns by approved-all addresses", async function () {
        await token.setApprovalForAllOwner(
          otherAddress.address,
          addressToBeApproved.address,
          true
        );

        await expect(
          token.connect(addressToBeApproved).burn(0)
        ).to.not.be.reverted;
      });

      it("Should allow burns by allowed token holder", async function () {
        await token.allowBurn(true);

        await expect(token.connect(otherAddress).burn(0)).to.not.be.reverted;
      });

      it("Shouldn't remove approval status of approved-all address post burn", async function () {
        await token.setApprovalForAllOwner(
          otherAddress.address,
          addressToBeApproved.address,
          true
        );

        await token.connect(addressToBeApproved).burn(0);

        expect(
          await token.isApprovedForAll(
            otherAddress.address,
            addressToBeApproved.address
          )
        ).to.be.true;
      });

      it("Should destroy the burned token", async function () {
        await token.burn(0);

        await expect(token.tokenURI(0)).to.be.revertedWithCustomError(
          token,
          "ERC721NonexistentToken"
        );
      });

      it("Shouldn't allow burns from addresses which had their approved-all status removed", async function () {
        await token.setApprovalForAllOwner(
          otherAddress.address,
          addressToBeApproved.address,
          true
        );
        expect(
          await token.isApprovedForAll(
            otherAddress.address,
            addressToBeApproved.address
          )
        ).to.be.true;

        await token.setApprovalForAllOwner(
          otherAddress.address,
          addressToBeApproved.address,
          false
        );

        expect(await token.burn(0)).to.be.revertedWith(
          "Address is neither contractowner nor tokenapproved/tokenowner"
        );
      });
    });
  });

  describe("totalSupply", function () {
    it("Should display total minted tokens", async function () {
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
      await hardhatToken.mint(owner.address);
      await hardhatToken.mint(owner.address);

      expect(await hardhatToken.totalSupply()).to.be.equal(2);
    });

    it("Should take burned tokens into account when displaying totalSupply", async function () {
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
      await hardhatToken.mint(owner.address);
      await hardhatToken.unlockedStatus(0, true);
      await hardhatToken.mint(owner.address);
      await hardhatToken.burn(0);

      expect(await hardhatToken.totalSupply()).to.be.equal(1);
    });
  });

  describe("totalMinted", function () {
    it("Should display total minted tokens", async function () {
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
      await hardhatToken.mint(owner.address);
      await hardhatToken.mint(owner.address);

      expect(await hardhatToken.totalMinted()).to.be.equal(2);
    });

    it("Shouldn't be influenced by burned tokens", async function () {
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
      await hardhatToken.mint(owner.address);
      await hardhatToken.unlockedStatus(0, true);
      await hardhatToken.mint(owner.address);
      await hardhatToken.burn(0);

      expect(await hardhatToken.totalMinted()).to.be.equal(2);
    });
  });

  describe("totalBurned", function () {
    it("Should increase in value when burning tokens", async function () {
      const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
      await hardhatToken.mint(owner.address);

      expect(await hardhatToken.totalBurned()).to.be.equal(0);

      await hardhatToken.unlockedStatus(0, true);
      await hardhatToken.burn(0);

      expect(await hardhatToken.totalBurned()).to.be.equal(1);
    });
  });
});
