// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Soulbound is ERC721, ERC721URIStorage, Ownable {
    uint256 _tokenSupply;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
    }

    function _mint(address to, string memory uri) internal virtual onlyOwner {
        uint256 tokenId = _tokenSupply;
        unchecked {
            _tokenSupply++;
        }
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) onlyOwner {
        super._burn(tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual override onlyOwner {
        transferFrom(from, to, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}