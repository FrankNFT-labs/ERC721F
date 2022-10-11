// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../ERC721F.sol";

abstract contract walletOfOwnerStorage is ERC721F {
    mapping(address => uint256[]) _walletOfOwner;

    function walletOfOwner(address _owner) external view virtual override returns (uint256[] memory) {
        return _walletOfOwner[_owner];
    }

    function _mint(address to, uint256 tokenId) internal virtual override {
        _walletOfOwner[to].push(tokenId);
        super._mint(to, tokenId);
    }
}