// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

interface DelegateCashInterface {
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        TOKEN
    }

    struct DelegationInfo {
        DelegationType type_;
        address vault;
        address delegate;
        address contract_;
        uint256 tokenId;
    }

    struct ContractDelegation {
        address contract_;
        address delegate;
    }

    struct TokenDelegation {
        address contract_;
        uint256 tokenId;
        address delegate;
    }

    function delegateForAll(address delegate, bool value) external;

    function delegateForContract(
        address delegate,
        address contract_,
        bool value
    ) external;

    function delegateForToken(
        address delegate,
        address contract_,
        uint256 tokenId,
        bool value
    ) external;

    function revokeAllDelegates() external;

    function revokeDelegate(address delegate) external;

    function revokeSelf(address vault) external;

    function getDelegationsByDelegate(
        address delegate
    ) external view returns (DelegationInfo[] memory);

    function getDelegatesForAll(
        address vault
    ) external view returns (address[] memory);

    function getDelegatesForContract(
        address vault,
        address contract_
    ) external view returns (address[] memory);

    function getDelegatesForToken(
        address vault,
        address contract_,
        uint256 tokenId
    ) external view returns (address[] memory);

    function getContractLevelDelegations(
        address vault
    ) external view returns (ContractDelegation[] memory delegations);

    function getTokenLevelDelegations(
        address vault
    ) external view returns (TokenDelegation[] memory delegations);

    function checkDelegateForAll(
        address delegate,
        address vault
    ) external view returns (bool);

    function checkDelegateForContract(
        address delegate,
        address vault,
        address contract_
    ) external view returns (bool);

    function checkDelegateForToken(
        address delegate,
        address vault,
        address contract_,
        uint256 tokenId
    ) external view returns (bool);
}
