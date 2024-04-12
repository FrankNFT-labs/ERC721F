const fs = require('fs')

// get the new value from the command line arguments
const newValue = process.argv[2]

// read the .env file into memory
const env = fs.readFileSync('.env', 'utf8')

// split the file into lines
const lines = env.split('\n')

// find the line with the BREAK_EVEN_COUNT variable and update its value
const updatedLines = lines.map((line) => {
  if (line.startsWith('BREAK_EVEN_COUNT=')) {
    return `BREAK_EVEN_COUNT=${newValue}`
  }
  return line
})

// join the lines back into a single string
const updatedEnv = updatedLines.join('\n')

// write the updated .env file back to disk
fs.writeFileSync('.env', updatedEnv, 'utf8')
