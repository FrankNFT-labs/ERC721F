// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../ERC721F.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

abstract contract ERC721FEnumerable is ERC721F, IERC721Enumerable {
    function totalSupply() public view override(ERC721F, IERC721Enumerable) returns (uint256) {
        return ERC721F.totalSupply();
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        require(index < balanceOf(owner));
        uint256 totalMinted = totalSupply();
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

    function tokenByIndex(uint256 index) external view returns(uint256) {

    }
}