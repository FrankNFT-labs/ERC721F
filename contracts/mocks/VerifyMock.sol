// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../utils/Verify.sol";

/**
 * @title VerifyMock
 * @dev Mock exposing the internal verifyTokenOwner function for testing purposes
 */
contract VerifyMock is Verify {
    constructor(
        address warmWalletContract,
        address delegateCashContract
    ) Verify(warmWalletContract, delegateCashContract) {}

    function verify(
        address tokenContract,
        uint256 tokenId
    ) external view returns (bool) {
        return verifyTokenOwner(tokenContract, tokenId);
    }
}

/**
 * @title WarmWalletStubMock
 * @dev Minimal Warm Wallet stand-in; only implements the ownerOf lookup used
 * by Verify, returning a configurable hot wallet address
 */
contract WarmWalletStubMock {
    address private _hotWalletOwner;

    function setOwner(address hotWalletOwner) external {
        _hotWalletOwner = hotWalletOwner;
    }

    function ownerOf(address, uint256) external view returns (address) {
        return _hotWalletOwner;
    }
}

/**
 * @title DelegateCashStubMock
 * @dev Minimal Delegate Cash stand-in; only implements the token-level
 * delegation check used by Verify, returning a configurable flag
 */
contract DelegateCashStubMock {
    bool private _delegated;

    function setDelegated(bool delegated) external {
        _delegated = delegated;
    }

    function checkDelegateForToken(
        address,
        address,
        address,
        uint256
    ) external view returns (bool) {
        return _delegated;
    }
}
