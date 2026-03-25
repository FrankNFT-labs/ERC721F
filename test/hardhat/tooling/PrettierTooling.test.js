const { execSync } = require("child_process");

describe("Prettier tooling", () => {
    it("should run prettier check on a solidity file with plugin loaded", () => {
        const cmd =
            "npx prettier --check --plugin=prettier-plugin-solidity contracts/token/ERC721/ERC721F.sol";
        execSync(cmd, { stdio: "pipe" });
    });
});
