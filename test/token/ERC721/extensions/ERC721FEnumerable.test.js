const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721FEnumerable", function() {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("ERC721FEnumerable");
        const [owner] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("ERC721FEnumerable", "Enumerable");

        return { Token, hardhatToken, owner };
    }
});