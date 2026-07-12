#!/bin/bash

filter="${@:1}"

if [[ $filter != *.sol ]]; then
    echo "Invalid filepath. It must end with '.sol'."
    exit 1
else
    # Hardhat 3 accepts file paths directly (replaces WHITELIST_PATH filter)
    npx hardhat compile "$@"
fi
