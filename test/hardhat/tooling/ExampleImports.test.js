import { expect } from "chai";
import { execSync } from "child_process";
import {
    copyFileSync,
    mkdirSync,
    mkdtempSync,
    readFileSync,
    rmSync,
    writeFileSync,
} from "fs";
import os from "os";
import path from "path";

const scriptName = "update_example_contract_imports.js";
const exampleSource =
    'import "../contracts/token/ERC721/ERC721F.sol";\n\ncontract Example {}\n';
// Stands in for a package npm could not hoist out of the EIP-2535 workspace.
const nestedSource = 'import "../proxy/Proxied.sol";\n\ncontract Nested {}\n';

// The script resolves examples/ relative to its own location, so it runs from
// a copy inside a throwaway tree and never touches the repository's examples.
describe("Example import rewriting", () => {
    let root;
    let exampleFile;
    let nestedFile;

    before(() => {
        root = mkdtempSync(path.join(os.tmpdir(), "example-imports-"));
        const scriptDir = path.join(root, "scripts", "js");
        const nestedDir = path.join(
            root,
            "examples",
            "EIP-2535",
            "node_modules",
            "nested-package",
        );
        exampleFile = path.join(root, "examples", "Example.sol");
        nestedFile = path.join(nestedDir, "Nested.sol");

        mkdirSync(scriptDir, { recursive: true });
        mkdirSync(nestedDir, { recursive: true });
        writeFileSync(
            path.join(root, "package.json"),
            '{ "type": "module" }\n',
        );
        copyFileSync(
            path.join(process.cwd(), "scripts", "js", scriptName),
            path.join(scriptDir, scriptName),
        );
        writeFileSync(exampleFile, exampleSource);
        writeFileSync(nestedFile, nestedSource);

        execSync(`node ${path.join(scriptDir, scriptName)} prod`, {
            stdio: "pipe",
        });
    });

    after(() => {
        rmSync(root, { recursive: true, force: true });
    });

    it("rewrites example contracts to the published package", () => {
        expect(readFileSync(exampleFile, "utf8")).to.equal(
            'import "@franknft.eth/erc721-f/contracts/token/ERC721/ERC721F.sol";\n\ncontract Example {}\n',
        );
    });

    it("leaves Solidity under nested node_modules untouched", () => {
        expect(readFileSync(nestedFile, "utf8")).to.equal(nestedSource);
    });
});
