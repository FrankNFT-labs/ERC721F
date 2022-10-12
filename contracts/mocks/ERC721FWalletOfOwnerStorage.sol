// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9 <0.9.0;

import "../token/ERC721/extensions/ERC721FWalletOfOwnerStorage.sol";

contract ERC721FWalletOfOwnerStorageMock is ERC721FWalletOfOwnerStorage {
    constructor(string memory name, string memory symbol) ERC721F(name, symbol) {
        
    }
}