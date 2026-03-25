const { readFileSync } = require("fs");
const path = require("path");

describe("Husky hooks", () => {
    it("pre-commit should not use deprecated husky.sh bootstrap", () => {
        const hookPath = path.join(process.cwd(), ".husky", "pre-commit");
        const content = readFileSync(hookPath, "utf8");

        if (content.includes("_/husky.sh")) {
            throw new Error(
                "Deprecated husky bootstrap found in .husky/pre-commit; remove husky.sh sourcing for Husky v9+"
            );
        }
    });
});
