// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import {FreeMintStorage, WithStorage} from "./WithStorage.sol";
import {UsingDiamondOwner} from "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

/**
 * @dev Facet which adds control of storage saleIsActive variable through external function
 */
contract SaleControl is WithStorage, UsingDiamondOwner {
    function flipSaleState() external onlyOwner {
        FreeMintStorage storage freeMintStorage = s();
        freeMintStorage.saleIsActive = !freeMintStorage.saleIsActive;
    }
}
