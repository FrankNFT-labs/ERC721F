const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AllowListWithAmount", function () {
    async function deployFixture() {
        const [owner, alice, bob] = await ethers.getSigners();
        const Mock = await ethers.getContractFactory("AllowListWithAmountMock");
        const mock = await Mock.deploy();
        await mock.deployed();
        return { mock, owner, alice, bob };
    }

    describe("allowAddress", function () {
        it("owner can add an address with a token quota", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address, 5);
            expect(await mock.getAllowListFunds(alice.address)).to.equal(5);
        });

        it("non-owner cannot add an address", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await expect(
                mock.connect(alice).allowAddress(alice.address, 5)
            ).to.be.reverted;
        });

        it("overwrites the quota when called again", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address, 5);
            await mock.allowAddress(alice.address, 10);
            expect(await mock.getAllowListFunds(alice.address)).to.equal(10);
        });
    });

    describe("allowAddresses", function () {
        it("owner can bulk-add addresses with the same quota", async function () {
            const { mock, alice, bob } = await loadFixture(deployFixture);
            await mock.allowAddresses([alice.address, bob.address], 3);
            expect(await mock.getAllowListFunds(alice.address)).to.equal(3);
            expect(await mock.getAllowListFunds(bob.address)).to.equal(3);
        });

        it("non-owner cannot bulk-add", async function () {
            const { mock, alice, bob } = await loadFixture(deployFixture);
            await expect(
                mock.connect(alice).allowAddresses([bob.address], 3)
            ).to.be.reverted;
        });
    });

    describe("disallowAddress", function () {
        it("resets quota to 0 for the removed address", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address, 5);
            await mock.disallowAddress(alice.address);
            expect(await mock.getAllowListFunds(alice.address)).to.equal(0);
        });

        it("non-owner cannot remove", async function () {
            const { mock, alice, bob } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address, 5);
            await expect(
                mock.connect(bob).disallowAddress(alice.address)
            ).to.be.reverted;
        });
    });

    describe("getAllowListFunds", function () {
        it("returns 0 for an address never added", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            expect(await mock.getAllowListFunds(alice.address)).to.equal(0);
        });
    });

    describe("onlyAllowListWithSufficientAvailableTokens modifier", function () {
        it("reverts when address has no quota", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await expect(
                mock.connect(alice).consumeTokens(1)
            ).to.be.revertedWithCustomError(
                mock,
                "InsufficientAllowListTokens"
            );
        });

        it("reverts when requesting more than the available quota", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address, 2);
            await expect(
                mock.connect(alice).consumeTokens(3)
            ).to.be.revertedWithCustomError(
                mock,
                "InsufficientAllowListTokens"
            );
        });

        it("succeeds and decreases quota when within allowance", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address, 5);
            await mock.connect(alice).consumeTokens(2);
            expect(await mock.getAllowListFunds(alice.address)).to.equal(3);
        });

        it("drains quota to zero when consuming exact allowance", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address, 5);
            await mock.connect(alice).consumeTokens(5);
            expect(await mock.getAllowListFunds(alice.address)).to.equal(0);
        });

        it("consuming more than quota sets it to zero rather than underflowing", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address, 3);
            await mock.connect(alice).consumeTokens(3);
            expect(await mock.getAllowListFunds(alice.address)).to.equal(0);
        });

        it("second caller with own quota is independent from first", async function () {
            const { mock, alice, bob } = await loadFixture(deployFixture);
            await mock.allowAddresses([alice.address, bob.address], 5);
            await mock.connect(alice).consumeTokens(3);
            expect(await mock.getAllowListFunds(bob.address)).to.equal(5);
        });
    });
});
