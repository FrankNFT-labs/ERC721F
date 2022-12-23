const fs = require('fs');

const wordCombination = 'Test result:';
const inputFilename = process.argv[2];
const outputFilename = process.argv[3];

const directory = outputFilename.substring(0, outputFilename.lastIndexOf('/'));
const file = outputFilename.substring(outputFilename.lastIndexOf('/') + 1);

try {
  fs.mkdirSync(directory, { recursive: true });
} catch (err) {
  if (err.code !== 'EEXIST') {
    console.error(err);
    return;
  }
}

fs.readFile(inputFilename, 'utf8', (err, data) => {
  if (err) {
    console.error(err);
    return;
  }

  const lines = data.split('\n');
  let found = false;
  const outputLines = [];
  for (const line of lines) {
    if (!found) {
      if (line.includes(wordCombination)) {
        found = true;
      }
    } else {
      outputLines.push(line);
    }
  }

  fs.appendFile(outputFilename, outputLines.join('\n'), (err) => {
    if (err) {
      console.error(err);
      return;
    }

    console.log(`Successfully written to ${outputFilename}`);
  });
});