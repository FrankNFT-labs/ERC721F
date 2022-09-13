const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721F Gas Usage", function() {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("ERC721FGasReporterMock");
        const [owner, addr1] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("GAS Stress Test", "GAS");

        await hardhatToken.deployed();

        return { Token, hardhatToken, owner, addr1 };
    }

    describe("Minting", async function() {
        context("mintOne", async function() {
            it("Executes mintOne twice", async function() {
                const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
                for (let i = 0; i < 2; i++) {
                    await hardhatToken.mintOne(owner.address);
                }
            });            
        });

        context("mintTen", async function() {
            it("Executes mintTen twice", async function() {
                const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
                for (let i = 0; i < 2; i++) {
                    await hardhatToken.mintTen(owner.address);
                }
            });
        });

        context("mintHundred", async function() {
            it("Executes mintHundred twice", async function() {
                const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
                for (let i = 0; i < 2; i++) {
                    await hardhatToken.mintHundred(owner.address);
                }
            });
        });
    });
});