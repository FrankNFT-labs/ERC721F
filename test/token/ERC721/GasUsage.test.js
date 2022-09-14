const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721F Gas Usage", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("ERC721FGasReporterMock");
        const [owner, addr1] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("GAS Stress Test", "GAS");

        await hardhatToken.deployed();

        return { Token, hardhatToken, owner, addr1 };
    }

    describe("Minting", async function () {
        context("mintOne", async function () {
            it("Executes mintOne twice", async function () {
                const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
                for (let i = 0; i < 2; i++) {
                    await hardhatToken.mintOne(owner.address);
                }
            });
        });

        context("mintTen", async function () {
            it("Executes mintTen twice", async function () {
                const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
                for (let i = 0; i < 2; i++) {
                    await hardhatToken.mintTen(owner.address);
                }
            });
        });

        context("mintHundred", async function () {
            it("Executes mintHundred twice", async function () {
                const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
                for (let i = 0; i < 2; i++) {
                    await hardhatToken.mintHundred(owner.address);
                }
            });
        });
    });

    describe("Transferring", async function () {
        context("mintOneTransferOneAsc", async function () {
            it("Transfers to and from two addresses", async function () {
                const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
                await hardhatToken.mintOne(owner.address);
                await hardhatToken.transferOneAsc(addr1.address);
                await hardhatToken.connect(addr1).transferOneAsc(owner.address);
            });
        });

        context("mintOneTransferOneDesc", async function () {
            it("Transfers to and from two addresses", async function () {
                const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
                await hardhatToken.mintOne(owner.address);
                await hardhatToken.transferOneDesc(addr1.address);
                await hardhatToken.connect(addr1).transferOneDesc(owner.address);
            });
        });

        context("mintTenTransferOneAsc", async function () {
            it("Transfers first token to address1 from owner with walletsize 10", async function () {
                const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
                await hardhatToken.mintTen(owner.address);
                await hardhatToken.transferOneAsc(addr1.address);
            });
        });

        context("mintTenTransferOneDesc", async function() {
            it("Transfers last token to addres1 from owner with walletsize 10", async function() {
                const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
                await hardhatToken.mintTen(owner.address);
                await hardhatToken.transferOneDesc(addr1.address);
            });
        });

        context("mintTentransferTenAsc", async function() {
            it("Transfer to and from two addresses", async function() {
                const {hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
                await hardhatToken.mintTen(owner.address);
                await hardhatToken.transferTenAsc(addr1.address);
                await hardhatToken.connect(addr1).transferTenAsc(owner.address);
            });
        });

        context("mintTenTransferTenDesc", async function() {
            it("Transfer to and from two addresses", async function() {
                const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
                await hardhatToken.mintTen(owner.address);
                await hardhatToken.transferTenDesc(addr1.address);
                await hardhatToken.connect(addr1).transferTenDesc(owner.address);
            });
        });
    });
});