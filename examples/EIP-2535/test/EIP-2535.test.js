import { expect } from "chai";
import {
    ethers,
    loadFixture,
    provider,
} from "../../../test/hardhat/helpers/connection.js";
import { loadAndExecuteDeploymentsFromFiles } from "../rocketh/environment.js";
import { shouldBehaveLikeERC721F } from "../../../test/hardhat/behaviours/index.js";

const deployTokenFixture = async () => {
    const env = await loadAndExecuteDeploymentsFromFiles({ provider });
    const [owner, addr1] = await ethers.getSigners();

    const eip2535 = env.get("EIP-2535");
    const hardhatToken = new ethers.Contract(
        eip2535.address,
        eip2535.abi,
        owner,
    );
    await hardhatToken.flipSaleState();
    return { hardhatToken, owner, addr1 };
};

describe("EIP-2535", function () {
    describe("Should behave like ERC72F", function () {
        shouldBehaveLikeERC721F(deployTokenFixture);
    });

    describe("burn", function () {
        it("Should allow the token owner to burn their own token", async function () {
            const { hardhatToken, owner } =
                await loadFixture(deployTokenFixture);
            await hardhatToken.mint(1);

            await hardhatToken.burn(0);

            expect(await hardhatToken.totalBurned()).to.equal(1);
            expect(await hardhatToken.balanceOf(owner.address)).to.equal(0);
        });

        it("Shouldn't allow a third party to burn someone else's token", async function () {
            const { hardhatToken, owner, addr1 } =
                await loadFixture(deployTokenFixture);
            await hardhatToken.mint(1);

            await expect(
                hardhatToken.connect(addr1).burn(0),
            ).to.be.revertedWith(
                "ERC721: caller is not token owner or approved",
            );

            expect(await hardhatToken.ownerOf(0)).to.equal(owner.address);
            expect(await hardhatToken.totalBurned()).to.equal(0);
        });

        it("Should allow an approved address to burn the token", async function () {
            const { hardhatToken, addr1 } =
                await loadFixture(deployTokenFixture);
            await hardhatToken.mint(1);
            await hardhatToken.approve(addr1.address, 0);

            await hardhatToken.connect(addr1).burn(0);

            expect(await hardhatToken.totalBurned()).to.equal(1);
        });

        it("Should allow an operator to burn the token", async function () {
            const { hardhatToken, addr1 } =
                await loadFixture(deployTokenFixture);
            await hardhatToken.mint(1);
            await hardhatToken.setApprovalForAll(addr1.address, true);

            await hardhatToken.connect(addr1).burn(0);

            expect(await hardhatToken.totalBurned()).to.equal(1);
        });

        it("Shouldn't allow burning a token which doesn't exist", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);

            await expect(hardhatToken.burn(0)).to.be.revertedWith(
                "ERC721: invalid token ID",
            );

            expect(await hardhatToken.totalBurned()).to.equal(0);
        });

        it("Shouldn't allow burning the same token twice", async function () {
            const { hardhatToken } = await loadFixture(deployTokenFixture);
            await hardhatToken.mint(1);
            await hardhatToken.burn(0);

            await expect(hardhatToken.burn(0)).to.be.revertedWith(
                "ERC721: invalid token ID",
            );

            expect(await hardhatToken.totalBurned()).to.equal(1);
        });
    });
});
