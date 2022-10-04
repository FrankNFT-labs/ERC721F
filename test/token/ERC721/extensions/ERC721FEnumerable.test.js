const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721FEnumerable", function() {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("ERC721FEnumerableMock");
        const [owner, addr1] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("ERC721FEnumerable", "Enumerable");

        return { Token, hardhatToken, owner, addr1 };
    }

    describe("Should behave like ERC721Enumerable", function() {
        context("With minted tokens", function() {
            let token;
            let ownerContract;
            let otherAddress;
    
            beforeEach(async () => {
                const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
                token = hardhatToken;
                ownerContract = owner;
                otherAddress = addr1;
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

                describe("When the index is greater than or equal to the total tokens owned by the given address", function() {
                    it("Reverts", async function() {
                        await expect(token.tokenOfOwnerByIndex(ownerContract.address, 2)).to.be.revertedWith("Index out of bounds for owned tokens");
                    });
                });

                describe("When the given address does not own any tokens", function() {
                    it("Reverts", async function() {
                        await expect(token.tokenOfOwnerByIndex(otherAddress.address, 0)).to.be.revertedWith("Index out of bounds for owned tokens");
                    });
                });

                describe("After transferring all tokens to another user", function() {
                    beforeEach(async () => {
                        await token.transferFrom(ownerContract.address, otherAddress.address, 0);
                        await token.transferFrom(ownerContract.address, otherAddress.address, 1);
                    });
    
                    it("Returns correct token IDs for target", async function() {
                        expect(await token.balanceOf(otherAddress.address)).to.be.equal(2);
    
                        const tokensListed = await Promise.all(
                            [0, 1].map(i => token.tokenOfOwnerByIndex(otherAddress.address, i)),
                        );
    
                        expect(tokensListed.map(t => t.toNumber())).to.have.members([0, 1]);
                    });
    
                    it("Returns empty collection for original owner", async function() {
                        expect(await token.balanceOf(ownerContract.address)).to.be.equal(0);
    
                        await expect(token.tokenOfOwnerByIndex(ownerContract.address, 0)).to.be.revertedWith("Index out of bounds for owned tokens");
                    });
                });
            });
        });
    })
});