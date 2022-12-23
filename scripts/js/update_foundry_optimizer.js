const fs = require('fs')

// get the new values from the command line arguments
const optimizerValue = process.argv[2]
const optimizerRunsValue = process.argv[3]

// read the foundry.toml file into memory
const foundry = fs.readFileSync('foundry.toml', 'utf8')

// split the file into lines
const lines = foundry.split('\n')

// find the lines with the optimizer and optimizer_runs variables and update their values
const updatedLines = lines.map((line) => {
  if (line.startsWith('optimizer=')) {
    return `optimizer=${optimizerValue}`
  } else if (line.startsWith('optimizer_runs=')) {
    return `optimizer_runs=${optimizerRunsValue}`
  }
  return line
})

// join the lines back into a single string
const updatedFoundry = updatedLines.join('\n')

// write the updated foundry.toml file back to disk
fs.writeFileSync('foundry.toml', updatedFoundry, 'utf8')
