// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

interface IERC4883 is IERC165 {
    function renderTokenById(uint256 id) external view returns (string memory);
}