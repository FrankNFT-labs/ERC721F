#!/bin/bash

filter="$1"

if [[ $filter != *.sol ]]; then
    echo "Invalid filepath. It must end with '.sol'."
    exit 1
else
    filename=$(basename "$filter" .sol)

    WHITELIST_PATH=$filter npx hardhat compile
fi

