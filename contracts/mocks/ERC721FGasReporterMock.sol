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
}