// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../utils/AddressUtils.sol";

/**
 * @title AddressUtilsMock
 * @dev Mock exposing the internal functions of the AddressUtils library for testing purposes
 */
contract AddressUtilsMock {
    function calculateAddress(
        string memory publicKey
    ) external pure returns (address) {
        return AddressUtils.calculateAddress(publicKey);
    }
}
