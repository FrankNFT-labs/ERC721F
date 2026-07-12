import { execSync } from "child_process";

describe("Passing command to EIP-2535 workspace", () => {
    it("should run npm test in eip-2535 workspace", () => {
        const workspace = "eip-2535";
        const cmd = `npm run test --workspace=${workspace}`;
        // Hardhat 3 exports its global options (HARDHAT_CONFIG, ...) as env
        // vars; strip them so the workspace run resolves its own config
        // instead of recursively re-running the root test suite.
        const env = Object.fromEntries(
            Object.entries(process.env).filter(
                ([key]) => !key.startsWith("HARDHAT_"),
            ),
        );
        const output = execSync(cmd, { env, timeout: 300000 });
        console.log(output.toString());
    });
});
