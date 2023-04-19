// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../contracts/token/ERC721/ERC721F.sol";

interface WarmInterface {
    function ownerOf(
        address contractAddress,
        uint256 tokenId
    ) external view returns (address);
}

interface DelegateCashInterface {
    function checkDelegateForToken(
        address delegate,
        address vault,
        address contract_,
        uint256 tokenId
    ) external view returns (bool);
}

error ZeroAddressCheck();

/**
 * @title ERC721FVerify - check for token ownership via contract, warm wallet and delegate cash
 * Based on https://etherscan.io/address/0xba5a9e9cbce12c70224446c24c111132becf9f1d#code
 * Warm Wallet https://github.com/wenewlabs/public/tree/main/HotWalletProxy
 * Delegate.cash https://github.com/delegatecash/delegation-registry
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
     * @notice verify contract token based claim using warm wallet and delegate cash
     * @param tokenContract the smart contract address of the token
     * @param tokenId the tokenId
     */
    function verifyTokenOwner(
        address tokenContract,
        uint256 tokenId
    ) internal view returns (bool) {
        address tokenOwner = ERC721F(tokenContract).ownerOf(tokenId);

        // 1. check contract token owner
        // 2. check warm wallet delegation - ownerOf()
        //      all delegation
        //      is a mapping of token owner's wallet to hot wallet
        //      coldWalletToHotWallet[owner].walletAddress
        // 3. check delegate.cash delegation - checkDelegateForToken()
        //      checks three forms of delegation all, contract, and contract/token id
        return (msg.sender == tokenOwner ||
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
            ));
    }
}
