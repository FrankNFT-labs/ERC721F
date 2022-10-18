// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721FCOMMON.sol";

/**
 * @title FreeMint
 *
 * @dev Example implementation of [ERC721F]
 */



contract FreeMint is ERC721FCOMMON {
    mapping(uint256 => uint256) public offers;
    mapping(address => uint256) private _sellerBalance;

    uint256 public constant MAX_TOKENS = 10000;
    uint public constant MAX_PURCHASE = 31; // Theoretical limit 1100
    bool public saleIsActive;

    constructor() ERC721FCOMMON("FreeMint", "Free") {
        setBaseTokenURI(
            "ipfs://QmVy7VQUFtTQawBsp4tbJPp9MgbTKS4L7WSDpZEdZUzsiD/"
        );
    }

    /**
     * Changes the state of saleIsActive from true to false and false to true
     */
    function flipSaleState() external onlyOwner {
        saleIsActive = !saleIsActive;
    }

    /**
     * Mint your tokens here.
     */
    function mint(uint256 numberOfTokens) external {
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
        for (uint256 i; i < numberOfTokens; ) {
            _mint(msg.sender, supply + i); // no need to use safeMint as we don't allow contracts.
            unchecked {
                i++;
            }
        }
    }

    function sellToken(uint256 tokenId, uint256 priceInWei) public {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        require(ownerOf(tokenId) == msg.sender, "Not the tokenowner");
        require(priceInWei > 0, "token price must be larger than 0");
        offers[tokenId] = priceInWei;
    }

    function buyToken(uint256 tokenId) public payable {
        uint256 tokenPrice = offers[tokenId];
        uint256 buyPrice = msg.value;
        require(tokenPrice > 0, "Token is not for sale");
        require(buyPrice >= tokenPrice, "Insufficient funds");

        address tokenOwner = ownerOf(tokenId);
        (address royaltyReceiver, uint256 royaltyAmount) = royaltyInfo(tokenId, buyPrice);

        delete offers[tokenId];

        _sellerBalance[royaltyReceiver] = royaltyAmount;
        _sellerBalance[tokenOwner] = buyPrice - royaltyAmount;

        _transfer(tokenOwner, msg.sender, tokenId);
    }

    function sellerBalance(address seller) public view returns (uint256) {
        return _sellerBalance[seller];
    }
}
