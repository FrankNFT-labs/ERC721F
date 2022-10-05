// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract AllowList is Ownable {
    mapping(address => bool) allowList;

    modifier onlyAllowList() {
        require(isAllowList(msg.sender), "Address is not within allowList");
        _;
    }

    function allowAddress(address _address) public onlyOwner {
        allowList[_address] = true;
    }

    function allowAddresses(address[] calldata _addresses) external onlyOwner {
        uint length = _addresses.length;
        for (uint i; i < length; ) {
            allowAddress(_addresses[i]);
            unchecked {
                i++;
            }
        }
    }

    function disallowAddress(address _address) public onlyOwner {
        allowList[_address] = false;
    }

    function isAllowList(address _address) public view returns (bool) {
        return allowList[_address];
    }
}
