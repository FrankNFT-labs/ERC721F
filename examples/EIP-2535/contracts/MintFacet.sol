// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import {ERC721FUpgradeableInternal} from "./ERC721F/ERC721FUpgradeableInternal.sol";
import {FreeMintStorage, WithStorage} from "./WithStorage.sol";

/**
 * @dev Facet which adds external mint function
 */
contract MintFacet is ERC721FUpgradeableInternal, WithStorage {
    function mint(uint256 numberOfTokens) external {
        FreeMintStorage storage freeMintStorage = s();

        require(msg.sender == tx.origin, "NO Contracts allowed");
        require(freeMintStorage.saleIsActive, "Sale NOT active yet");
        require(numberOfTokens > 0, "numberOfNfts cannot be 0");
        require(
            numberOfTokens < freeMintStorage.MAX_PURCHASE,
            "Can only mint 30 tokens at a time"
        );
        uint256 supply = _totalMinted();
        require(
            supply + numberOfTokens <= freeMintStorage.MAX_TOKENS,
            "Purchase would exceed max supply of Tokens"
        );
        unchecked {
            for (uint256 i; i < numberOfTokens; ) {
                _mint(msg.sender, supply + i); // no need to use safeMint as we don't allow contracts.
                i++;
            }
        }
    }
}
