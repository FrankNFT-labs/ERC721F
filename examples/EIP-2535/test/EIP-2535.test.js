import { ethers, provider } from "../../../test/hardhat/helpers/connection.js";
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
});
