// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../ERC721/ERC721F.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Soulbound is ERC721F, ERC721URIStorage {
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    bool private _tokenHolderIsAllowedToBurn;

    constructor(string memory name_, string memory symbol_)
        ERC721F(name_, symbol_)
    {}

    /**
     * @dev Only a `spender` that is the owner of the contract or approved for `tokenId`/owner of `tokenId` passes
     */
    modifier onlyOwnerOrApproved(address spender, uint256 tokenId) {
        address ownerToken = ERC721.ownerOf(tokenId);
        require(
            isOwnerOrApproved(spender, tokenId),
            "Address is neither owner of contract nor approved for token/tokenowner"
        );
        _;
    }

    /**
     * @notice Approve `to` to have transfer- and burnperms of `tokenId`
     */
    function approve(address to, uint256 tokenId)
        public
        virtual
        override
        onlyOwner
    {
        _approve(to, tokenId);
    }

    /**
     * @notice Give transfer- and burnperms to `operator` for all tokens owned by `owner`
     */
    function setApprovalForAllOwner(
        address owner,
        address operator,
        bool approved
    ) public virtual onlyOwner {
        _setApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual override {
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address, bool)
        public
        virtual
        override
        onlyOwner
    {
        revert("Use setApprovalForAllOwner");
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Mint function is only executable by the owner of the contract or approved addresses who are responsible for the uri provided and can decide for who the token is
     * @param to address which receives the mint
     * @param uri string in which the name, svg image, properties, etc are stored
     */
    function _mint(address to, string memory uri) internal virtual onlyOwner {
        uint256 tokenSupply = _totalMinted();
        _mint(to, tokenSupply);
        _setTokenURI(tokenSupply, uri);
    }

    /**
     * @dev Burn function is only executable by the owner of the contract or approved addresses, increases `_burnCounter` for proper functionality of totalSupply
     */
    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721F, ERC721URIStorage)
    {
        if (
            !isOwnerOrApproved(msg.sender, tokenId) &&
            !(ownerOf(tokenId) == msg.sender && _tokenHolderIsAllowedToBurn)
        )
            revert(
                "Caller is neither tokenholder which is allowed to burn nor owner of contract nor approved address for token/tokenOwner"
            );
        ERC721F._burn(tokenId);
    }

    /**
     * @notice Returns whether an address is the owner of the contract or is approved for a specific `tokenId` or has overal approval for the holder of `tokenId`
     */
    function isOwnerOrApproved(address spender, uint256 tokenId)
        public
        view
        returns (bool)
    {
        address ownerToken = ERC721.ownerOf(tokenId);
        return
            spender == owner() ||
            isApprovedForAll(ownerToken, spender) ||
            getApproved(tokenId) == spender;
    }

    /**
     * @notice Allows whether the contract token holders can burn their tokens
     * @dev Only executable by the owner of the contract
     */
    function allowBurn(bool allowed) public onlyOwner {
        _tokenHolderIsAllowedToBurn = allowed;
    }

    /**
     * @notice Returns whether all token holders are allowed to burn tokens
     */
    function tokenHolderIsAllowedToBurn() public view returns (bool) {
        return _tokenHolderIsAllowedToBurn;
    }

    /**
     * @notice Transfers `tokenId` from `from` to `to`
     * @dev Only executable by owner or approved addresses
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override onlyOwnerOrApproved(msg.sender, tokenId) {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     * @dev Only executable by owner or approved addresses
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override onlyOwnerOrApproved(msg.sender, tokenId) {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     * @dev Only executable by owner or approved addresses
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override onlyOwnerOrApproved(msg.sender, tokenId) {
        _safeTransfer(from, to, tokenId, data);
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

    function _baseURI() internal view virtual override(ERC721, ERC721F) returns (string memory) {
        return ERC721F._baseURI();
    }

    function _mint(address to, uint256 tokenId) internal virtual override(ERC721, ERC721F) {
        ERC721F._mint(to, tokenId);
    }
}
