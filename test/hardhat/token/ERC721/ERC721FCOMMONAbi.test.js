const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721FCOMMON — ABI surface", function () {
    async function deployFixture() {
        const Token = await ethers.getContractFactory("ERC721FCOMMONMock");
        const [owner, alice] = await ethers.getSigners();
        const token = await Token.deploy("ABI Test", "ABI");
        await token.deployed();
        return { token, owner, alice };
    }

    describe("withdraw ABI", function () {
        it("withdraw(address,uint256) is the only withdraw variant in the ABI", async function () {
            const { token } = await loadFixture(deployFixture);
            const withdrawFragments = Object.keys(
                token.interface.functions
            ).filter((sig) => sig.startsWith("withdraw"));
            expect(withdrawFragments).to.deep.equal([
                "withdraw(address,uint256)",
            ]);
        });

        it("withdraw(address,uint256) transfers ETH to the recipient", async function () {
            const { token, owner, alice } = await loadFixture(deployFixture);
            await owner.sendTransaction({
                to: token.address,
                value: ethers.utils.parseEther("1"),
            });

            await expect(
                token.withdraw(alice.address, ethers.utils.parseEther("1"))
            ).to.changeEtherBalances(
                [token.address, alice.address],
                [
                    ethers.utils.parseEther("-1"),
                    ethers.utils.parseEther("1"),
                ]
            );
        });
    });
});
