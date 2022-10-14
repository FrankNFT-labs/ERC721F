// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../token/soulbound/Soulbound.sol";

contract SoulboundMock is Soulbound {
    constructor(string memory name, string memory symbol)
        Soulbound(name, symbol)
    {}

    function mint(address to, string memory uri) public {
        _mint(to, uri);
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}