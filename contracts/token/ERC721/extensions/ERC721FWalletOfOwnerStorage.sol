// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../ERC721F.sol";

/**
 * @title ERC721FWalletOfOwnerStorage
 *
 * @dev Extension of ERC721F, which overrides default walletOfOwner functionality to utilise a mapping instead of looping through the token collection
 */
abstract contract ERC721FWalletOfOwnerStorage is ERC721F {
    mapping(address => uint256[]) private _walletOfOwner;
    
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        _transferERC721FWalletOfOwnerStorage(from, to, tokenId);
    }

    /**
     * @dev walletOfOwner
     * @return tokens id owned by `_owner`
     */
    function walletOfOwner(address _owner)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        return _walletOfOwner[_owner];
    }

    /**
     * @dev Pushes `tokenId` to _walletOfOwner of `to`
     */
    function _mintERC721F(address to, uint256 tokenId) internal virtual override {
        super._mintERC721F(to, tokenId);
        _walletOfOwner[to].push(tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to` and pushes `tokenId` to wallet of `to`
     */
    function _transferERC721FWalletOfOwnerStorage(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        _transfer(from, to, tokenId);
        _removeTokenFromWallet(tokenId, from);
        _walletOfOwner[to].push(tokenId);
    }

    /**
     * @dev Burns `tokenId`
     */
    function _burnERC721F(uint256 tokenId) internal virtual override {
        super._burnERC721F(tokenId);
        _removeTokenFromWallet(tokenId);
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
