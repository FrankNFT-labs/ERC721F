const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Soulbound", function() {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("SoulboundMock");
        const [owner, addr1, addr2] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("Soulbound", "Soulbound");

        await hardhatToken.deployed();

        return { Token, hardhatToken, owner, addr1, addr2 };
    }

    describe("Deployment", function() {

    });

    describe("Minting", function() {
        it("Should only be executable by the operators of the contract", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);
            
            await expect(hardhatToken.mint(addr1.address, "Testing")).to.not.be.reverted;
            await expect(hardhatToken.connect(addr1).mint(addr1.address, "Testing")).to.be.revertedWith("Sender does not have operator role");
            await hardhatToken.addOperator(addr1.address);
            await expect(hardhatToken.connect(addr1).mint(addr1.address, "Testing")).to.not.be.reverted;
        });

        it("Should increase the tokenbalance of the recipient", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.mint(addr1.address, "Testing")).to.changeTokenBalance(hardhatToken, addr1.address, 1);
        });

        it("Should set the tokenURI of the minted token", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.mint(addr1.address, "Testing");

            expect(await hardhatToken.tokenURI(0)).to.be.equal("Testing");
        });
    });

    describe("Transferring", function() {
        let token;
        let ownerAdress;
        let operatorAddress;
        let otherAddress;

        beforeEach(async () => {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            token = hardhatToken;
            ownerAdress = owner;
            operatorAddress = addr1;
            otherAddress = addr2;
            await token.mint(otherAddress.address, "Testing");
            await token.addOperator(operatorAddress.address);
        });

        it("Should allow transfers done by operators", async function() {
            expect(await token.transferFrom(otherAddress.address, ownerAdress.address, 0)).to.not.be.reverted;
            expect(await token.connect(operatorAddress).transferFrom(ownerAdress.address, otherAddress.address, 0)).to.not.be.reverted;
        });
    });

    describe("Burning", function() {

    });
});