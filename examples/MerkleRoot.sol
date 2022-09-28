// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721F.sol";
import "../contracts/token/ERC721/extensions/ERC721Payable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title MerkleRoot
 *
 * @dev Example implementation of [ERC721F] with MerkleRoot validation for whitelisted accounts that can take part in the pre-sale
 */
contract MerkleRoot is ERC721F, ERC721Payable {
    uint256 public constant MAX_TOKENS = 10000;
    uint public constant MAX_PURCHASE = 31;
    uint public tokenPrice = 1 ether;
    bool public preSaleIsActive;
    bool public saleIsActive;
    bytes32 public root;

    constructor(bytes32 _root) ERC721F("MerkleRoot Pre-Sale", "Merkle") {
        root = _root;
    }

    modifier validMintRequest(uint256 numberOfTokens) {
        require(numberOfTokens != 0, "numberOfNfts cannot be 0");
        require(
            numberOfTokens < MAX_PURCHASE,
            "Can only mint 30 tokens at a time"
        );
        require(
            tokenPrice * numberOfTokens <= msg.value,
            "Ether value sent is not correct"
        );
        _;
    }

    function setRoot(bytes32 _root) external onlyOwner {
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
     * @dev If saleIsActive becomes `true` sets preSaleIsActive to `false`
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
    function mint(uint256 numberOfTokens)
        external
        payable
        validMintRequest(numberOfTokens)
    {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        require(saleIsActive, "Sale NOT active yet");
        uint256 supply = totalSupply();
        require(
            supply + numberOfTokens <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );

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
     * @dev Uses MerkleProof to determine whether an address is allowed to mint during the pre-sale, non-mint name is due to hardhat being unable to handle function overloading
     */
    function mintPreSale(uint256 numberOfTokens, bytes32[] calldata merkleProof)
        external
        payable
        validMintRequest(numberOfTokens)
    {
        require(preSaleIsActive, "PreSale is not active yet");
        uint256 supply = totalSupply();
        require(
            supply + numberOfTokens <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );
        require(checkValidity(merkleProof), "Invalid Merkle Proof");

        for (uint256 i; i < numberOfTokens; ) {
            _safeMint(msg.sender, supply + i);
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

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficient balance");
        _withdraw(owner(), balance);
    }
}
