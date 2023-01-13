// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

contract RequireNonZero {
    function requireLargerThanZero(uint256 value) public pure {
        require(value > 0, "Value must be larger than 0");
    }

    function requireNotEqualsZero(uint256 value) public pure {
        require(value != 0, "Value, can't be 0");
    }
}
