// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./utils/Operatable.sol";

contract Soulbound is ERC721, ERC721URIStorage, Operatable {
    uint256 _tokenSupply;
    uint256 _burnCounter;

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {}

    /**
     * @dev Only a `spender` with `OPERATOR_ROLE` or approved for `tokenId` passes
     */
    modifier onlyOperatorOrApproved(address spender, uint256 tokenId) {
        if (getApproved(tokenId) != spender) {
            if (!checkOperator(spender)) revert("Neither operator of contract nor approved address");
        }
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Approve `to` to have transfer- and burnperms of `tokenId` 
     */
    function approve(address to, uint256 tokenId) public virtual override onlyOperator {
        _approve(to, tokenId);
    }

    /**
     * @dev Mint function is only executable by operators who aree responsible for the uri provided and can decide for who the token is
     * @param to address which receives the mint
     * @param uri string in which the name, svg image, properties, etc are stored
     */
    function _mint(address to, string memory uri) internal virtual onlyOperator {
        _mint(to, _tokenSupply);
        _setTokenURI(_tokenSupply, uri);
        unchecked {
            _tokenSupply++;
        }
    }

    /**
     * @dev Burn function is only executable by operators of the contract or an approved address of `tokenId`, increases `_burnCounter` for proper functionality of totalSupply
     */
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
        onlyOperatorOrApproved(msg.sender, tokenId)
    {
        super._burn(tokenId);
        unchecked {
            _burnCounter++;
        }
    }

    /**
     * @notice Transfers `tokenId` from `from` to `to`
     * @dev Only executable by operators or an approved address of `tokenId`
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override onlyOperatorOrApproved(msg.sender, tokenId) {
        _transfer(from, to, tokenId);
    }

    /**
     * @notice Returns tokenURI of `tokenId`
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract, uses _burnCounter to take burned tokens into consideration
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view virtual returns (uint256) {
        return _tokenSupply - _burnCounter;
    }
}
