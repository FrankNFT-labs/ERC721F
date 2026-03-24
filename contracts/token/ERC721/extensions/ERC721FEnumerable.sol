// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../ERC721F.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/**
 * @title ERC721FEnumerable
 * @dev This contract extends ERC721F to implement the IERC721Enumerable interface.
 * It provides functions to enumerate over all tokens and tokens owned by a specific address.
 *
 * @notice This implementation uses O(n) time complexity for enumeration operations,
 * where n is the total supply of tokens. This may become inefficient for large collections.
 * Consider using alternative data structures for better performance in such cases.
 *
 * @author @FrankNFT.eth
 */

abstract contract ERC721FEnumerable is ERC721F, IERC721Enumerable {
    error OwnerIndexOutOfBounds();
    error TotalIndexOutOfBounds();
    error UnexpectedEnumerationState();

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}
     * Returns token ID owned by `owner` at a given `index` of its token list
     * This read function is O(totalSupply). If calling from a seperate contract, be sure to test gas first
     * It may also degrade with extremely large collection sizes (e.g >> 10000), test for your use case
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view returns (uint256) {
        if (index >= balanceOf(owner)) revert OwnerIndexOutOfBounds();
        uint256 currentTokenIndex = _startTokenId();
        uint256 endTokenId = currentTokenIndex + _totalMinted();
        uint256 ownedTokenIndex = 0;

        // Counter overflow is impossible as the loop breaks when
        // currentTokenIndex reaches endTokenId.
        unchecked {
            for (; currentTokenIndex < endTokenId; currentTokenIndex++) {
                if (_ownerOf(currentTokenIndex) == owner) {
                    if (ownedTokenIndex == index) {
                        return currentTokenIndex;
                    }
                    ownedTokenIndex++;
                }
            }
        }

        // Execution should never reach this point.
        revert UnexpectedEnumerationState();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}
     * Returns a token ID at a given `index` of all the tokens stored by the contract
     * This read function is O(totalSupply). If calling from a seperate contract, be sure to test gas first
     * It may also degrade with extremely large collection sizes (e.g >> 10000), test for your use case
     */
    function tokenByIndex(uint256 index) external view returns (uint256) {
        uint256 totalMinted = ERC721FEnumerable.totalSupply();
        if (index >= totalMinted) revert TotalIndexOutOfBounds();
        uint256 currentTokenIndex;

        // Counter overflow is impossible as the loop breaks when
        // uint256 i is equal to another uint256 totalMinted.
        unchecked {
            for (uint256 i; i < totalMinted; i++) {
                if (currentTokenIndex == index) {
                    return i;
                }
                currentTokenIndex++;
            }
        }
        revert UnexpectedEnumerationState();
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}
     * Returns total amount of tokens stored in the contract
     */
    function totalSupply()
        public
        view
        override(ERC721F, IERC721Enumerable)
        returns (uint256)
    {
        return ERC721F.totalSupply();
    }
}
