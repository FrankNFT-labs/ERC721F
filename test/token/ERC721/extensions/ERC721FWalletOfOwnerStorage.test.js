const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721FWalletOfOwnerStorage", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("ERC721FWalletOfOwnerStorageMock");
        const [owner, addr1] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("ERC721FWalletOfOwnerStorage", "walletOfOwnerStorage");

        return { Token, hardhatToken, owner, addr1 };
    }
});
