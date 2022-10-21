// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract AllowList is Ownable {
    mapping(address => uint256) private allowList;

    modifier onlyAllowListWithAvailableTokens() {
        require(getAllowListFunds(msg.sender) > 0, "Address does not have any tokens available within allowList");
        _;
    }

    function getAllowListFunds(address _address) public view returns (uint256) {
        return allowList[_address];
    }
}
