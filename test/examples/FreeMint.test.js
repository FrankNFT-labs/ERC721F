const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FreeMint", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("FreeMint");
        const [owner, addr1] = await ethers.getSigners();

        const hardhatToken = await Token.deploy();

        await hardhatToken.deployed();

        return { Token, hardhatToken, owner, addr1 };
    }

    describe("Max tokens minted in ONE TRX", function () {
        let totalMint = 1120; // Lower limit of tokens that'll increase in amount and be minted
        this.retries(10); // Amount of times the test will be attempted after failure

        beforeEach(function () {
            totalMint = totalMint + 1; // Increase total amount of tokens that are getting minted
        })

        // Test passes when `totalMint` is high enough to transcend the gas limit of a single transaction, this amount will then be displayed in the console 
        it("Should eventually fail indicating the total tokens minted", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            await hardhatToken.flipSaleState();
            await expect(hardhatToken.mint(totalMint)).to.be.reverted;
            console.log(totalMint);
        })
    });
});