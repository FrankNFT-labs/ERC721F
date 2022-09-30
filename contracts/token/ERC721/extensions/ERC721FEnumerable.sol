// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../ERC721F.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

abstract contract ERC721FEnumerable is ERC721F, IERC721Enumerable {

    /**
     * @dev See {IERC721Enumerable-totalSupply}
     * Returns total amount of tokens stored in the contract
     */
    function totalSupply() public view override(ERC721F, IERC721Enumerable) returns (uint256) {
        return ERC721F.totalSupply();
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}
     * Returns token ID owned by `owner` at a given `index` of its token list
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        require(index < balanceOf(owner), "Index out of bounds for owned tokens");
        uint256 totalMinted = ERC721FEnumerable.totalSupply();
        uint256 currentTokenId = _startTokenId();
        uint256 ownedTokenIndex = 0;

        while (ownedTokenIndex <= index && currentTokenId < totalMinted) {
            if (ownerOf(currentTokenId) == owner) {
                if (currentTokenId == index) return currentTokenId;
                unchecked {
                    ownedTokenIndex++;
                }
            }
            unchecked {
                currentTokenId++;
            }
        }  
        revert();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}
     * Returns a token ID at a given `index` of all the tokens stored by the contract 
     */
    function tokenByIndex(uint256 index) external view returns(uint256) {
        uint256 totalMinted = ERC721FEnumerable.totalSupply();
        require(index < totalMinted, "Index out of bounds for total minted tokens");
        uint256 currentTokenIndex = _startTokenId();

        while(currentTokenIndex < totalMinted) {
            if(currentTokenIndex == index) return currentTokenIndex;
            unchecked {
                currentTokenIndex++;
            }
        }
        revert();
    }
}