// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AddressUtils
 * @dev A collection of utility functions related to the address type.
 * @author FrankNFT.eth
 */
library AddressUtils {
    /**
     * @notice Checks if the provided address is a contract.
     * !!!! It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract !!!!
     * @dev This function checks the size of the code at the given address.
     * @param _address The address to check.
     * @return bool Returns true if the address is a contract, false otherwise.
     */
    function _isContract(address _address) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }
}
