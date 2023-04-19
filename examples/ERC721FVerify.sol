// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;
import "@franknft.eth/erc721-f/contracts/token/ERC721/ERC721F.sol";

interface WarmInterface {
    function balanceOf(
        address contractAddress,
        address owner
    ) external view returns (uint256);
}

interface DelegateCashInterface {
    function checkDelegateForContract(
        address delegate,
        address vault,
        address contract_
    ) external view returns (bool);
}

error ZeroAddressCheck();

/**
 * @title ERC721FVerify
 * Based on https://etherscan.io/address/0xba5a9e9cbce12c70224446c24c111132becf9f1d#code
 * Warm Wallet https://github.com/wenewlabs/public/tree/main/HotWalletProxy
 * Delegate.cash https://github.com/delegatecash/delegation-registry
 * @dev Contract used to interact with Warm Wallet and Delegate Cash for permission checks
 */
contract ERC721FVerify {
    address public immutable WARM_WALLET_CONTRACT;
    address public immutable DELEGATE_CASH_CONTRACT;

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
}
