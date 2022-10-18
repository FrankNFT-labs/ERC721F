// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../token/ERC721/extensions/ERC721FEnumerable.sol";

/**
 * @title ERC721FEnumerableMock
 * This mock provides a public mint function for testing purposes
 */
contract ERC721FEnumerableMock is ERC721FEnumerable {
    constructor(string memory name, string memory symbol)
        ERC721F(name, symbol)
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
}
