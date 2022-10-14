const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const tokenURI = "TestingURI";

describe("Soulbound", function() {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("SoulboundMock");
        const [owner, addr1, addr2] = await ethers.getSigners();

        const hardhatToken = await Token.deploy("Soulbound", "Soulbound");

        await hardhatToken.deployed();

        return { Token, hardhatToken, owner, addr1, addr2 };
    }

    describe("approve", function() {
        it("Should only be executable by owner of the contract", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);
            
            await hardhatToken.mint(addr1.address, tokenURI);

            await expect(hardhatToken.approve(addr1.address, 0)).to.not.be.reverted;
            await expect(hardhatToken.connect(addr1).approve(addr1.address, 0)).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should set the address as the approved of the token", async function() {
            const { hardhatToken, addr1, addr2 } = await loadFixture(deployTokenFixture);

            await hardhatToken.mint(addr1.address, tokenURI);
            await hardhatToken.approve(addr2.address, 0);

            expect(await hardhatToken.getApproved(0)).to.be.equal(addr2.address);
        });

        it("Should allow that the owner of the token can be the ones being approved", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);
            
            await hardhatToken.mint(addr1.address, tokenURI);

            await expect(hardhatToken.approve(addr1.address, 0)).to.not.be.reverted;
            expect(await hardhatToken.getApproved(0)).to.be.equal(addr1.address);
        });

        it("Should remove the approval status when assigning another address to the token", async function() {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);

            await hardhatToken.mint(addr1.address, tokenURI);

            await hardhatToken.approve(owner.address, 0);
            expect(await hardhatToken.getApproved(0)).to.be.equal(owner.address);

            await hardhatToken.approve(addr2.address, 0);
            expect(await hardhatToken.getApproved(0)).to.be.equal(addr2.address);
        });
    });

    describe("setApproveForAll", function() {
        it("Should only be executable by the owner of the contract", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.setApprovalForAllOwner(addr1.address, addr1.address, true)).to.not.be.reverted;
            await expect(hardhatToken.connect(addr1).setApprovalForAllOwner(addr1.address, addr1.address, true)).be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should allow that the owner of the token can be the one being approved", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.setApprovalForAllOwner(addr1.address, addr1.address, true)).to.not.be.reverted;
            expect(await hardhatToken.isApprovedForAll(addr1.address, addr1.address)).to.be.true;
        });

        it("Should set the address as the approved of the token", async function() {
            const { hardhatToken, addr1, addr2 } = await loadFixture(deployTokenFixture);
            
            expect(await hardhatToken.isApprovedForAll(addr1.address, addr1.address)).to.be.false;

            await hardhatToken.setApprovalForAllOwner(addr1.address, addr2.address, true);

            expect(await hardhatToken.isApprovedForAll(addr1.address, addr2.address)).to.be.true;
        });

        it("Should remove the approval status when setting approval to false", async function() {
            const { hardhatToken, addr1, addr2 } = await loadFixture(deployTokenFixture);

            await hardhatToken.setApprovalForAllOwner(addr1.address, addr2.address, true);

            expect(await hardhatToken.isApprovedForAll(addr1.address, addr2.address)).to.be.true;

            await hardhatToken.setApprovalForAllOwner(addr1.address, addr2.address, false);

            expect(await hardhatToken.isApprovedForAll(addr1.address, addr2.address)).to.be.false;
        });
    });

    describe("mint", function() {
        it("Should only be executable by the owner of the contract", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);
            
            await expect(hardhatToken.mint(addr1.address, tokenURI)).to.not.be.reverted;
            await expect(hardhatToken.connect(addr1).mint(addr1.address, tokenURI)).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should increase the tokenbalance of the recipient", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.mint(addr1.address, tokenURI)).to.changeTokenBalance(hardhatToken, addr1.address, 1);
        });

        it("Should set the tokenURI of the minted token", async function() {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.mint(addr1.address, tokenURI);

            expect(await hardhatToken.tokenURI(0)).to.be.equal(tokenURI);
        });
    });

    describe("transferFrom", function() {
        let token;
        let ownerAdress;
        let otherAddress;
        let addressToBeApproved;

        beforeEach(async () => {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            token = hardhatToken;
            ownerAdress = owner;
            otherAddress = addr1;
            addressToBeApproved = addr2;
            await token.mint(otherAddress.address, tokenURI);
        });

        it("Should allow transfers done by owner", async function() {
            expect(await token.transferFrom(otherAddress.address, ownerAdress.address, 0)).to.not.be.reverted;
        });

        it("Shouldn't allow transfers by unapproved addresses", async function() {
            await expect(token.connect(addressToBeApproved).transferFrom(otherAddress.address, ownerAdress.address, 0)).to.be.revertedWith("Address is neither owner of contract nor approved for token/tokenowner");
        });

        it("Should allow transfers by approved addresses", async function() {
            await token.approve(addressToBeApproved.address, 0);

            await expect(token.connect(addressToBeApproved).transferFrom(otherAddress.address, ownerAdress.address, 0)).to.not.be.reverted;
        }); 

        it("Should allow transfers by approved-all addresses", async function() {
            await token.setApprovalForAllOwner(otherAddress.address, addressToBeApproved.address, true);

            await expect(token.connect(addressToBeApproved).transferFrom(otherAddress.address, ownerAdress.address, 0)).to.not.be.reverted;
        })

        it("Should transfer the token between addresses", async function() {
            await expect(token.transferFrom(otherAddress.address, ownerAdress.address, 0)).to.changeTokenBalances(token, [otherAddress.address, ownerAdress.address], [-1, 1]);
            expect(await token.ownerOf(0)).to.be.equal(ownerAdress.address);
        });

        it("Should remove the approval status of approved address post transfer", async function() {
            await token.approve(addressToBeApproved.address, 0);
            expect(await token.getApproved(0)).to.equal(addressToBeApproved.address);

            await token.connect(addressToBeApproved).transferFrom(otherAddress.address, ownerAdress.address, 0)

            expect(await token.getApproved(0)).to.not.equal(addressToBeApproved.address);
            expect(await token.getApproved(0)).to.equal(ethers.constants.AddressZero);
        });

        it("Shouldn't remove approval status of an approved-all address post transfer", async function() {
            await token.setApprovalForAllOwner(otherAddress.address, addressToBeApproved.address, true);
            
            await token.connect(addressToBeApproved).transferFrom(otherAddress.address, ownerAdress.address, 0);

            expect(await token.isApprovedForAll(otherAddress.address, addressToBeApproved.address)).to.be.true;
        });
    });

    describe("safeTransferFrom", function() {
        let token;
        let ownerAdress;
        let otherAddress;

        beforeEach(async () => {
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);
            token = hardhatToken;
            ownerAdress = owner;
            otherAddress = addr1;
            await token.mint(otherAddress.address, tokenURI);
        });
    });

    describe("burn", function() {
        let token;
        let ownerAdress;
        let otherAddress;
        let addressToBeApproved;

        beforeEach(async () => {
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
            token = hardhatToken;
            ownerAdress = owner;
            otherAddress = addr1;
            addressToBeApproved = addr2;
            await token.mint(otherAddress.address, tokenURI);
        });

        it("Should allow burns done by owner", async function() {
            await token.mint(otherAddress.address, tokenURI);

            await expect(token.burn(0)).to.not.be.reverted;
        });

        it("Shouldn't allow burns by unapproved addresses", async function() {
            await expect(token.connect(addressToBeApproved).burn(0)).to.be.revertedWith("Address is neither owner of contract nor approved for token/tokenowner");
        });

        it("Should allow burns by approved addresses", async function() {
            await token.approve(addressToBeApproved.address, 0);

            await expect(token.connect(addressToBeApproved).burn(0)).to.not.be.reverted;
        });

        it("Should allow burns by approved-all addresses", async function() {
            await token.setApprovalForAllOwner(otherAddress.address, addressToBeApproved.address, true);

            await expect(token.connect(addressToBeApproved).burn(0)).to.not.be.reverted;
        });

        it("Shouldn't remove approval status of approved-all address post burn", async function() {
            await token.setApprovalForAllOwner(otherAddress.address, addressToBeApproved.address, true);

            await token.connect(addressToBeApproved).burn(0);

            expect(await token.isApprovedForAll(otherAddress.address, addressToBeApproved.address)).to.be.true;
        });

        it("Should destroy the burned token", async function() {
            await token.burn(0);

            await expect(token.tokenURI(0)).to.be.revertedWith("ERC721: invalid token ID");
        });
    });

    describe("totalSupply", function() {
        it("Should display total minted tokens", async function() {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
            await hardhatToken.mint(owner.address, tokenURI);
            await hardhatToken.mint(owner.address, tokenURI);

            expect(await hardhatToken.totalSupply()).to.be.equal(2);
        });

        it("Should take burned tokens into account when displaying totalSupply", async function() {
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
            await hardhatToken.mint(owner.address, tokenURI);
            await hardhatToken.mint(owner.address, tokenURI);
            await hardhatToken.burn(0);
            
            expect(await hardhatToken.totalSupply()).to.be.equal(1);
        });
    });
});