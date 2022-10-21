const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const transferAmount = ethers.utils.parseEther("1");

describe("AllowListWithAmount", function() {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("AllowListWithAmountExample");
        const [owner, addr1, addr2, addr3, addr4, addr5, addr6, addr7] = await ethers.getSigners();
        const presaleWhiteListAddresses = [
            owner.address, addr1.address, addr2.address, addr3.address, addr4.address, addr5.address
        ];

        const hardhatToken = await Token.deploy();

        await hardhatToken.deployed();

        await hardhatToken.allowAddresses(presaleWhiteListAddresses, 5);

        return { Token, hardhatToken, owner, addr1, addr2, addr3, addr4, addr5, addr6, addr7 };
    }

    describe("Deployment", function () {
        it("should have saleIsActive as false by default", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.saleIsActive()).to.be.false;
        });

        it("should have preSaleIsActive as false by default", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.preSaleIsActive()).to.be.false;
        });
    });

    context("flipSaleState", function () {
        describe("Single flip", function () {
            it("should cause saleIsActive to become true", async function () {
                const { hardhatToken } = await loadFixture(deployTokenFixture);

                await hardhatToken.flipSaleState();

                expect(await hardhatToken.saleIsActive()).to.be.true;
            });

            it("should disable preSaleIsactive when flipping to true", async function () {
                const { hardhatToken } = await loadFixture(deployTokenFixture);

                await hardhatToken.flipPreSaleState();
                expect(await hardhatToken.preSaleIsActive()).to.be.true;

                await hardhatToken.flipSaleState();
                expect(await hardhatToken.saleIsActive()).to.be.true;
                expect(await hardhatToken.preSaleIsActive()).to.be.false;
            });
        });

        describe("Double flip", function () {
            it("should cause saleIsActive to become false", async function () {
                const { hardhatToken } = await loadFixture(deployTokenFixture);

                await hardhatToken.flipSaleState();
                await hardhatToken.flipSaleState();

                expect(await hardhatToken.saleIsActive()).to.be.false;
            });
        });
    });

    context("flipPreSaleState", function () {
        describe("Single flip", function () {
            it("should cause preSaleIsActive to become true", async function () {
                const { hardhatToken } = await loadFixture(deployTokenFixture);

                await hardhatToken.flipPreSaleState();

                expect(await hardhatToken.preSaleIsActive()).to.be.true;
            });
        });

        describe("Double flip", function () {
            it("should cause preSaleIsActive to become false", async function () {
                const { hardhatToken } = await loadFixture(deployTokenFixture);

                await hardhatToken.flipPreSaleState();
                await hardhatToken.flipPreSaleState();

                expect(await hardhatToken.preSaleIsActive()).to.be.false;
            });
        });
    });

    context("mintPreSale", function () {
        describe("Inactive pre-sale", function () {
            it("shouldn't allow minting by whitelisted accounts during inactive pre-sale period", async function () {
                const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

                await expect(hardhatToken.connect(addr1).mintPreSale(1, {
                    value: transferAmount
                })).to.be.revertedWith("PreSale is NOT active yet");
            });
        });

        describe("Active pre-sale", function () {
            let token;
            let whitelistedAddress;
            let nonWhitelistedAddress;

            beforeEach(async () => {
                const { hardhatToken, addr1, addr6 } = await loadFixture(deployTokenFixture);
                token = hardhatToken;
                whitelistedAddress = addr1;
                nonWhitelistedAddress = addr6;

                await token.flipPreSaleState();
            });

            it("shouldn't allow minting by whitelisted accounts which don't send enough funds", async function () {
                await expect(token.connect(whitelistedAddress).mintPreSale(5, {
                    value: transferAmount
                })).to.be.revertedWith("Ether value sent is not correct");
            });

            it("shouldn't allow minting by unwhitelisted accounts or whitelisted accounts without available tokens during pre-sale period", async function () {
                await expect(token.connect(nonWhitelistedAddress).mintPreSale(1, {
                    value: transferAmount
                })).to.be.revertedWith("Address does not have any tokens available within allowList");
            });

            it("should allow minting by whitelisted accounts during active pre-sale period", async function () {
                await expect(token.connect(whitelistedAddress).mintPreSale(1, {
                    value: transferAmount
                })).to.not.be.reverted;
            });

            it("shouldn't allow minting when requesting more than their remaining available tokens", async function() {
                await expect(token.connect(whitelistedAddress).mintPreSale(6, {
                    value: ethers.utils.parseEther("6")
                })).to.be.revertedWith("Purchase would exceed max available tokens within allowList");
            });

            it("should increase the total cost when requesting more tokens to be minted", async function () {
                await expect(token.connect(whitelistedAddress).mintPreSale(5, {
                    value: transferAmount
                })).to.be.revertedWith("Ether value sent is not correct");
            });

            it("should transfer the transaction cost to the contract", async function () {
                await expect(token.connect(whitelistedAddress).mintPreSale(1, {
                    value: transferAmount
                })).to.changeEtherBalance(token.address, transferAmount);
            });

            it("shouldn't revert when accounts overpays transfer costs", async function () {
                await expect(token.connect(whitelistedAddress).mintPreSale(1, {
                    value: ethers.utils.parseEther("5")
                })).to.not.be.reverted;
            });

            it("should increase the token wallet of the account minting", async function () {
                await expect(token.connect(whitelistedAddress).mintPreSale(5, {
                    value: ethers.utils.parseEther("5")
                })).to.changeTokenBalance(token, whitelistedAddress, 5);
            });

            it("should decrease the total avaiable funds for an account post mint", async function() {
                expect(await token.getAllowListFunds(whitelistedAddress.address)).to.be.equal(5);
            
                await token.connect(whitelistedAddress).mintPreSale(1, {
                    value: transferAmount
                });

                expect(await token.getAllowListFunds(whitelistedAddress.address)).to.be.equal(4);
            });
        });
    });

    context("mint", function () {
        describe("Inactive sale", function () {
            it("shouldn't allow minting by anyone", async function () {
                const { hardhatToken, addr1, addr6 } = await loadFixture(deployTokenFixture);

                await expect(hardhatToken.connect(addr1).mint(1, {
                    value: transferAmount
                })).to.be.revertedWith("Sale NOT active yet");
                await expect(hardhatToken.connect(addr6).mint(1, {
                    value: transferAmount
                })).to.be.revertedWith("Sale NOT active yet");
            });
        });

        describe("Active sale", function () {
            let token;
            let whitelistedAddress;
            let nonWhitelistedAddress;

            beforeEach(async () => {
                const { hardhatToken, addr1, addr6 } = await loadFixture(deployTokenFixture);
                token = hardhatToken;
                whitelistedAddress = addr1;
                nonWhitelistedAddress = addr6;

                await token.flipSaleState();
            });

            it("shouldn't allow minting by accounts which don't send enough funds", async function () {
                await expect(token.connect(whitelistedAddress).mint(5, {
                    value: transferAmount
                })).to.be.revertedWith("Ether value sent is not correct");
            });

            it("should allow anyone to mint when sending sufficient funds", async function () {
                await expect(token.connect(whitelistedAddress).mint(1, {
                    value: transferAmount
                })).to.not.be.reverted;
                await expect(token.connect(nonWhitelistedAddress).mint(1, {
                    value: transferAmount
                })).to.not.be.reverted;
            });

            it("should increase the total cost when requesting more tokens to be minted", async function () {
                await expect(token.mint(5, {
                    value: transferAmount
                })).to.be.revertedWith("Ether value sent is not correct");
            });

            it("should transfer the transaction cost to the contract", async function () {
                await expect(token.mint(1, {
                    value: transferAmount
                })).to.changeEtherBalance(token, transferAmount);
            });

            it("shouldn't revert when the accounts overpays transfer costs", async function () {
                await expect(token.mint(1, {
                    value: ethers.utils.parseEther("5")
                })).to.not.be.reverted;
            });

            it("should increase the token wallet of the account minting", async function () {
                await expect(token.connect(nonWhitelistedAddress).mint(1, {
                    value: transferAmount
                })).to.changeTokenBalance(token, nonWhitelistedAddress, 1);
            });
        });
    });

    context("AllowListWithAmount imported functions", function() {
        let token;
        let whitelistedAddress;
        let nonWhitelistedAddress;
        let secondNonWhitelistedAddress;

        beforeEach(async () => {
            const { hardhatToken, addr1, addr6, addr7 } = await loadFixture(deployTokenFixture);
            token = hardhatToken;
            whitelistedAddress = addr1;
            nonWhitelistedAddress = addr6;
            secondNonWhitelistedAddress = addr7
        });
    });
});