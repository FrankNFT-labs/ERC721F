// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import {LibDiamond} from "hardhat-deploy/solc_0.8/diamond/libraries/LibDiamond.sol";

struct FreeMintStorage {
    // solhint-disable-next-line var-name-mixedcase
    uint256 MAX_TOKENS;
    // solhint-disable-next-line var-name-mixedcase
    uint256 MAX_PURCHASE;
    bool isInitialized;
    bool saleIsActive;
}

/**
 * @dev Contract is utilised to setup the function s to allow access to FreeMintStorage variables and contains mandatory DiamondStorage initialization
 */
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
