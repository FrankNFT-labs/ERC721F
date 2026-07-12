// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../utils/Operable.sol";

/**
 * @title OperableMock
 * @dev Mock exposing an onlyOperator-gated function for testing purposes
 */
contract OperableMock is Operable {
    uint256 public operatorActionCount;

    constructor() Ownable(msg.sender) {}

    function operatorAction() external onlyOperator {
        operatorActionCount++;
    }
}
