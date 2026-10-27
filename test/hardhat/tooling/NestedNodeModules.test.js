import { expect } from "chai";
import { mkdirSync, rmSync, writeFileSync } from "fs";
import hre from "hardhat";
import path from "path";

// Stands in for a package npm could not hoist out of the EIP-2535 workspace;
// like hardhat-deploy's templates, its pragma matches no profile compiler.
const fixtureDir = path.join(
    process.cwd(),
    "examples",
    "EIP-2535",
    "node_modules",
    "nested-node-modules-fixture",
);
const fixtureFile = path.join(fixtureDir, "Fixture.sol");

describe("Nested node_modules", () => {
    before(() => {
        mkdirSync(fixtureDir, { recursive: true });
        writeFileSync(
            fixtureFile,
            "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.28;\n\ncontract Fixture {}\n",
        );
    });

    after(() => {
        rmSync(fixtureDir, { recursive: true, force: true });
    });

    it("are still reached by the source scan (drop skipNestedNodeModules once this fails)", async () => {
        expect(await hre.solidity.getRootFilePaths()).to.include(fixtureFile);
    });

    it("are left out of the build", async () => {
        const results = await hre.solidity.build([fixtureFile], {
            quiet: true,
        });

        expect(results).to.be.instanceOf(Map);
        expect([...results.keys()]).to.not.include(fixtureFile);
    });
});
