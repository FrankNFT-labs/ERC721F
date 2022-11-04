// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract AllowListWithAmount is Ownable {
    mapping(address => uint256) private allowList;

    modifier onlyAllowListWithSufficientAvailableTokens(
        uint256 numberOfTokens
    ) {
        require(
            numberOfTokens <= allowList[msg.sender],
            "Address does not have sufficient tokens available within allowList"
        );
        _;
    }

    /**
     * @notice Adds an address to the allowList and sets `totalTokens` as their token amount
     */
    function allowAddress(address _address, uint256 totalTokens)
        public
        onlyOwner
    {
        allowList[_address] = totalTokens;
    }

    /**
     * @notice Adds an array of addresses to the allowList and sets `totalTokens` as their token amount
     */
    function allowAddresses(address[] calldata _addresses, uint256 totalTokens)
        external
        onlyOwner
    {
        uint length = _addresses.length;
        for (uint i; i < length; ) {
            allowAddress(_addresses[i], totalTokens);
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Removes an address off the allowList
     */
    function disallowAddress(address _address) public onlyOwner {
        _disallowAddress(_address);
    }

    /**
     * @dev Available tokens of `_address` get set to 0
     */
    function _disallowAddress(address _address) internal {
        delete allowList[_address];
    }

    /**
     * @notice Returns total available amount of tokens an address has
     */
    function getAllowListFunds(address _address) public view returns (uint256) {
        return allowList[_address];
    }

    /**
     * @dev Decreases the total available tokens by a certain amount, defaults to 0 when `totalDecrease` is larger or equal to total availableTokens of `_address`
     */
    function decreaseAddressAvailableTokens(
        address _address,
        uint256 totalDecrease
    ) internal {
        if (totalDecrease >= allowList[_address]) {
            allowList[_address] = 0;
        } else {
            allowList[_address] = allowList[_address] - totalDecrease;
        }
    }
}
