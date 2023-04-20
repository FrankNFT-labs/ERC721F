// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../interfaces/DelegateCashInterface.sol";
import "../interfaces/WarmInterface.sol";

/**
 * @title Verify
 * Based on https://etherscan.io/address/0xba5a9e9cbce12c70224446c24c111132becf9f1d#code
 * Warm Wallet https://github.com/wenewlabs/public/tree/main/HotWalletProxy
 * Delegate.cash https://github.com/delegatecash/delegation-registry
 * @dev Contract used to interact with Warm Wallet and Delegate Cash for permission checks
 */
contract Verify {
    address public immutable WARM_WALLET_CONTRACT;
    address public immutable DELEGATE_CASH_CONTRACT;

    error ZeroAddressCheck();

    constructor(address _warmWalletContract, address _delegateCashContract) {
        if (
            _warmWalletContract == address(0) ||
            _delegateCashContract == address(0)
        ) revert ZeroAddressCheck();
        WARM_WALLET_CONTRACT = _warmWalletContract;
        DELEGATE_CASH_CONTRACT = _delegateCashContract;
    }

    /**
     * @notice Returns whether coldWallet of `msg.sender` contains any tokens in `tokenContract`
     */
    function hasTokens(address tokenContract) internal view returns (bool) {
        return
            WarmInterface(WARM_WALLET_CONTRACT).balanceOf(
                tokenContract,
                msg.sender
            ) > 0;
    }

    /**
     * @notice Returns whether `msg.sender` is delegate in `tokenContract` on behalf of `vault`
     */
    function isDelegateInContractForVault(
        address tokenContract,
        address vault
    ) internal view returns (bool) {
        return
            DelegateCashInterface(DELEGATE_CASH_CONTRACT)
                .checkDelegateForContract(msg.sender, vault, tokenContract);
    }
}
