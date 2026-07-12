// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AllowListWithAmount
 * @dev This contract manages an allowList of addresses and their respective token amounts, providing utility functions to add, remove, and modify these amounts.
 * It also implements a custom modifier to ensure that only addresses with a sufficient amount of available tokens can perform certain actions.
 * The contract is Ownable, allowing only the contract owner to manage the allowList.
 */
abstract contract AllowListWithAmount is Ownable {
    mapping(address => uint256) private allowList;

    error InsufficientAllowListTokens();

    modifier onlyAllowListWithSufficientAvailableTokens(uint256 numberOfTokens)
    {
        if (numberOfTokens > allowList[msg.sender]) {
            revert InsufficientAllowListTokens();
        }
        _;
    }

    /**
     * @notice Adds an array of addresses to the allowList and sets `totalTokens` as their token amount
     */
    function allowAddresses(
        address[] calldata _addresses,
        uint256 totalTokens
    ) external onlyOwner {
        uint256 length = _addresses.length;
        for (uint256 i; i < length; ) {
            // The internal variant skips the redundant onlyOwner check that
            // the public allowAddress would re-run on every iteration.
            _allowAddress(_addresses[i], totalTokens);
            unchecked {
                i++;
            }
        }
    }

    /**
     * @notice Removes an address off the allowList
     */
    function disallowAddress(address _address) external onlyOwner {
        _disallowAddress(_address);
    }

    /**
     * @notice Adds an address to the allowList and sets `totalTokens` as their token amount
     */
    function allowAddress(
        address _address,
        uint256 totalTokens
    ) public onlyOwner {
        _allowAddress(_address, totalTokens);
    }

    /**
     * @notice Returns total available amount of tokens an address has
     */
    function getAllowListFunds(address _address) public view returns (uint256) {
        return allowList[_address];
    }

    /**
     * @dev Sets `totalTokens` as the token amount of `_address` in the allowList
     */
    function _allowAddress(address _address, uint256 totalTokens) internal {
        allowList[_address] = totalTokens;
    }

    /**
     * @dev Available tokens of `_address` get set to 0
     */
    function _disallowAddress(address _address) internal {
        delete allowList[_address];
    }

    /**
     * @dev Decreases the total available tokens by a certain amount, defaults to 0 when `totalDecrease` is larger or equal to total availableTokens of `_address`
     */
    function decreaseAddressAvailableTokens(
        address _address,
        uint256 totalDecrease
    ) internal {
        // Cache the current amount so the slot is read once instead of twice.
        uint256 availableTokens = allowList[_address];
        if (totalDecrease >= availableTokens) {
            allowList[_address] = 0;
        } else {
            unchecked {
                // Cannot underflow: totalDecrease < availableTokens.
                allowList[_address] = availableTokens - totalDecrease;
            }
        }
    }
}
