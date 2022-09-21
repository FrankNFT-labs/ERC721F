// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721F.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title MerkleRoot
 * 
 * @dev Example implementation of [ERC721F]
 */
contract MerkleRoot is ERC721F {

    uint256 public constant MAX_TOKENS = 10000;
    uint public constant MAX_PURCHASE = 31; 
    bool public saleIsActive;
    bytes32 public root;

    constructor(bytes32 _root) ERC721F("MerkleRoot Pre-Sale", "Merkle") {
        root = _root;
    }

    function mint(bytes32[] calldata merkleProof) external {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        uint256 supply = totalSupply();
        require(supply <= MAX_TOKENS, "Purchase would exceed max supply of Tokens");
        if (!saleIsActive) {
            require(checkValidity(merkleProof), "Invalid Merkle Proof");
        }
        _mint(msg.sender, supply + 1);
    }

    function checkValidity(bytes32[] calldata merkleProof) public view returns (bool) {
        bytes32 leafToCheck = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(merkleProof, root, leafToCheck);
    }
}
