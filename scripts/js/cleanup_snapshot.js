const fs = require('fs');

const wordCombination = 'Test result:';
const inputFilename = process.argv[2];
const outputFilename = process.argv[3];

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