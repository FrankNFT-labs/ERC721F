// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721FCOMMON.sol";
import "../contracts/utils/AllowListWithAmount.sol";

contract AllowListWithAmountExample is ERC721FCOMMON, AllowListWithAmount {
    constructor() ERC721FCOMMON("AllowListWithAmount", "ALA") {
        setBaseTokenURI(
            "ipfs://QmVy7VQUFtTQawBsp4tbJPp9MgbTKS4L7WSDpZEdZUzsiD/"
        );
    }
}