// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../token/ERC721/ERC721FCOMMON.sol";

/**
 * @title ERC721FCOMMONMock
 * @dev Mock for testing ERC721FCOMMON — provides a public mint function.
 */
contract ERC721FCOMMONMock is ERC721FCOMMON {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721FCOMMON(name_, symbol_, msg.sender) {}

    function mint(uint256 numberOfTokens) public {
        uint256 supply = _totalMinted();
        for (uint256 i; i < numberOfTokens; ) {
            _mint(msg.sender, supply + i);
            unchecked {
                i++;
            }
        }
    }

    function withdraw(address to, uint256 amount) public onlyOwner {
        _withdraw(to, amount);
    }
}
