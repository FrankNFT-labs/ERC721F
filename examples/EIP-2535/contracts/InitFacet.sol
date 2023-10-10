// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import {IDiamondLoupe} from "hardhat-deploy/solc_0.8/diamond/interfaces/IDiamondLoupe.sol";
import {IERC173} from "hardhat-deploy/solc_0.8/diamond/interfaces/IERC173.sol";
import {IERC165, IERC721, IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {UsingDiamondOwner, IDiamondCut} from "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";
import {ERC721FStorage} from "./ERC721F/ERC721FStorage.sol";
import {WithStorage} from "./WithStorage.sol";

/**
 * @dev Contract is utilised to setup initial values and registration of all interfaces utilised by the Diamond supportsInterface
 */
contract InitFacet is UsingDiamondOwner, WithStorage {
    function init() external onlyOwner {
        if (s().isInitialized) return;

        f()._name = "FreeMint";
        f()._symbol = "FM";
        f()
            ._baseTokenURI = "ipfs://QmVy7VQUFtTQawBsp4tbJPp9MgbTKS4L7WSDpZEdZUzsiD/";

        s().MAX_TOKENS = 10000;
        s().MAX_PURCHASE = 31;

        ds().supportedInterfaces[type(IERC165).interfaceId] = true;
        ds().supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds().supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds().supportedInterfaces[type(IERC173).interfaceId] = true;
        ds().supportedInterfaces[type(IERC721).interfaceId] = true;
        ds().supportedInterfaces[type(IERC721Metadata).interfaceId] = true;

        s().isInitialized = true;
    }

    function f() internal pure returns (ERC721FStorage.Layout storage) {
        return ERC721FStorage.layout();
    }
}
