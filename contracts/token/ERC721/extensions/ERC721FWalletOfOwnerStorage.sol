// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../ERC721F.sol";

/**
 * @title ERC721FWalletOfOwnerStorage
 *
 * @dev Extension of ERC721F, which overrides default walletOfOwner functionality to utilise a mapping instead of looping through the token collection
 */
abstract contract ERC721FWalletOfOwnerStorage is ERC721F {
    mapping(address => uint256[]) private _walletOfOwner;

    /**
     * @dev walletOfOwner
     * @return tokens id owned by `_owner`
     */
    function walletOfOwner(
        address _owner
    ) public view virtual override returns (uint256[] memory) {
        return _walletOfOwner[_owner];
    }

    /**
     * @dev Minting: Pushes `tokenId` to _walletOfOwner of `to`
     * @dev Burning: Removes `tokenId` from wallet sender
     * @dev Transferring: Removes `tokenId` from wallet `from` and adds `tokenId` to wallet `to`
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = super._update(to, tokenId, auth);
        if (from == address(0)) {
            _walletOfOwner[to].push(tokenId);
        } else if (to == address(0)) {
            _removeTokenFromWallet(tokenId);
        } else {
            _removeTokenFromWallet(tokenId, from);
            _walletOfOwner[to].push(tokenId);
        }
        return from;
    }

    /**
     * @dev Copies last token from wallet of `sender` to the index where `tokenId` is at and pops last element. Removes `tokenId` from wallet
     */
    function _removeTokenFromWallet(uint256 tokenId) private {
        address owner = msg.sender;
        _removeTokenFromWallet(tokenId, owner);
    }

    /**
     * @dev Copies last token from wallet of `owner` to the index where `tokenId` is at and pops last element. Removes `tokenId` from wallet
     */
    function _removeTokenFromWallet(uint256 tokenId, address owner) private {
        uint length = _walletOfOwner[owner].length;
        for (uint i; i < length; ) {
            if (_walletOfOwner[owner][i] == tokenId) {
                _walletOfOwner[owner][i] = _walletOfOwner[owner][length - 1];
                _walletOfOwner[owner].pop();
                break;
            }
            unchecked {
                i++;
            }
        }
    }
}
