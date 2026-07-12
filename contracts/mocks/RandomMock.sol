// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../utils/Random.sol";

/**
 * @title RandomMock
 * @dev Mock exposing the internal random functions for testing purposes
 */
contract RandomMock is Random {
    function drawRandom() external returns (uint256) {
        return random();
    }

    function drawRandomWithSeed(uint256 seed) external returns (uint256) {
        return random(seed);
    }
}
