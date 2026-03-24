const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721FCOMMON", function () {
    async function deployFixture() {
        const Token = await ethers.getContractFactory("ERC721FCOMMONMock");
        const [owner, addr1] = await ethers.getSigners();
        const token = await Token.deploy("ERC721FCOMMON", "COMMON");
        return { token, owner, addr1 };
    }

    describe("setRoyaltyReceiver", function () {
        it("reverts when called with the zero address", async function () {
            const { token } = await loadFixture(deployFixture);
            await expect(
                token.setRoyaltyReceiver(ethers.constants.AddressZero)
            ).to.be.revertedWithCustomError(
                token,
                "RoyaltyReceiverIsZeroAddress"
            );
        });

        it("accepts a valid non-zero receiver", async function () {
            const { token, addr1 } = await loadFixture(deployFixture);
            await expect(token.setRoyaltyReceiver(addr1.address)).to.not.be
                .reverted;
        });

        it("royaltyInfo returns the updated receiver", async function () {
            const { token, addr1 } = await loadFixture(deployFixture);
            await token.mint(1);
            await token.setRoyaltyReceiver(addr1.address);
            const [receiver] = await token.royaltyInfo(0, 10000);
            expect(receiver).to.equal(addr1.address);
        });
    });

    describe("setRoyalties", function () {
        it("owner can set royalties to 0 (royalties disabled)", async function () {
            const { token } = await loadFixture(deployFixture);
            await token.mint(1);
            await expect(token.setRoyalties(0)).to.not.be.reverted;
            const [, amount] = await token.royaltyInfo(0, 10000);
            expect(amount).to.equal(0);
        });

        it("owner can set royalties to 89 (max allowed, 89%)", async function () {
            const { token } = await loadFixture(deployFixture);
            await token.mint(1);
            await token.setRoyalties(89);
            const [, amount] = await token.royaltyInfo(0, 10000);
            expect(amount).to.equal(8900);
        });

        it("reverts when royalties set to 90 or above", async function () {
            const { token } = await loadFixture(deployFixture);
            await expect(token.setRoyalties(90)).to.be.revertedWithCustomError(
                token,
                "RoyaltiesTooHigh"
            );
            await expect(token.setRoyalties(100)).to.be.revertedWithCustomError(
                token,
                "RoyaltiesTooHigh"
            );
        });

        it("emits ROYALTIESUPDATED event", async function () {
            const { token } = await loadFixture(deployFixture);
            await expect(token.setRoyalties(5))
                .to.emit(token, "ROYALTIESUPDATED")
                .withArgs(5);
        });
    });

    describe("withdraw", function () {
        it("reverts when withdrawing to the zero address", async function () {
            const { token, owner } = await loadFixture(deployFixture);
            await owner.sendTransaction({
                to: token.address,
                value: ethers.utils.parseEther("1"),
            });
            await expect(
                token.withdraw(
                    ethers.constants.AddressZero,
                    ethers.utils.parseEther("1")
                )
            ).to.be.revertedWithCustomError(token, "WithdrawToZeroAddress");
        });

        it("succeeds when withdrawing to a valid address", async function () {
            const { token, addr1 } = await loadFixture(deployFixture);
            await (
                await ethers.getSigners()
            )[0].sendTransaction({
                to: token.address,
                value: ethers.utils.parseEther("1"),
            });
            const before = await ethers.provider.getBalance(addr1.address);
            await token.withdraw(addr1.address, ethers.utils.parseEther("1"));
            const after = await ethers.provider.getBalance(addr1.address);
            expect(after.sub(before)).to.equal(ethers.utils.parseEther("1"));
        });
    });

    describe("royaltyInfo", function () {
        it("reverts for non-existent token", async function () {
            const { token } = await loadFixture(deployFixture);
            await expect(
                token.royaltyInfo(999, 10000)
            ).to.be.revertedWithCustomError(
                token,
                "RoyaltyInfoForNonexistentToken"
            );
        });

        it("returns correct royalty amount for default 5% royalties", async function () {
            const { token, owner } = await loadFixture(deployFixture);
            await token.mint(1);
            const [receiver, amount] = await token.royaltyInfo(0, 10000);
            expect(receiver).to.equal(owner.address);
            expect(amount).to.equal(500); // 5% of 10000
        });
    });
});
