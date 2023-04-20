// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import {LibDiamond} from "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

contract WithStorage {
    function ds() internal pure returns (LibDiamond.DiamondStorage storage) {
        return LibDiamond.diamondStorage();
    }
}
