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

    function mint(address to, uint256 numberOfTokens) public {
        uint256 supply = totalSupply();
        for(uint256 i; i < numberOfTokens;){
            _mint( to, supply + i );
            unchecked{ i++;}
        }
    }

    function safeMint(address to, uint256 numberOfTokens) public {
        uint256 supply = totalSupply();
        for(uint256 i; i < numberOfTokens;){
            _safeMint( to, supply + i );
            unchecked{ i++;}
        }
    }
}