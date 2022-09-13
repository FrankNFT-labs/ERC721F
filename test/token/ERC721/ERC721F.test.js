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
});