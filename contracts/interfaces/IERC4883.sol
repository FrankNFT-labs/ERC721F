// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

interface IERC4883 is IERC165 {
    function renderTokenById(uint256 id) external view returns (string memory);
}