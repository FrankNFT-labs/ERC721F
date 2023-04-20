// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

interface WarmInterface {
    struct WalletLink {
        address walletAddress;
        uint256 expirationTimestamp;
    }

    function version() external pure returns (string memory);

    function removeExpiredWalletLinks(address hotWalletAddress) external;

    function setHotWallet(
        address hotWalletAddress,
        uint256 expirationTimestamp,
        bool lockHotWalletAddress
    ) external;

    function renounceHotWallet() external;

    function getHotWallet(address coldWallet) external view returns (address);

    function getHotWalletLink(
        address coldWallet
    ) external view returns (WalletLink memory);

    function getColdWallets(
        address hotWallet
    ) external view returns (address[] memory);

    function isLocked(address hotWallet) external view returns (bool);

    function setLocked(bool locked) external;

    function setExpirationTimestamp(uint256 expirationTimestamp) external;

    function balanceOf(
        address contractAddress,
        address owner
    ) external view returns (uint256);

    function ownerOf(
        address contractAddress,
        uint256 tokenId
    ) external view returns (address);

    function balanceOfBatch(
        address contractAddress,
        address[] calldata owners,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    function balanceOf(
        address contractAddress,
        address owner,
        uint256 tokenId
    ) external view returns (uint256);
}
