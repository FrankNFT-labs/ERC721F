const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

let merkleTree;

describe.only("Token Contract", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("MerkleRoot");
        const [owner, addr1, addr2, addr3, addr4, addr5, addr6, addr7] = await ethers.getSigners();
        const presaleWhiteListAddresses = [
            owner.address, addr1.address, addr2.address, addr3.address, addr4.address, addr5.address
        ];

        const hardhatToken = await Token.deploy(createMerkleRoot(presaleWhiteListAddresses));

        await hardhatToken.deployed();

        return { Token, hardhatToken, owner, addr1, addr2, addr3, addr4, addr5, addr6, addr7 };
    }

    describe("Deployment", function () {
        it("Should have defined the root", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.root).to.not.be.null;
            expect(await hardhatToken.root).to.not.be.undefined;
        });

        it("Shouldn't have defined isActive yet", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.isActive).to.be.undefined;
        });
    });

    describe("Pre-Sale Minting", function () {
        it("Should allow minting by whitelisted accounts during inactive sale period", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            const merkleProof = createProof(addr1.address);
            await expect(hardhatToken.connect(addr1).mint(merkleProof)).to.not.be.reverted;
        });

        it("Shouldn't allow minting by unwhitelisted accounts during inactive sale period", async function () {
            const { hardhatToken, addr6 } = await loadFixture(deployTokenFixture);

            const merkleProof = createProof(addr6.address);
            await expect(hardhatToken.connect(addr6).mint(merkleProof)).to.be.revertedWith("Invalid Merkle Proof");
        });
    });

    describe("Minting", function () {
        it("Should allow minting by anyone whitelisted or not during active sale period", async function () {
            const { hardhatToken, addr2, addr7 } = await loadFixture(deployTokenFixture);

            const merkleProofAddr2 = createProof(addr2.address);
            const merkleProofAddr7 = createProof(addr7.address);

            await hardhatToken.flipSaleState();

            await expect(hardhatToken.connect(addr2).mint(merkleProofAddr2)).to.not.be.reverted;
            await expect(hardhatToken.connect(addr7).mint(merkleProofAddr7)).to.not.be.reverted;
        });
    });
});

function createMerkleRoot(presaleWhiteListAddresses) {
    const leaves = presaleWhiteListAddresses.map(addr => keccak256(addr));
    merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true })
    const rootHash = merkleTree.getRoot().toString('hex');

    return "0x" + rootHash;
}

function createProof(address) {
    const hashesAddress = keccak256(address);
    const proof = merkleTree.getHexProof(hashesAddress);
    return proof;
}