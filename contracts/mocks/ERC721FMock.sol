// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../token/ERC721/ERC721F.sol";

/**
 * @title ERC721FMock
 * This mock provides public helper functions for testing purposes
 */
contract ERC721FMock is ERC721F {
    constructor(string memory name_, string memory symbol_)
        ERC721F(name_, symbol_)
    {}

    /**
     * @notice Mint your tokens here
     * @dev Function utilised in testing, don't use in production due to lack of restrictions
     */
    function mint(uint256 numberOfTokens) public {
        uint256 supply = _totalMinted();
        for (uint256 i; i < numberOfTokens; ) {
            _mint(msg.sender, supply + i);
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Burns `tokenId`
     */
    function burn(uint256 tokenId) public {
        _burnERC721F(tokenId);
    }

    /**
     * @dev Helper function for testing of internal function _totalMinted
     */
    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    /**
     * @dev Helper function for testing of internal function _totalBurned
     */
    function totalBurned() public view returns (uint256) {
        return _totalBurned();
    }
}
