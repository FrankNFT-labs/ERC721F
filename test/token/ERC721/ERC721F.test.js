const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721F", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("ERC721FMock");
        const [owner, addr1] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("ERC721F", "ERC721F");

        await hardhatToken.deployed();

        return { Token, hardhatToken, owner, addr1 };
    }

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.owner()).to.equal(owner.address);
        });

        it("Shouldn't have any tokens in the owners wallet", async function () {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.walletOfOwner(owner.address)).to.eql([]);
        });

        it("Contains an empty total supply", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.totalSupply()).to.equal(0);
        });
    });

    describe("totalSupply", function() {
        it("Should increase in value after minting", async function() {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.totalSupply()).to.be.equal(0);

            await hardhatToken.mint(1);

            expect(await hardhatToken.totalSupply()).to.be.equal(1);
        });

        it("Should take burned tokens into account", async function() {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await hardhatToken.mint(2);
            await hardhatToken.burn(0);

            expect(await hardhatToken.totalSupply()).to.be.equal(1);
        });
    });

    describe("walletOfOwner", function() {
        let token;
        let ownerAddress;
        let otherAddress;

        beforeEach(async () => {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            token = hardhatToken;
            ownerAddress = owner;
            otherAddress = addr1;

            await token.mint(2);
            await token.connect(otherAddress).mint(1);
        });

        it("Should include the tokens minted by the sender", async function() {
            const walletOfOwner = await token.walletOfOwner(ownerAddress.address);
            
            expect(walletOfOwner.map(t => t.toNumber())).to.have.members([0, 1]);
        });

        it("Shouldn't assign minted tokens by another address to the owner of the contract", async function() {
            const walletOwner = await token.walletOfOwner(ownerAddress.address);
            const walletOther = await token.walletOfOwner(otherAddress.address);

            expect(walletOwner.map(t => t.toNumber())).to.not.include.members([2]);
            expect(walletOther.map(t => t.toNumber())).to.have.members([2]);
        });
    });

    describe("totalMinted", function() {
        it("Should increase in value after minting", async function() {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.totalMinted()).to.be.equal(0);

            await hardhatToken.mint(1);

            expect(await hardhatToken.totalMinted()).to.be.equal(1);
        });

        it("Shouldn't be influenced by burned tokens", async function() {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            
            await hardhatToken.mint(2);
            await hardhatToken.burn(0);

            expect(await hardhatToken.totalMinted()).to.be.equal(2);
        });
    });

    describe("totalBurned", function() {
        it("Should increase in value after burning", async function() {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            await hardhatToken.mint(1);

            expect(await hardhatToken.totalBurned()).to.be.equal(0);
            
            await hardhatToken.burn(0);

            expect(await hardhatToken.totalBurned()).to.be.equal(1);
        });
    });
});
