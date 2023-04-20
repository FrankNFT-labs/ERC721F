// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import {LibDiamond} from "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

struct FreeMintStorage {
    uint256 MAX_TOKENS;
    uint MAX_PURCHASE;
    bool saleIsActive;
}

contract WithStorage {
    function s() internal pure returns (FreeMintStorage storage cs) {
        bytes32 position = keccak256("free.mint.nft.contract.storage");
        assembly {
            cs.slot := position
        }
    }

    function ds() internal pure returns (LibDiamond.DiamondStorage storage) {
        return LibDiamond.diamondStorage();
    }
}
