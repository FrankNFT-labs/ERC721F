// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../ERC721F.sol";

/**
 * @title ERC721FWalletOfOwnerStorage
 *
 * @dev Extension of ERC721F, which overrides default walletOfOwner functionality to utilise a mapping instead of looping through the token collection
 */
abstract contract ERC721FWalletOfOwnerStorage is ERC721F {
    mapping(address => uint256[]) _walletOfOwner;

    /**
     * @dev walletOfOwner
     * @return tokens id owned by `_owner`
     */
    function walletOfOwner(address _owner)
        external
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
    function _mint(address to, uint256 tokenId) internal virtual override {
        super._mint(to, tokenId);
        _walletOfOwner[to].push(tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual override {
        super._transfer(from, to, tokenId);
        removeTokenIdFromWallet(tokenId);
        _walletOfOwner[to].push(tokenId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        removeTokenIdFromWallet(tokenId);
    }

    function removeTokenIdFromWallet(uint256 tokenId) internal {
        address owner = msg.sender;
        require(ownerOf(tokenId) == owner);
        uint length = _walletOfOwner[owner].length - 1;
        bool encountedId = false;
        for (uint i; i < length; ) {
            if (_walletOfOwner[owner][i] == tokenId) encountedId = true;
            if (encountedId) _walletOfOwner[owner][i] = _walletOfOwner[owner][i + 1];
            unchecked {
                i++;
            }
        }
        _walletOfOwner[owner].pop();
    }
}