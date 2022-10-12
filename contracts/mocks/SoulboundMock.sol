// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../token/soulbound/Soulbound.sol";

contract SoulboundMock is Soulbound {
    constructor(string memory name, string memory symbol)
        Soulbound(name, symbol)
    {}
}