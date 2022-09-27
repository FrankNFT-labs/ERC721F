const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

describe("ChainLink", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("ChainLink");
        const VRFMock = await ethers.getContractFactory("VRFCoordinatorV2Mock");
        const [owner] = await ethers.getSigners();

        const hardhatVrfMock = await VRFMock.deploy(0, 0);

        await hardhatVrfMock.createSubscription();

        await hardhatVrfMock.fundSubscription(1, ethers.utils.parseEther("7"));

        const hardhatToken = await Token.deploy(1, hardhatVrfMock.address);

        await hardhatToken.flipSaleState();

        return { Token, hardhatToken, VRFMock, hardhatVrfMock, owner };
    }

    describe("Events", function () {
        it("Contract should emit RequestRandomness event", async function () {
            const { hardhatToken, owner } = await deployTokenFixture();

            await expect(hardhatToken.mint(1)).to.emit(hardhatToken, "RequestedRandomness").withArgs(BigNumber.from(1), owner.address);
        });


        it("Coordinator should emit RandomWordsRequested event", async function () {
            const { hardhatToken, hardhatVrfMock } = await deployTokenFixture();

            await expect(hardhatToken.mint(1)).to.emit(hardhatVrfMock, "RandomWordsRequested");
        });

        it("Coordinator should emit RandomWordsFulfilled event during Random Number request", async function () {
            const { hardhatToken, hardhatVrfMock } = await deployTokenFixture();

            const tx = await hardhatToken.mint(1);
            const { events } = await tx.wait();
            const [reqId] = events.filter(x => x.event == "RequestedRandomness")[0].args;

            await expect(
                hardhatVrfMock.fulfillRandomWords(reqId, hardhatToken.address)
            ).to.emit(hardhatVrfMock, "RandomWordsFulfilled");
        });
    });
});