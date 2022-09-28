// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "./ERC721F.sol";

contract ERC721FOnChain is ERC721F {
    
    constructor(string memory name_, string memory symbol_) ERC721F(name_, symbol_) {
    }
}