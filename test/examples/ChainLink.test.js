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
        it("Should request Random numbers successfully", async () => {
            const { hardhatToken, owner } = await deployTokenFixture();

            await expect(hardhatToken.mint(1)).to.emit(hardhatToken, "RequestedRandomness").withArgs(BigNumber.from(1), owner.address);
        });
    });
});