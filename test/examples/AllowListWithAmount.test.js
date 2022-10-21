const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

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

});