const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { ContractFunctionType } = require("hardhat/internal/hardhat-network/stack-traces/model");

const transferAmount = ethers.utils.parseEther("1");

describe("AllowList", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("AllowListExample");
        const [owner, addr1, addr2, addr3, addr4, addr5, addr6, addr7] = await ethers.getSigners();
        const presaleWhiteListAddresses = [
            owner.address, addr1.address, addr2.address, addr3.address, addr4.address, addr5.address
        ];

        const hardhatToken = await Token.deploy();

        await hardhatToken.deployed();

        await hardhatToken.allowAddresses(presaleWhiteListAddresses);

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
        })
    });

    context("flipSaleState", function() {
        describe("Single flip", function() {
            it("should cause saleIsActive to become true", async function() {
                const { hardhatToken } = await loadFixture(deployTokenFixture);

                await hardhatToken.flipSaleState();

                expect(await hardhatToken.saleIsActive()).to.be.true;
            });

            it("should disable preSaleIsactive when flipping to true", async function() {
                const { hardhatToken } = await loadFixture(deployTokenFixture);

                await hardhatToken.flipPreSaleState();
                expect(await hardhatToken.preSaleIsActive()).to.be.true;

                await hardhatToken.flipSaleState();
                expect(await hardhatToken.saleIsActive()).to.be.true;
                expect(await hardhatToken.preSaleIsActive()).to.be.false;
            });
        })

        describe("Double flip", function() {
            it("should cause saleIsActive to become false", async function() {
                const { hardhatToken } = await loadFixture(deployTokenFixture);

                await hardhatToken.flipSaleState();
                await hardhatToken.flipSaleState();

                expect(await hardhatToken.saleIsActive()).to.be.false;
            });
        });
    })

    context("flipPreSaleState", function() {
        describe("Single flip", function() {
            it("should cause preSaleIsActive to become true", async function() {
                const { hardhatToken } = await loadFixture(deployTokenFixture);

                await hardhatToken.flipPreSaleState();

                expect(await hardhatToken.preSaleIsActive()).to.be.true;
            });
        }); 

        describe("Double flip", function() {
            it("should cause preSaleIsActive to become false", async function() {
                const { hardhatToken } = await loadFixture(deployTokenFixture);

                await hardhatToken.flipPreSaleState();
                await hardhatToken.flipPreSaleState();

                expect(await hardhatToken.preSaleIsActive()).to.be.false;
            });
        });
    });

    context("mintPreSale", function() {
        describe("Inactive pre-sale", function() {
            it("shouldn't allow minting by whitelisted accounts during inactive pre-sale period", async function() {
                const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

                await expect(hardhatToken.connect(addr1).mintPreSale(1, {
                    value: transferAmount
                })).to.be.revertedWith("PreSale is NOT active yet");
            });
        });

        describe("Active pre-sale", function() {
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
        });
    });
});