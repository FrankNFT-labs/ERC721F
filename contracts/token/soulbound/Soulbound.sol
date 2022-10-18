// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Soulbound is ERC721, ERC721URIStorage, Ownable {
    uint256 _tokenSupply;
    uint256 _burnCounter;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => bool) ownerIsAllowedToBurn;

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {}

    /**
     * @dev Only a `spender` that is the owner of the contract or approved for `tokenId`/owner of `tokenId` passes
     */
    modifier onlyOwnerOrApproved(address spender, uint256 tokenId) {
        address ownerToken = ERC721.ownerOf(tokenId);
        require(
            spender == owner() ||
                isApprovedForAll(ownerToken, spender) ||
                getApproved(tokenId) == spender,
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
        _mint(to, _tokenSupply);
        _setTokenURI(_tokenSupply, uri);
        unchecked {
            _tokenSupply++;
        }
    }

    /**
     * @dev Burn function is only executable by the owner of the contract or approved addresses, increases `_burnCounter` for proper functionality of totalSupply
     */
    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721, ERC721URIStorage)
        onlyOwnerOrApproved(msg.sender, tokenId)
    {
        super._burn(tokenId);
        unchecked {
            _burnCounter++;
        }
    }
    
    function allowBurn(uint256 tokenId, bool allowed) public onlyOwnerOrApproved(msg.sender, tokenId) {
        
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

    /**
     * @dev Gets the total amount of existing tokens stored by the contract, uses _burnCounter to take burned tokens into consideration
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view virtual returns (uint256) {
        return _tokenSupply - _burnCounter;
    }

    /**
     * @dev Gets total amount of tokens minted by the contract
     */
    function _totalMinted() internal view virtual returns (uint256) {
        return _tokenSupply;
    }

    /**
     * @dev Gets total amount of burned tokens
     */
    function _totalBurned() internal view virtual returns (uint256) {
        return _burnCounter;
    }
}
