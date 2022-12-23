const fs = require('fs')

// get the new value from the command line arguments
const newValue = process.argv[2]

// read the foundry.toml file into memory
const foundry = fs.readFileSync('foundry.toml', 'utf8')

// split the file into lines
const lines = foundry.split('\n')

// find the line with the optimizer variable and update its value
const updatedLines = lines.map((line) => {
  if (line.startsWith('optimizer=')) {
    return `optimizer=${newValue}`
  }
  return line
})

// join the lines back into a single string
const updatedFoundry = updatedLines.join('\n')

// write the updated foundry.toml file back to disk
fs.writeFileSync('foundry.toml', updatedFoundry, 'utf8')
