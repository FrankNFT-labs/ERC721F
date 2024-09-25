// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AllowList
 * @dev This contract provides functionality for managing an allow list of addresses.
 * It extends the Ownable contract from OpenZeppelin, allowing only the owner to modify the allow list.
 *
 * The contract includes functions to:
 * - Add single or multiple addresses to the allow list
 * - Remove addresses from the allow list
 * - Check if an address is on the allow list
 *
 * It also provides a modifier `onlyAllowList` that can be used to restrict function access
 * to only addresses on the allow list.
 *
 * @notice This contract is useful for implementing access control mechanisms where certain
 * operations should be restricted to a pre-approved set of addresses.
 *
 * @author @FrankNFT.eth
 */

abstract contract AllowList is Ownable {
    mapping(address => bool) private allowList;

    modifier onlyAllowList() {
        require(isAllowList(msg.sender), "Address is not within allowList");
        _;
    }

    /**
     * @notice Adds an array of addresses to the allowList
     */
    function allowAddresses(address[] calldata _addresses) external onlyOwner {
        uint256 length = _addresses.length;
        for (uint256 i; i < length; ) {
            allowAddress(_addresses[i]);
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
     * @notice Adds an address to the allowList
     */
    function allowAddress(address _address) public onlyOwner {
        allowList[_address] = true;
    }

    /**
     * @notice Returns `true` if `_address` is in and `true` in the allowList
     */
    function isAllowList(address _address) public view returns (bool) {
        return allowList[_address];
    }

    /**
     * @dev Sets `_address` to `false` in allowList
     */
    function _disallowAddress(address _address) internal {
        delete allowList[_address];
    }
}
