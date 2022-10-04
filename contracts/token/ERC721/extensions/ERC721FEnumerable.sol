// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../ERC721F.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

abstract contract ERC721FEnumerable is ERC721F, IERC721Enumerable {
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

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}
     * Returns token ID owned by `owner` at a given `index` of its token list
     * This read function is O(totalSupply). If calling from a seperate contract, be sure to test gas first
     * It may also degrade with extremely large collection sizes (e.g >> 10000), test for your use case
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256)
    {
        require(
            index < balanceOf(owner),
            "Index out of bounds for owned tokens"
        );
        uint256 totalMinted = ERC721FEnumerable.totalSupply();
        uint256 currentTokenIndex;
        uint256 ownedTokenIndex = 0;

        // Counter overflow is impossible as the loop breaks when
        // uint256 i is equal to another uint256 totalMinted.
        unchecked {
            for (uint256 i; i < totalMinted; i++) {
                if (ownerOf(currentTokenIndex) == owner) {
                    if (ownedTokenIndex == index) {
                        return i;
                    }
                    ownedTokenIndex++;
                }
                currentTokenIndex++;
            }
        }

        // Execution should never reach this point.
        revert();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}
     * Returns a token ID at a given `index` of all the tokens stored by the contract
     * This read function is O(totalSupply). If calling from a seperate contract, be sure to test gas first
     * It may also degrade with extremely large collection sizes (e.g >> 10000), test for your use case
     */
    function tokenByIndex(uint256 index) external view returns (uint256) {
        uint256 totalMinted = ERC721FEnumerable.totalSupply();
        require(
            index < totalMinted,
            "Index out of bounds for total minted tokens"
        );
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
        revert();
    }
}
