#!/bin/bash

FILTER="$1"

# Run the 'npx hardhat compile' command
WHITELIST_PATH=$FILTER npx hardhat compile
