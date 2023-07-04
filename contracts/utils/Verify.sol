// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
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
     * @notice Verify contract token based claim using warm wallet and delegate cash
     * @param tokenContract the smart contract address of the token
     * @param tokenId the tokenId
     */
    function verifyTokenOwner(
        address tokenContract,
        uint256 tokenId
    ) internal view returns (bool) {
        address tokenOwner = IERC721(tokenContract).ownerOf(tokenId);

        return
            msg.sender == tokenOwner ||
            msg.sender ==
            WarmInterface(WARM_WALLET_CONTRACT).ownerOf(
                tokenContract,
                tokenId
            ) ||
            DelegateCashInterface(DELEGATE_CASH_CONTRACT).checkDelegateForToken(
                msg.sender,
                tokenOwner,
                tokenContract,
                tokenId
            );
    }
}
