// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../token/ERC721/extensions/ERC721FEnumerable.sol";

/**
 * @title ERC721FEnumerableMock
 * This mock provides a public safeMint and mint functions for testing purposes
 */
contract ERC721FEnumerableMock is ERC721FEnumerable {
    string private _baseTokenURI;

    constructor(string memory name, string memory symbol) ERC721F(name, symbol) {}

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId, bytes memory _data) public {
        _safeMint(to, tokenId, _data);
    }
}