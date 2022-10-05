// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/utils/AllowList.sol";
import "../contracts/token/ERC721/ERC721F.sol";

contract AllowListExample is AllowList, ERC721F {
    constructor() ERC721F("AllowList", "AL") {
        setBaseTokenURI(
            "ipfs://QmVy7VQUFtTQawBsp4tbJPp9MgbTKS4L7WSDpZEdZUzsiD/"
        );
    }
}