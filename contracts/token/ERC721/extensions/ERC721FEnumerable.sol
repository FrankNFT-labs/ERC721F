// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../ERC721F.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

abstract contract ERC721FEnumerable is ERC721F, IERC721Enumerable {
    function totalSupply() public view override(ERC721F, IERC721Enumerable) returns (uint256) {
        return ERC721F.totalSupply();
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {

    }

    function tokenByIndex(uint256 index) external view returns(uint256) {

    }
}