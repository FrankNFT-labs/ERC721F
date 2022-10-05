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

            it("shouldn't allow minting by whitelisted accounts which don't send enough funds", async function() {
                await expect(token.connect(whitelistedAddress).mintPreSale(5, {
                    value: transferAmount
                })).to.be.revertedWith("Ether value sent is not correct");
            });

            it("shouldn't allow minting by unwhitelisted accounts during pre-sale period", async function() {
                await expect(token.connect(nonWhitelistedAddress).mintPreSale(1, {
                    value: transferAmount
                })).to.be.revertedWith("Address is not within allowList");
            });

            it("should allow minting by whitelisted accounts during active pre-sale period", async function() {
                await expect(token.connect(whitelistedAddress).mintPreSale(1, {
                    value: transferAmount
                })).to.not.be.reverted;
            });

            it("should increase the total cost when requesting more tokens to be minted", async function() {
                await expect(token.connect(whitelistedAddress).mintPreSale(5, {
                    value: transferAmount
                })).to.be.revertedWith("Ether value sent is not correct");
            });

            it("should transfer the transaction cost to the contract", async function() {
                await expect(token.connect(whitelistedAddress).mintPreSale(1, {
                    value: transferAmount
                })).to.changeEtherBalance(token.address, transferAmount);
            });

            it("shouldn't revert when accounts overpays transfer costs", async function() {
                await expect(token.connect(whitelistedAddress).mintPreSale(1, {
                    value: ethers.utils.parseEther("5")
                })).to.not.be.reverted;
            });

            it("should increase the token wallet of the account minting", async function() {
                await expect(token.connect(whitelistedAddress).mintPreSale(5, {
                    value: ethers.utils.parseEther("5")
                })).to.changeTokenBalance(token, whitelistedAddress, 5);
            });
        });
    });

    context("mint", function() {
        describe("Inactive sale", function() {
            it("shouldn't allow minting by anyone", async function() {
                const { hardhatToken, addr1, addr6 } = await loadFixture(deployTokenFixture);

                await expect(hardhatToken.connect(addr1).mint(1, {
                    value: transferAmount
                })).to.be.revertedWith("Sale NOT active yet");
                await expect(hardhatToken.connect(addr6).mint(1, {
                    value: transferAmount
                })).to.be.revertedWith("Sale NOT active yet");
            });
        });

        describe("Active sale", function() {
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

            it("shouldn't allow minting by accounts which don't send enough funds", async function() {
                await expect(token.connect(whitelistedAddress).mint(5, {
                    value: transferAmount
                })).to.be.revertedWith("Ether value sent is not correct");
            });

            it("should allow anyone to mint when sending sufficient funds", async function() {
                await expect(token.connect(whitelistedAddress).mint(1, {
                    value: transferAmount
                })).to.not.be.reverted;
                await expect(token.connect(nonWhitelistedAddress).mint(1, {
                    value: transferAmount
                })).to.not.be.reverted;
            });

            it("should increase the total cost when requesting more tokens to be minted", async function() {
                await expect(token.mint(5, {
                    value: transferAmount
                })).to.be.revertedWith("Ether value sent is not correct");
            });

            it("should transfer the transaction cost to the contract", async function() {
                await expect(token.mint(1, {
                    value: transferAmount
                })).to.changeEtherBalance(token, transferAmount);
            });

            it("shouldn't revert when the accounts overpays transfer costs", async function() {
                await expect(token.mint(1, {
                    value: ethers.utils.parseEther("5")
                })).to.not.be.reverted;
            });

            it("should increase the token wallet of the account minting", async function() {
                await expect(token.connect(nonWhitelistedAddress).mint(1, {
                    value: transferAmount
                })).to.changeTokenBalance(token, nonWhitelistedAddress, 1);
            });
        });
    })

    describe("withdraw", function() {
        it("should only be executable by owner", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();
            await hardhatToken.connect(addr1).mint(1, {
                value: ethers.utils.parseEther("1")
            });

            await expect(hardhatToken.withdraw()).to.not.be.reverted;
            await expect(hardhatToken.connect(addr1).withdraw()).to.be.reverted;
        });

        it("should increase the wallebalance of the owner and decrease the wallet of the contract", async function() {
            const transferAmount = ethers.utils.parseEther("5");
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();
            await hardhatToken.connect(addr1).mint(5, {
                value: transferAmount
            });

            await expect(hardhatToken.withdraw()).to.changeEtherBalances([hardhatToken.address, owner], [ethers.utils.parseEther("-5"), transferAmount]);
        });

        it("should revert when no balance can be withdrawn", async function() {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.withdraw()).to.be.revertedWith("Insufficient balance");
        })
    });

    context("AllowList imported functions", function() {
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

        describe("allowAddress", function() {
            it("should only be executable by the owner", async function() {
                await expect(token.allowAddress(nonWhitelistedAddress.address)).to.not.be.reverted;
                await expect(token.connect(nonWhitelistedAddress).allowAddress(nonWhitelistedAddress.address)).to.be.reverted;
            })

            it("should add the address to the allowList", async function() {
                expect(await token.isAllowList(nonWhitelistedAddress.address)).to.be.false;

                await token.allowAddress(nonWhitelistedAddress.address);

                expect(await token.isAllowList(nonWhitelistedAddress.address)).to.be.true;
            });

            it("shouldn't revert or disallow an existing allowed address", async function() {
                expect(await token.isAllowList(whitelistedAddress.address)).to.be.true;

                await expect(token.allowAddress(whitelistedAddress.address)).to.not.be.reverted;

                expect(await token.isAllowList(whitelistedAddress.address)).to.be.true;
            });
        });

        describe("allowAddresses", function() {
            it("should only be executable by owner", async function() {
                await expect(token.allowAddresses([nonWhitelistedAddress.address])).to.not.be.reverted;
                await expect(token.connect(nonWhitelistedAddress).allowAddresses([nonWhitelistedAddress.address])).to.be.reverted;
            });

            it("should add the addresses to the allowList", async function() {
                expect(await token.isAllowList(nonWhitelistedAddress.address)).to.be.false;
                expect(await token.isAllowList(secondNonWhitelistedAddress.address)).to.be.false;

                await token.allowAddresses([nonWhitelistedAddress.address, secondNonWhitelistedAddress.address]);

                expect(await token.isAllowList(nonWhitelistedAddress.address)).to.be.true;
                expect(await token.isAllowList(secondNonWhitelistedAddress.address)).to.be.true;
            });

            it("shouldn't revert or disallow an existing allowed address", async function() {
                expect(await token.isAllowList(whitelistedAddress.address)).to.be.true;
                expect(await token.isAllowList(nonWhitelistedAddress.address)).to.be.false;

                await expect(token.allowAddresses([whitelistedAddress.address, nonWhitelistedAddress.address])).to.not.be.reverted;

                expect(await token.isAllowList(whitelistedAddress.address)).to.be.true;
                expect(await token.isAllowList(nonWhitelistedAddress.address)).to.be.true;
            });
        });

        describe("disallowAddress", function() {
            it("should only be executable by owner", async function() {
                await expect(token.disallowAddress(nonWhitelistedAddress.address)).to.not.be.reverted;
                await expect(token.connect(nonWhitelistedAddress).disallowAddress(nonWhitelistedAddress.address)).to.be.reverted;
            });

            it("should remove the address from the allowList", async function() {
                expect(await token.isAllowList(whitelistedAddress.address)).to.be.true;

                await token.disallowAddress(whitelistedAddress.address);

                expect(await token.isAllowList(whitelistedAddress.address)).to.be.false;
            });

            it("shouldn't revert or allow a non-existing allowed address", async function(){
                expect(await token.isAllowList(nonWhitelistedAddress.address)).to.be.false;

                await expect(token.disallowAddress(whitelistedAddress.address)).to.not.be.reverted;

                expect(await token.isAllowList(nonWhitelistedAddress.address)).to.be.false;
            });
        });

        describe("isAllowList", function() {
            it("should be executable by anyone", async function() {
                await expect(token.isAllowList(whitelistedAddress.address)).to.not.be.reverted;
                await expect(token.connect(nonWhitelistedAddress.address).isAllowList(whitelistedAddress.address)).to.not.be.reverted;
            });

            it("should return true for allowed addresses", async function() {
                expect(await token.isAllowList(whitelistedAddress.address)).to.be.true;
            });

            it("should return false for non-existing allowed addresses", async function() {
                expect(await token.isAllowList(nonWhitelistedAddress.address)).to.be.false;
            });

            it("should return false for disallowed addresses", async function() {
                await token.disallowAddress(nonWhitelistedAddress.address);

                expect(await token.isAllowList(nonWhitelistedAddress.address)).to.false;
            });
        });
    })
});