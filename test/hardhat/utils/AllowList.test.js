const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AllowList", function () {
    async function deployFixture() {
        const [owner, alice, bob, carol] = await ethers.getSigners();
        const Mock = await ethers.getContractFactory("AllowListMock");
        const mock = await Mock.deploy();
        await mock.deployed();
        return { mock, owner, alice, bob, carol };
    }

    describe("allowAddress", function () {
        it("owner can add an address", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address);
            expect(await mock.isAllowList(alice.address)).to.be.true;
        });

        it("non-owner cannot add an address", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await expect(
                mock.connect(alice).allowAddress(alice.address)
            ).to.be.reverted;
        });

        it("adding an already-allowed address does not revert", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address);
            await expect(mock.allowAddress(alice.address)).to.not.be.reverted;
            expect(await mock.isAllowList(alice.address)).to.be.true;
        });
    });

    describe("allowAddresses", function () {
        it("owner can bulk-add addresses", async function () {
            const { mock, alice, bob } = await loadFixture(deployFixture);
            await mock.allowAddresses([alice.address, bob.address]);
            expect(await mock.isAllowList(alice.address)).to.be.true;
            expect(await mock.isAllowList(bob.address)).to.be.true;
        });

        it("non-owner cannot bulk-add", async function () {
            const { mock, alice, bob } = await loadFixture(deployFixture);
            await expect(
                mock.connect(alice).allowAddresses([bob.address])
            ).to.be.reverted;
        });
    });

    describe("disallowAddress", function () {
        it("owner can remove an allowed address", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address);
            await mock.disallowAddress(alice.address);
            expect(await mock.isAllowList(alice.address)).to.be.false;
        });

        it("non-owner cannot remove an address", async function () {
            const { mock, alice, bob } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address);
            await expect(
                mock.connect(bob).disallowAddress(alice.address)
            ).to.be.reverted;
        });

        it("disallowing an address not on the list does not revert", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await expect(mock.disallowAddress(alice.address)).to.not.be
                .reverted;
        });
    });

    describe("isAllowList", function () {
        it("returns false for an address never added", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            expect(await mock.isAllowList(alice.address)).to.be.false;
        });

        it("returns true after address is added", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address);
            expect(await mock.isAllowList(alice.address)).to.be.true;
        });

        it("returns false after address is removed", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await mock.allowAddress(alice.address);
            await mock.disallowAddress(alice.address);
            expect(await mock.isAllowList(alice.address)).to.be.false;
        });

        it("can be called by anyone", async function () {
            const { mock, alice, bob } = await loadFixture(deployFixture);
            await expect(mock.connect(bob).isAllowList(alice.address)).to.not.be
                .reverted;
        });
    });

    describe("onlyAllowList modifier", function () {
        it("reverts with AddressNotInAllowList for unlisted caller", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            await expect(
                mock.connect(alice).allowAddress(alice.address)
            ).to.be.reverted;
        });
    });
});
