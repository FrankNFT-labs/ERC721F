const { execSync } = require("child_process");

describe("Passing command to EIP-2535 workspace", () => {
  it("should run npm test in eip-2535 workspace", () => {
    const workspace = "eip-2535";
    const cmd = `npm run test --workspace=${workspace}`;
    const output = execSync(cmd);
    console.log(output.toString());
  });
});
