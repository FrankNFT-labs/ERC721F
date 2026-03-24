const fs = require("fs");
const path = require("path");

const args = process.argv.slice(2);
if (args.length < 1) {
    console.error("Usage: node replacePaths.js <prod or dev> [file ...]");
    process.exit(1);
}

const mode = args[0];
const targetFiles = args.slice(1);

if (mode !== "prod" && mode !== "dev") {
    console.error("Usage: node replacePaths.js <prod or dev> [file ...]");
    process.exit(1);
}

// Assuming your script is in the /scripts/js folder
const directoryPath = path.join(__dirname, "..", "..", "examples");

// Function to replace paths
function replacePaths(filePath, isProd) {
    const data = fs.readFileSync(filePath, "utf8");
    let newData;

    if (isProd) {
        newData = data.replace(/(\.\.\/)/g, "@franknft.eth/erc721-f/");
    } else {
        newData = data.replace(/@franknft\.eth\/erc721-f/g, "..");
    }

    fs.writeFileSync(filePath, newData);
}

function isSolidityFile(filePath) {
    return path.extname(filePath) === ".sol";
}

function isInsideExamples(filePath) {
    const relative = path.relative(directoryPath, filePath);
    return relative && !relative.startsWith("..") && !path.isAbsolute(relative);
}

function collectSolidityFiles(rootDirectory) {
    const stack = [rootDirectory];
    const solidityFiles = [];

    while (stack.length > 0) {
        const currentDirectory = stack.pop();
        const entries = fs.readdirSync(currentDirectory, {
            withFileTypes: true,
        });

        for (const entry of entries) {
            const entryPath = path.join(currentDirectory, entry.name);
            if (entry.isDirectory()) {
                stack.push(entryPath);
            } else if (entry.isFile() && isSolidityFile(entryPath)) {
                solidityFiles.push(entryPath);
            }
        }
    }

    return solidityFiles;
}

const isProd = mode === "prod";
let filesToProcess;

if (targetFiles.length > 0) {
    filesToProcess = targetFiles
        .map((file) => path.resolve(file))
        .filter((filePath) => fs.existsSync(filePath))
        .filter((filePath) => fs.statSync(filePath).isFile())
        .filter((filePath) => isSolidityFile(filePath))
        .filter((filePath) => isInsideExamples(filePath));
} else {
    filesToProcess = collectSolidityFiles(directoryPath);
}

if (filesToProcess.length === 0) {
    console.log("No Solidity example files to update.");
    process.exit(0);
}

filesToProcess.forEach((filePath) => replacePaths(filePath, isProd));

console.log(`Paths updated in ${filesToProcess.length} file(s).`);
