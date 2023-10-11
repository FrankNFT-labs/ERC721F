// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

/**
 * @title Payable
 * @notice This abstract contract provides a simple and secure way to handle Ether payments and withdrawals.
 * It allows the contract to receive Ether and provides an internal function for derived contracts to withdraw Ether.
 */
abstract contract Payable {
    /**
     * Helper method to allow ETH withdraws.
     */
    function _withdraw(address _address, uint256 _amount) internal {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Failed to withdraw Ether");
    }

    // contract can recieve Ether
    // solhint-disable-next-line ordering
    receive() external payable {}
}
