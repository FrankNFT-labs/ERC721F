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

    describe("walletOfOwner", function() {
        context("Minting", function() {
            let token;
            let ownerAddress;
            let otherAddress;

            beforeEach(async () => {
                const { hardhatToken, owner, addr1 } = await deployTokenFixture(loadFixture);   
                token = hardhatToken;
                ownerAddress = owner;
                otherAddress = addr1;
                await token.mint(2);
            })

            it("Should assign the minted tokens to the wallet of the minter", async function() {
                const walletOfOwner = await token.walletOfOwner(ownerAddress.address);
                
                expect(walletOfOwner.map(t => t.toNumber())).to.have.members([0, 1]);
            });

            it("Should assign the minted tokens to the minter address", async function() {
                await token.connect(otherAddress).mint(5);
                const walletOfOwner = await token.walletOfOwner(otherAddress.address);

                expect(walletOfOwner.map(t => t.toNumber())).to.have.members([2, 3, 4, 5, 6]);
            });
        }); 
    });
});
