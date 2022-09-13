// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import '../token/ERC721/ERC721F.sol';

/**
 * @title ERC721FGasReporterMock
 * @dev Extends ERC721
 * Contains massmint and -transfer methods to test gasconsumption of ERC721F.
 */

contract ERC721FGasReporterMock is ERC721F {
    constructor(string memory name_, string memory symbol_) ERC721F(name_, symbol_) {
    }

    /**
     * @notice Mints a single token
     */
    mintOne(address to) public {
        mint(to, 1)
    }

    /**
     * @notice Mints ten tokens
     */
    mintTen(address to) public {
        mint(to, 10);
    }

    /**
     * @notice Mints a hundred tokens
     */
    mintHundred(address to) public {
        mint(to, 100);
    }

    /**
     * Mints any number of tokens and transfers them to `to`
     */
    function mint(address to, uint256 numberOfTokens) external {
        uint256 supply = totalSupply();
        for (uint256 i = 0; i < numberOfTokens) {
            _mint(msg.sender, supply + i);
            unchecked {i++}
        }
    }
}