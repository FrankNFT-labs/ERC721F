// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/token/ERC721/ERC721F.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

/**
 * @title FreeMint
 *
 * @dev Example implementation of [ERC721F] and [ERC2981]
 */
contract FreeMint is ERC721F, ERC2981 {
    uint16 private royalties = 500;

    uint256 public constant MAX_TOKENS = 10000;
    uint public constant MAX_PURCHASE = 31; // Theoretical limit 1100
    bool public saleIsActive;

    event RoyaltiesUpdated(uint256 royalties);

    constructor() ERC721F("FreeMint", "Free") {
        setBaseTokenURI(
            "ipfs://QmVy7VQUFtTQawBsp4tbJPp9MgbTKS4L7WSDpZEdZUzsiD/"
        );
    }

    /**
     * @notice Indicates whether this contract supports an interface
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * @return `true` if the contract implements `interfaceID` or is 0x2a55205a, `false` otherwise
     */
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return
            _interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    /**
     * @dev it will update the royalties for token
     * @param _royalties is new percentage of royalties. It should be more than 0 and least 90
     */
    function setRoyalties(uint16 _royalties) external onlyOwner {
        require(
            _royalties != 0 && _royalties < 90,
            "royalties should be between 0 and 90"
        );

        royalties = (_royalties * 100);

        emit RoyaltiesUpdated(_royalties);
    }

    /**
     * @notice Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     * @param _tokenId is the token being sold and should exist.
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        public
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        require(
            _exists(_tokenId),
            "ERC2981RoyaltyStandard: Royalty info for nonexistent token"
        );
        return (owner(), (_salePrice * royalties) / 10000);
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
}
