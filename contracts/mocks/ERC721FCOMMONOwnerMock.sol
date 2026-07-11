// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../token/ERC721/ERC721FCOMMON.sol";

/**
 * @title ERC721FCOMMONOwnerMock
 * @dev Mock for testing ERC721FCOMMON with a configurable `initialOwner`,
 * so deployment on behalf of a third party (e.g. a multisig) can be exercised.
 */
contract ERC721FCOMMONOwnerMock is ERC721FCOMMON {
    constructor(
        address initialOwner
    ) ERC721FCOMMON("Test", "TST", initialOwner) {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}
