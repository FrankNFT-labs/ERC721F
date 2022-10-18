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

    describe("Minting", function () {
        it("Should increase total supply", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            const initialTotalSupply = await hardhatToken.totalSupply();

            await hardhatToken.mint(1);

            expect(await hardhatToken.totalSupply()).to.not.equal(initialTotalSupply);
        });

        it("Should assign the token to the wallet of the owner", async function () {
            const totalMintedTokens = 5;
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);

            await hardhatToken.mint(totalMintedTokens);

            const walletOfOwner = await hardhatToken.walletOfOwner(owner.address);

            expect(Object.keys(walletOfOwner).length).to.equal(totalMintedTokens);
        });

        it("Shouldn't assign non-owner mints to owner however should increase totalSupply", async function () {
            const totalOwnerMints = 3;
            const totalNonOwerMints = 4;
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.mint(totalOwnerMints);
            await hardhatToken.connect(addr1).mint(totalNonOwerMints);

            const walletOfOwner = await hardhatToken.walletOfOwner(owner.address);
            const totalSupply = await hardhatToken.totalSupply();

            expect(totalSupply).to.equal(totalOwnerMints + totalNonOwerMints);
            expect(Object.keys(walletOfOwner).length).to.equal(totalSupply - totalNonOwerMints);
        });
    });
});