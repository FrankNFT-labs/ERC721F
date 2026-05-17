// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../utils/AllowList.sol";

contract AllowListMock is AllowList {
    constructor() Ownable(msg.sender) {}
}
