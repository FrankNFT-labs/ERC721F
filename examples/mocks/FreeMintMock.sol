// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../FreeMint.sol";

/**
 * @title FreeMintMock
 *
 * @dev Contract utilised to test variations of functions of FreeMint and compare their gas consumption
 */
contract FreeMintMock is FreeMint {
    /**
     * @dev Variation of mint function where numberOfTokens must be larger than 0
     */
    function mintRequireNumberOfTokensLargerThanZero(
        uint256 numberOfTokens
    ) external {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        require(saleIsActive, "Sale NOT active yet");
        require(numberOfTokens > 0, "numberOfNfts must be larger than 0");
        require(
            numberOfTokens < MAX_PURCHASE,
            "Can only mint 30 tokens at a time"
        );
        uint256 supply = _totalMinted();
        require(
            supply + numberOfTokens <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );
        unchecked {
            for (uint256 i; i < numberOfTokens; ) {
                _mintERC721F(msg.sender, supply + i); // no need to use safeMint as we don't allow contracts.
                i++;
            }
        }
    }

    /**
     * @dev variation of mint function where numberOfTokens can't be zero
     */
    function mintRequireNumberOfTokensNotEqualsZero(
        uint256 numberOfTokens
    ) external {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        require(saleIsActive, "Sale NOT active yet");
        require(numberOfTokens != 0, "numberOfNfts cannot be 0");
        require(
            numberOfTokens < MAX_PURCHASE,
            "Can only mint 30 tokens at a time"
        );
        uint256 supply = _totalMinted();
        require(
            supply + numberOfTokens <= MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );
        unchecked {
            for (uint256 i; i < numberOfTokens; ) {
                _mintERC721F(msg.sender, supply + i); // no need to use safeMint as we don't allow contracts.
                i++;
            }
        }
    }
}
