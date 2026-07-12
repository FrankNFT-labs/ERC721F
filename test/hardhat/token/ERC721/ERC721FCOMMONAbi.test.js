import { expect } from "chai";
import { ethers, loadFixture } from "../../helpers/connection.js";
describe("ERC721FCOMMON — ABI surface", function () {
    async function deployFixture() {
        const Token = await ethers.getContractFactory("ERC721FCOMMONMock");
        const [owner, alice] = await ethers.getSigners();
        const token = await Token.deploy("ABI Test", "ABI");
        await token.waitForDeployment();
        return { token, owner, alice };
    }

    describe("withdraw ABI", function () {
        it("withdraw(address,uint256) is the only withdraw variant in the ABI", async function () {
            const { token } = await loadFixture(deployFixture);
            const withdrawFragments = token.interface.fragments
                .filter(
                    (f) =>
                        f.type === "function" && f.name.startsWith("withdraw"),
                )
                .map((f) => f.format("sighash"));
            expect(withdrawFragments).to.deep.equal([
                "withdraw(address,uint256)",
            ]);
        });

        it("withdraw(address,uint256) transfers ETH to the recipient", async function () {
            const { token, owner, alice } = await loadFixture(deployFixture);
            await owner.sendTransaction({
                to: token.target,
                value: ethers.parseEther("1"),
            });

            await expect(
                token.withdraw(alice.address, ethers.parseEther("1")),
            ).to.changeEtherBalances(
                ethers,
                [token.target, alice.address],
                [ethers.parseEther("-1"), ethers.parseEther("1")],
            );
        });
    });
});
