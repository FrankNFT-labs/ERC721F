// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../ERC4906.sol";

/**
 * @title ERC4906Mock
 * @dev Mock contract utilised to provide public functions of ERC4906 for testing purposes
 */
contract ERC4906Mock is ERC4906 {
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        _setTokenURI(tokenId, _tokenURI);
    }

    function setTokenURIS(
        uint256 _fromTokenId,
        uint256 _toTokenId,
        string memory _tokenURI
    ) public {
        _setTokenURIS(_fromTokenId, _toTokenId, _tokenURI);
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    function totalBurned() public view returns (uint256) {
        return _totalBurned();
    }
}
