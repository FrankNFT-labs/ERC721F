const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const firstTokenId = 5042;
const secondTokenId = 79217;
const nonExistentTokenId = 13;
const fourthTokenId = 4;
const baseURI = "https://api.example.com/v1/";

const RECEIVER_MAGIC_VALUE = "0x150b7a02";

describe("ERC721FEnumerable", function() {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("ERC721FEnumerableMock");
        const [owner] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("ERC721FEnumerable", "Enumerable");

        return { Token, hardhatToken, owner };
    }

    describe("Should behave like ERC721Enumerable", function() {
        context("With minted tokens", function() {
            let token;
            let ownerContract;
    
            beforeEach(async () => {
                const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
                token = hardhatToken;
                ownerContract = owner;
                await token.mint(2);
            });
    
            describe("totalSupply", function() {
                it("Returns total token supply", async function() {
                    expect(await token.totalSupply()).to.be.equal("2");
                });
            });

            describe("tokenOfOwnerByIndex", function() {
                describe("When the given index is lower than the amount of tokens owned by the given address", function() {
                    it("Returns the token ID placed at the given index", async function() {
                        expect(await token.tokenOfOwnerByIndex(ownerContract.address, 0)).to.be.equal(0);
                    });
                });
            });
        });
    })
});