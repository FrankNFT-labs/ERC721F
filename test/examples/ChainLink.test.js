const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ChainLink", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("ChainLink");
        const VRFMock = await ethers.getContractFactory("VRFCoordinatorV2Mock");
        const [owner, addr1] = await ethers.getSigners();

        const hardhatVrfMock = await VRFMock.deploy(0, 0);

        await hardhatVrfMock.createSubscription();

        await hardhatVrfMock.fundSubscription(1, ethers.utils.parseEther("7"));

        const hardhatToken = await Token.deploy(1, hardhatVrfMock.address);

        return { Token, hardhatToken, VRFMock, hardhatVrfMock, owner, addr1 };
    }

    describe("flipSaleState", function () {
        it("Reverts when startingIndex hasn't been set", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);;

            await expect(hardhatToken.flipSaleState()).to.be.revertedWith("startingIndex must be set before sale can begin");
        });

        it("Coordinator should emit RandomWordsFulfilled when asking for random number", async function () {
            const { hardhatToken, hardhatVrfMock } = await loadFixture(deployTokenFixture);;

            const tx = await hardhatToken.setRandomStartingIndex();
            const requestId = await retrieveRequestId(tx);

            await expect(
                hardhatVrfMock.fulfillRandomWords(requestId, hardhatToken.address)
            ).to.emit(hardhatVrfMock, "RandomWordsFulfilled");
        });

        it("Should allow flipping the saleState after having requested a randomStartingIndex", async function () {
            const { hardhatToken, hardhatVrfMock } = await loadFixture(deployTokenFixture);;

            const tx = await hardhatToken.setRandomStartingIndex();
            const requestId = await retrieveRequestId(tx);
            await expect(
                hardhatVrfMock.fulfillRandomWords(requestId, hardhatToken.address)
            ).to.emit(hardhatVrfMock, "RandomWordsFulfilled");

            await expect(await hardhatToken.flipSaleState()).to.not.be.revertedWith("startingIndex must be set before sale can begin");
            expect(await hardhatToken.saleIsActive()).to.be.true;
        });
    });

    describe("setRandomStartingIndex", function () {
        it("Should revert if the startingIndex has already been set", async function () {
            const { hardhatToken, hardhatVrfMock } = await loadFixture(deployTokenFixture);;

            const tx = await hardhatToken.setRandomStartingIndex();
            const requestId = await retrieveRequestId(tx);
            await expect(
                hardhatVrfMock.fulfillRandomWords(requestId, hardhatToken.address)
            ).to.emit(hardhatVrfMock, "RandomWordsFulfilled");

            await expect(hardhatToken.setRandomStartingIndex()).to.be.revertedWith("startingIndex already set");
        });
    });

    describe("mint", function () {
        it("Should increase the totalSupply and walletOfOwner size", async function () {
            const { hardhatToken, hardhatVrfMock, owner } = await loadFixture(deployTokenFixture);;

            const tx = await hardhatToken.setRandomStartingIndex();
            const requestId = await retrieveRequestId(tx);
            await expect(
                hardhatVrfMock.fulfillRandomWords(requestId, hardhatToken.address)
            ).to.emit(hardhatVrfMock, "RandomWordsFulfilled");

            await hardhatToken.flipSaleState();
            await hardhatToken.mint(1);

            expect(await hardhatToken.totalSupply()).to.be.equal(1);
            expect(Object.keys(await hardhatToken.walletOfOwner(owner.address)).length).to.be.equal(1);
        });

        it("Should allow multiple minting multiple records at once", async function () {
            const { hardhatToken, hardhatVrfMock, owner } = await loadFixture(deployTokenFixture);;

            const tx = await hardhatToken.setRandomStartingIndex();
            const requestId = await retrieveRequestId(tx);
            await expect(
                hardhatVrfMock.fulfillRandomWords(requestId, hardhatToken.address)
            ).to.emit(hardhatVrfMock, "RandomWordsFulfilled");

            await hardhatToken.flipSaleState();
            await hardhatToken.mint(10);

            expect(await hardhatToken.totalSupply()).to.be.equal(10);
            expect(Object.keys(await hardhatToken.walletOfOwner(owner.address)).length).to.be.equal(10);
        });

        it("Shouldn't assign non-owner mints to owner however should increase totalSupply", async function () {
            const { hardhatToken, hardhatVrfMock, owner, addr1 } = await loadFixture(deployTokenFixture);

            const tx = await hardhatToken.setRandomStartingIndex();
            const requestId = await retrieveRequestId(tx);
            await expect(
                hardhatVrfMock.fulfillRandomWords(requestId, hardhatToken.address)
            ).to.emit(hardhatVrfMock, "RandomWordsFulfilled");

            await hardhatToken.flipSaleState();
            await hardhatToken.mint(3);
            await hardhatToken.connect(addr1).mint(6);
            await hardhatToken.mint(1);

            expect(await hardhatToken.totalSupply()).to.be.equal(10);
            expect(Object.keys(await hardhatToken.walletOfOwner(owner.address)).length).to.be.equal(4);
            expect(Object.keys(await hardhatToken.walletOfOwner(addr1.address)).length).to.be.equal(6);
        });
    });
});

async function retrieveRequestId(tx) {
    const { events } = await tx.wait();

    const [requestId] = events.filter(x => x.event === "RequestedRandomness")[0].args;

    return requestId;
}