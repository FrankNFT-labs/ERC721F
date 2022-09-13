const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token contract", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("FreeMint");
        const [owner, addr1] = await ethers.getSigners();

        const hardhatToken = await Token.deploy();

        await hardhatToken.deployed();

        return { Token, hardhatToken, owner, addr1 };
    }
    
    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.owner()).to.equal(owner.address);
        });
        
        it("Shouldn't have any tokens in the owners wallet", async function() {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.walletOfOwner(owner.address)).to.eql([]);
        });

        it("Contains an empty total supply", async function() {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.totalSupply()).to.equal(0);
        });
    });
});