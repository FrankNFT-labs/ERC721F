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
    uint public cost = 1 ether;
    bool public preSaleIsActive;
    bool public saleIsActive;
    bytes32 public root;

    constructor(bytes32 _root) ERC721F("MerkleRoot Pre-Sale", "Merkle") {
        root = _root;
    }

    /**
     * Changes the state of preSaleIsactive from true to false and false to true
     */
    function flipPreSaleState() external onlyOwner {
        preSaleIsActive = !preSaleIsActive;
    }

    /**
     * Changes the state of saleIsActive from true to false and false to true
     * @dev If saleIsActive becomes `true`sets preSaleIsActive to `false`
     */
    function flipSaleState() external onlyOwner {
        saleIsActive = !saleIsActive;
        if (saleIsActive) {
            preSaleIsActive = false;
        }
    }

    /**
     * @notice Mints a certain number of tokens
     * @param numberOfTokens Total tokens to be minted, must be larger than 0 and at most 30
     */
    function mint(uint256 numberOfTokens) external payable {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        require(saleIsActive, "Sale NOT active yet");
        require(numberOfTokens != 0, "numberOfNfts cannot be 0");
        require(
            numberOfTokens < MAX_PURCHASE,
            "Can only mint 30 tokens at a time"
        );
        uint256 supply = totalSupply();
        require(
            supply + numberOfTokens <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );

        require(msg.value >= cost * numberOfTokens, "Insufficient funds");
        for (uint256 i; i < numberOfTokens; ) {
            _mint(msg.sender, supply + i); // no need to use safeMint as we don't allow contracts.
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Mints a certain number of tokens
     * @param numberOfTokens Total tokens to be minted, must be larger than 0 and at most 30
     * @param merkleProof Proof that an address is part of the whitelisted pre-sale addresses
     * @dev Uses MerkleProof to determine whether an address is allowed to mint during the pre-sale
     */
    function mintPreSale(uint256 numberOfTokens, bytes32[] calldata merkleProof)
        external
        payable
    {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        require(preSaleIsActive, "PreSale is not active yet");
        require(numberOfTokens != 0, "numberOfNfts cannot be 0");
        require(
            numberOfTokens < MAX_PURCHASE,
            "Can only mint 30 tokens at a time"
        );
        uint256 supply = totalSupply();
        require(
            supply <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );

        if (!saleIsActive) {
            require(checkValidity(merkleProof), "Invalid Merkle Proof");
        }

        require(msg.value >= cost * numberOfTokens, "Insufficient funds");
        for (uint256 i; i < numberOfTokens; ) {
            _mint(msg.sender, supply + i); // no need to use safeMint as we don't allow contracts.
            unchecked {
                i++;
            }
        }
    }

    function checkValidity(bytes32[] calldata merkleProof)
        internal
        view
        returns (bool)
    {
        bytes32 leafToCheck = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(merkleProof, root, leafToCheck);
    }
}
