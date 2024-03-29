const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

let merkleTree;

describe("Token Contract", function () {
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

            expect(await hardhatToken.root()).to.not.be.null;
            expect(await hardhatToken.root()).to.not.be.undefined;
        });

        it("Should have set saleIsActive to false", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.saleIsActive()).to.be.false;
        });

        it("Should have set isPreSaleActive to false", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            expect(await hardhatToken.preSaleIsActive()).to.be.false;
        });
    });

    describe("SetRoot", function () {
        it("Should change the value of root", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            const originalRoot = await hardhatToken.root();
            await hardhatToken.setRoot("0x00314e565e0574cb412563df634608d76f5c59d9f817e85966100ec1d48005c0");

            expect(await hardhatToken.root()).to.not.equal(originalRoot);
        });

        it("Should only be executable by owner", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.setRoot("0x00314e565e0574cb412563df634608d76f5c59d9f817e85966100ec1d48005c0")).to.not.be.reverted;
            await expect(hardhatToken.connect(addr1).setRoot("0x00314e565e0574cb412563df634608d76f5c59d9f817e85966100ec1d48005c0")).to.be.reverted;
        });
    });

    describe("SaleFlipping", function () {
        it("Should flip saleIsActive to true", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();

            expect(await hardhatToken.saleIsActive()).to.be.true;
        });

        it("Should flip saleIsActive to false if flipping twice", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();
            await hardhatToken.flipSaleState();

            expect(await hardhatToken.saleIsActive()).to.be.false;
        });
    });

    describe("PreSaleFlipping", function () {
        it("Should flip preSaleIsActive to true", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipPreSaleState();

            expect(await hardhatToken.preSaleIsActive()).to.be.true;
        });

        it("Should flip preSaleIsActive to false when flipping twice", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipPreSaleState();
            await hardhatToken.flipPreSaleState();

            expect(await hardhatToken.preSaleIsActive()).to.be.false;
        });
    });

    describe("Pre-Sale Minting", function () {
        it("Shouldn't allow minting by whitelisted accounts during inactive pre-sale period", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            const merkleProof = createProof(addr1.address);

            await expect(hardhatToken.connect(addr1).mintPreSale(1, merkleProof, {
                value: ethers.utils.parseEther("1")
            })).to.be.revertedWith("PreSale is not active yet");
        });

        it("Shouldn't allow minting by whitelisted accounts which don't send enough funds", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            const merkleProof = createProof(addr1.address);
            await hardhatToken.flipPreSaleState();

            await expect(hardhatToken.connect(addr1).mintPreSale(1, merkleProof, {
                value: ethers.utils.parseEther("0.2")
            })).to.be.revertedWith("Ether value sent is not correct");
        });

        it("Shouldn't allow minting by unwhitelisted accounts during pre-sale period", async function () {
            const { hardhatToken, addr6 } = await loadFixture(deployTokenFixture);

            const merkleProof = createProof(addr6.address);
            await hardhatToken.flipPreSaleState();

            await expect(hardhatToken.connect(addr6).mintPreSale(1, merkleProof, {
                value: ethers.utils.parseEther("1")
            })).to.be.revertedWith("Invalid Merkle Proof");
        });

        it("Should allow minting by whitelisted accounts during active pre-sale period", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            const merkleProof = createProof(addr1.address);
            await hardhatToken.flipPreSaleState();

            await expect(hardhatToken.connect(addr1).mintPreSale(1, merkleProof, {
                value: ethers.utils.parseEther("1.0")
            })).to.not.be.reverted;
        });

        it("Should increase the total cost when requesting more tokens to be minted", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            const merkleProof = createProof(addr1.address);
            await hardhatToken.flipPreSaleState();

            await expect(hardhatToken.connect(addr1).mintPreSale(5, merkleProof, {
                value: ethers.utils.parseEther("1.0")
            })).to.be.revertedWith("Ether value sent is not correct");
        });

        it("Should transfer the transaction cost to the contract", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);
            const transferAmount = ethers.utils.parseEther("5");

            const merkleProof = createProof(addr1.address);
            await hardhatToken.flipPreSaleState();

            await expect(hardhatToken.connect(addr1).mintPreSale(5, merkleProof, {
                value: transferAmount
            })).to.changeEtherBalance(hardhatToken.address, transferAmount);
        });

        it("Shouldn't revert when account overpays transfer costs", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            const merkleProof = createProof(addr1.address);
            await hardhatToken.flipPreSaleState();

            await expect(hardhatToken.connect(addr1).mintPreSale(5, merkleProof, {
                value: ethers.utils.parseEther("50.0")
            })).to.not.be.reverted;
        });

        it("Should increase the token wallet of the acccount minting", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            const merkleProof = createProof(addr1.address);
            await hardhatToken.flipPreSaleState();

            await expect(hardhatToken.connect(addr1).mintPreSale(5, merkleProof, {
                value: ethers.utils.parseEther("5")
            })).to.changeTokenBalance(hardhatToken, addr1, 5);
        });
    });

    describe("During Sale Minting", function () {
        it("Shouldn't allow minting by anyone during inactive sale period", async function () {
            const { hardhatToken, addr1, addr6 } = await loadFixture(deployTokenFixture);
            const transferAmount = ethers.utils.parseEther("1");

            await expect(hardhatToken.connect(addr1).mint(1, {
                value: transferAmount
            })).to.be.revertedWith("Sale NOT active yet");
            await expect(hardhatToken.connect(addr6).mint(1, {
                value: transferAmount
            })).to.be.revertedWith("Sale NOT active yet");
        });

        it("Shouldn't allow minting by accounts which don't send enough funds", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();

            await expect(hardhatToken.connect(addr1).mint(1, {
                value: ethers.utils.parseEther("0.2")
            })).to.be.revertedWith("Ether value sent is not correct");
        });

        it("Should allow anyone to mint during active sale period when sending sufficient funds", async function () {
            const { hardhatToken, addr2, addr7 } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();

            await expect(hardhatToken.connect(addr2).mint(1, {
                value: ethers.utils.parseEther("1.0")
            })).to.not.be.reverted;
            await expect(hardhatToken.connect(addr7).mint(1, {
                value: ethers.utils.parseEther("1.0")
            })).to.not.be.reverted;
        });

        it("Should increase the total cost when requesting more tokens to be minted", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();

            await expect(hardhatToken.connect(addr1).mint(5, {
                value: ethers.utils.parseEther("1.0")
            })).to.be.revertedWith("Ether value sent is not correct");
        });

        it("Should transfer the transaction cost to the contract", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);
            const transferAmount = ethers.utils.parseEther("5");

            await hardhatToken.flipSaleState();

            await expect(hardhatToken.connect(addr1).mint(5, {
                value: transferAmount
            })).to.changeEtherBalance(hardhatToken, transferAmount);
        });

        it("Shouldn't revert when account overpays transfer costs", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();

            await expect(hardhatToken.connect(addr1).mint(5, {
                value: ethers.utils.parseEther("50.0")
            })).to.not.be.reverted;
        });

        it("Should increase the token wallet of the acccount minting", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();

            await expect(hardhatToken.connect(addr1).mint(5, {
                value: ethers.utils.parseEther("5")
            })).to.changeTokenBalance(hardhatToken, addr1, 5);
        });
    });

    describe("Withdraw", function () {
        it("Should only be executable by owner", async function () {
            const { hardhatToken, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();
            await hardhatToken.connect(addr1).mint(1, {
                value: ethers.utils.parseEther("1")
            });

            await expect(hardhatToken.withdraw()).to.not.be.reverted;
            await expect(hardhatToken.connect(addr1).withdraw()).to.be.reverted;
        });

        it("Should increase the walletbalance of the owner and decrease the wallet of the contract", async function () {
            const transferAmount = ethers.utils.parseEther("5");
            const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);

            await hardhatToken.flipSaleState();
            await hardhatToken.connect(addr1).mint(5, {
                value: transferAmount
            });

            await expect(hardhatToken.withdraw()).to.changeEtherBalances([hardhatToken.address, owner], [ethers.utils.parseEther("-5"), transferAmount]);
        });

        it("Should revert when no balance can be withdrawn", async function() {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.withdraw()).to.be.revertedWith("Insufficient balance");
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