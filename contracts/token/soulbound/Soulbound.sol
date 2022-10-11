// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Soulbound is ERC721, ERC721URIStorage, Ownable {
    uint256 _tokenSupply;
    uint256 _burnCounter;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
    }

    function _mint(address to, string memory uri) internal virtual onlyOwner {
        _mint(to, _tokenSupply);
        _setTokenURI(_tokenSupply, uri);
        unchecked {
            _tokenSupply++;
        }
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) onlyOwner {
        super._burn(tokenId);
        unchecked {
            _burnCounter++;
        }
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual override onlyOwner {
        super._transfer(from, to, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract.
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view virtual returns (uint256) {
        return _tokenSupply - _burnCounter;
    }
}