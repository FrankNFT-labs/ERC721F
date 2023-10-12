// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

/**
 * @title RequireNonZero
 *
 * @dev Contract to test gas consumption of require non-zero value statements
 */
contract RequireNonZero {
    function requireLargerThanZero(uint256 value) public pure {
        require(value > 0, "Value must be larger than 0");
    }

    function requireNotEqualsZero(uint256 value) public pure {
        require(value != 0, "Value, can't be 0");
    }
}
