// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721F.sol";

/**
 * @title MerkleRoot
 * 
 * @dev Example implementation of [ERC721F]
 */
contract MerkleRoot is ERC721F {

    constructor() ERC721F("MerkleRoot Pre-Sale", "Merkle") {
    }
}
