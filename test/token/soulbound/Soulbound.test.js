const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const tokenURI = "TestingURI";

describe("Soulbound", function() {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("SoulboundMock");
        const [owner, addr1, addr2] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("Soulbound", "Soulbound");

        await hardhatToken.deployed();

        return { Token, hardhatToken, owner, addr1, addr2 };
    }

    describe("mint", function() {
        it("Should only be executable by the operators of the contract", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);
            
            await expect(hardhatToken.mint(addr1.address, tokenURI)).to.not.be.reverted;
            await expect(hardhatToken.connect(addr1).mint(addr1.address, tokenURI)).to.be.revertedWith("Sender does not have operator role");
            await hardhatToken.addOperator(addr1.address);
            await expect(hardhatToken.connect(addr1).mint(addr1.address, tokenURI)).to.not.be.reverted;
        });

        it("Should increase the tokenbalance of the recipient", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.mint(addr1.address, tokenURI)).to.changeTokenBalance(hardhatToken, addr1.address, 1);
        });

        it("Should set the tokenURI of the minted token", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.mint(addr1.address, tokenURI);

            expect(await hardhatToken.tokenURI(0)).to.be.equal(tokenURI);
        });
    });

    describe("transferFrom", function() {
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
            await token.mint(otherAddress.address, tokenURI);
            await token.addOperator(operatorAddress.address);
        });

        it("Should allow transfers done by operators", async function() {
            expect(await token.transferFrom(otherAddress.address, ownerAdress.address, 0)).to.not.be.reverted;
            expect(await token.connect(operatorAddress).transferFrom(ownerAdress.address, otherAddress.address, 0)).to.not.be.reverted;
        });

        it("Shouldn't allow transfers by unapproved addresses", async function() {
            await expect(token.connect(otherAddress).transferFrom(otherAddress.address, ownerAdress.address, 0)).to.be.revertedWith("Neither operator of contract nor approved address");
        });

        it("Should allow transfers by approved addresses", async function() {
            await token.approve(otherAddress.address, 0);

            await expect(token.connect(otherAddress).transferFrom(otherAddress.address, ownerAdress.address, 0)).to.not.be.reverted;
        }); 

        it("Should transfer the token between addresses", async function() {
            await expect(token.transferFrom(otherAddress.address, ownerAdress.address, 0)).to.changeTokenBalances(token, [otherAddress.address, ownerAdress.address], [-1, 1]);
            expect(await token.ownerOf(0)).to.be.equal(ownerAdress.address);
        });

        it("Should remove the approval status of approved address post transfer", async function() {
            await token.approve(otherAddress.address, 0);
            expect(await token.getApproved(0)).to.equal(otherAddress.address);

            await token.connect(otherAddress).transferFrom(otherAddress.address, ownerAdress.address, 0)

            expect(await token.getApproved(0)).to.not.equal(otherAddress.address);
            expect(await token.getApproved(0)).to.equal(ethers.constants.AddressZero);
        })
    });

    describe("burn", function() {
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
            await token.mint(otherAddress.address, tokenURI);
            await token.addOperator(operatorAddress.address);
        });
    });

    describe("totalSupply", function() {

    });
});