// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../contracts/utils/AllowList.sol";
import "../contracts/token/ERC721/ERC721FCOMMON.sol";
import "operator-filter-registry/src/RevokableDefaultOperatorFilterer.sol";
import "operator-filter-registry/src/UpdatableOperatorFilterer.sol";

contract RevokableDefaultOperatorFiltererERC721F is ERC721FCOMMON, AllowList, RevokableDefaultOperatorFilterer {
    
}
