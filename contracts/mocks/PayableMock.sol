// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../utils/Payable.sol";

/**
 * @title PayableMock
 * @dev Exposes Payable's internal _withdraw for testing purposes.
 *      Also exposes a helper to force a failed ETH transfer for error-path coverage.
 */
contract PayableMock is Payable {
    /**
     * @notice Public wrapper around _withdraw for test access.
     */
    function withdraw(address to, uint256 amount) external {
        _withdraw(to, amount);
    }
}

/**
 * @title RejectEtherMock
 * @dev A contract that always reverts on receive — used to trigger EtherWithdrawFailed.
 */
contract RejectEtherMock {
    receive() external payable {
        revert("rejected");
    }
}
