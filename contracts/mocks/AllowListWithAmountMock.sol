// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../utils/AllowListWithAmount.sol";

contract AllowListWithAmountMock is AllowListWithAmount {
    constructor() Ownable(msg.sender) {}

    function consumeTokens(
        uint256 numberOfTokens
    ) external onlyAllowListWithSufficientAvailableTokens(numberOfTokens) {
        decreaseAddressAvailableTokens(msg.sender, numberOfTokens);
    }
}
