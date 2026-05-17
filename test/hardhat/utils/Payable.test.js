const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Payable", function () {
    async function deployFixture() {
        const [owner, alice] = await ethers.getSigners();

        const PayableMock = await ethers.getContractFactory("PayableMock");
        const mock = await PayableMock.deploy();
        await mock.deployed();

        const RejectEtherMock =
            await ethers.getContractFactory("RejectEtherMock");
        const rejecter = await RejectEtherMock.deploy();
        await rejecter.deployed();

        await owner.sendTransaction({
            to: mock.address,
            value: ethers.utils.parseEther("10"),
        });

        return { mock, rejecter, owner, alice };
    }

    describe("receive", function () {
        it("accepts ETH sent directly to the contract", async function () {
            const { mock, owner } = await loadFixture(deployFixture);
            const amount = ethers.utils.parseEther("1");
            const before = await ethers.provider.getBalance(mock.address);

            await owner.sendTransaction({ to: mock.address, value: amount });

            const after = await ethers.provider.getBalance(mock.address);
            expect(after.sub(before)).to.equal(amount);
        });
    });

    describe("withdraw", function () {
        it("transfers the exact amount to the recipient", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            const amount = ethers.utils.parseEther("1");

            await expect(
                mock.withdraw(alice.address, amount)
            ).to.changeEtherBalances(
                [mock.address, alice.address],
                [amount.mul(-1), amount]
            );
        });

        it("can withdraw the entire contract balance", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            const total = await ethers.provider.getBalance(mock.address);

            await expect(
                mock.withdraw(alice.address, total)
            ).to.changeEtherBalance(mock.address, total.mul(-1));
        });

        it("reverts with WithdrawToZeroAddress when to is address(0)", async function () {
            const { mock } = await loadFixture(deployFixture);

            await expect(
                mock.withdraw(
                    ethers.constants.AddressZero,
                    ethers.utils.parseEther("1")
                )
            ).to.be.revertedWithCustomError(mock, "WithdrawToZeroAddress");
        });

        it("reverts with EtherWithdrawFailed when recipient rejects ETH", async function () {
            const { mock, rejecter } = await loadFixture(deployFixture);

            await expect(
                mock.withdraw(
                    rejecter.address,
                    ethers.utils.parseEther("1")
                )
            ).to.be.revertedWithCustomError(mock, "EtherWithdrawFailed");
        });
    });
});
