// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../token/ERC721/extensions/ERC721FWalletOfOwnerStorage.sol";

/**
 * @title ERC721FWalletOfOwnerStorageMock
 * This mock provides a public mint and burn function for testing purposes
 */
contract ERC721FWalletOfOwnerStorageMock is ERC721FWalletOfOwnerStorage {
    constructor(
        string memory name,
        string memory symbol
    ) ERC721F(name, symbol) {}

    /**
     * @notice Mint your tokens here
     * @dev Function utilised in testing, don't use in production due to lack of restrictions
     */
    function mint(uint256 numberOfTokens) public {
        uint256 supply = totalSupply();
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
        _burn(tokenId);
    }
}
