import { expect } from "chai";
import { ethers, loadFixture } from "../helpers/connection.js";
describe("Payable", function () {
    async function deployFixture() {
        const [owner, alice] = await ethers.getSigners();

        const PayableMock = await ethers.getContractFactory("PayableMock");
        const mock = await PayableMock.deploy();
        await mock.waitForDeployment();

        const RejectEtherMock =
            await ethers.getContractFactory("RejectEtherMock");
        const rejecter = await RejectEtherMock.deploy();
        await rejecter.waitForDeployment();

        await owner.sendTransaction({
            to: mock.target,
            value: ethers.parseEther("10"),
        });

        return { mock, rejecter, owner, alice };
    }

    describe("receive", function () {
        it("accepts ETH sent directly to the contract", async function () {
            const { mock, owner } = await loadFixture(deployFixture);
            const amount = ethers.parseEther("1");
            const before = await ethers.provider.getBalance(mock.target);

            await owner.sendTransaction({ to: mock.target, value: amount });

            const after = await ethers.provider.getBalance(mock.target);
            expect(after - before).to.equal(amount);
        });
    });

    describe("withdraw", function () {
        it("transfers the exact amount to the recipient", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            const amount = ethers.parseEther("1");

            await expect(
                mock.withdraw(alice.address, amount)
            ).to.changeEtherBalances(ethers, 
                [mock.target, alice.address],
                [-amount, amount]
            );
        });

        it("can withdraw the entire contract balance", async function () {
            const { mock, alice } = await loadFixture(deployFixture);
            const total = await ethers.provider.getBalance(mock.target);

            await expect(
                mock.withdraw(alice.address, total)
            ).to.changeEtherBalance(ethers, mock.target, -total);
        });

        it("reverts with WithdrawToZeroAddress when to is address(0)", async function () {
            const { mock } = await loadFixture(deployFixture);

            await expect(
                mock.withdraw(
                    ethers.ZeroAddress,
                    ethers.parseEther("1")
                )
            ).to.be.revertedWithCustomError(mock, "WithdrawToZeroAddress");
        });

        it("reverts with EtherWithdrawFailed when recipient rejects ETH", async function () {
            const { mock, rejecter } = await loadFixture(deployFixture);

            await expect(
                mock.withdraw(
                    rejecter.target,
                    ethers.parseEther("1")
                )
            ).to.be.revertedWithCustomError(mock, "EtherWithdrawFailed");
        });
    });
});
