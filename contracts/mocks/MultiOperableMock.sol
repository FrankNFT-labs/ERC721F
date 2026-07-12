// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../utils/MultiOperable.sol";

/**
 * @title MultiOperableMock
 * @dev Mock exposing an onlyOperators-gated function for testing purposes
 */
contract MultiOperableMock is MultiOperable {
    uint256 public operatorActionCount;

    constructor() Ownable(msg.sender) {}

    function operatorAction() external onlyOperators {
        operatorActionCount++;
    }
}
