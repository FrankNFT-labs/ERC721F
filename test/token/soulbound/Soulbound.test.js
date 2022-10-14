const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Soulbound", function() {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("SoulboundMock");
        const [owner, addr1] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("Soulbound", "Soulbound");

        await hardhatToken.deployed();

        return { Token, hardhatToken, owner, addr1 };
    }

    describe("Deployment", function() {

    });

    describe("Minting", function() {
        it("Should only be executable by the owner of the contract", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);
            
            await expect(hardhatToken.mint(addr1.address, "Testing")).to.not.be.reverted;
            await expect(hardhatToken.connect(addr1).mint(addr1.address, "Testing")).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should increase the tokenbalance of the recipient", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.mint(addr1.address, "Testing")).to.changeTokenBalance(hardhatToken, addr1.address, 1);
        });
    });

    describe("Transferring", function() {

    });

    describe("Burning", function() {

    });
});