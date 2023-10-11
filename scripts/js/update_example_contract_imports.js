const fs = require("fs");
const path = require("path");

const args = process.argv.slice(2);
if (args.length !== 1) {
  console.error("Usage: node replacePaths.js <prod or dev>");
  process.exit(1);
}

const mode = args[0];

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

// List all files in the directory
fs.readdirSync(directoryPath).forEach((file) => {
  const filePath = path.join(directoryPath, file);

  if (fs.statSync(filePath).isFile()) {
    replacePaths(filePath, mode === "prod");
  }
});

console.log(`Paths in ${directoryPath} have been updated.`);
