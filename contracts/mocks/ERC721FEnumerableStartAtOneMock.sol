// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../token/ERC721/extensions/ERC721FEnumerable.sol";

/**
 * @title ERC721FEnumerableStartAtOneMock
 * @dev Testing mock for ERC721FEnumerable with non-zero start token id.
 */
contract ERC721FEnumerableStartAtOneMock is ERC721FEnumerable {
    constructor(
        string memory name,
        string memory symbol
    ) ERC721F(name, symbol, msg.sender) {}

    function mint(uint256 numberOfTokens) public {
        uint256 supply = _totalMinted();
        uint256 startTokenId = _startTokenId();
        for (uint256 i; i < numberOfTokens; ) {
            _mint(msg.sender, startTokenId + supply + i);
            unchecked {
                i++;
            }
        }
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}
