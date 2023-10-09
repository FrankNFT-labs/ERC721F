// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../ERC721/ERC721F.sol";
import "../../interfaces/IERC5192.sol";
import "../../interfaces/IERC6454.sol";

contract Soulbound is IERC5192, IERC6454, ERC721F {
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => bool) private _unlockedTokens;
    bool private _tokenHolderIsAllowedToBurn;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721F(name_, symbol_) {}

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
     * @dev Only a `tokenId` which is transferable passes
     */
    modifier onlyTransferable(
        uint256 tokenId,
        address from,
        address to
    ) {
        require(
            isTransferable(tokenId, from, to),
            "Token can't be transferred"
        );
        _;
    }

    /**
     * @notice Indicates whether this contract supports an interface
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * @return `true` if the contract implements `interfaceID` or either is 0xb45a3c0e or 0x91a6262f, `false` otherwise
     */
    function supportsInterface(
        bytes4 _interfaceId
    ) public view virtual override returns (bool) {
        return
            _interfaceId == type(IERC5192).interfaceId ||
            _interfaceId == type(IERC6454).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    /**
     * @notice Approve `to` to have transfer- and burnperms of `tokenId`
     */
    function approve(
        address to,
        uint256 tokenId
    ) public virtual override onlyOwner {
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
    function setApprovalForAll(
        address operator,
        bool approved
    ) public virtual override onlyOwner {
        _setApprovalForAll(owner(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Mint function is only executable by the owner of the contract
     */
    function _mint(
        address to,
        uint256 tokenId
    )
        internal
        virtual
        override
        onlyOwner
        onlyTransferable(tokenId, address(0), to)
    {
        super._mint(to, tokenId);
        _unlockedStatus(tokenId, false);
    }

    /**
     * @dev Burn function is only executable on unlocked tokens by the owner of the contract or approved addresses, increases `_burnCounter` for proper functionality of totalSupply
     */
    function _burn(
        uint256 tokenId
    )
        internal
        virtual
        override
        onlyTransferable(tokenId, ownerOf(tokenId), address(0))
    {
        super._burn(tokenId);
    }

    /**
     * @notice Returns the locking status of a Soulbound Token
     * @dev SBTs assigned to zero address are considered invalid, and queries about them do throw
     * @param tokenId The identifier for an SBT
     */
    function locked(uint256 tokenId) external view returns (bool) {
        require(_exists(tokenId), "Token is owned by zero address");
        return !_unlockedTokens[tokenId];
    }

    /**
     * @notice Sets the unlockedState of `tokenId` to `_unlocked`
     */
    function unlockedStatus(
        uint256 tokenId,
        bool _unlocked
    ) external onlyOwner {
        _unlockedStatus(tokenId, _unlocked);
    }

    /**
     * @dev Sets the unlockedState of `tokenId` to `_unlocked`, `tokenId` must exist
     */
    function _unlockedStatus(uint256 tokenId, bool _unlocked) internal {
        require(_exists(tokenId), "Token has yet to be minted");
        _unlockedTokens[tokenId] = _unlocked;
        if (_unlocked) {
            emit Unlocked(tokenId);
        } else {
            emit Locked(tokenId);
        }
    }

    /**
     * @notice Returns whether an address is the owner of the contract or is approved for a specific `tokenId` or has overal approval for the holder of `tokenId`
     */
    function isOwnerOrApproved(
        address spender,
        uint256 tokenId
    ) public view returns (bool) {
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
     * @notice Returns whether a token is transferable
     * @dev See {IERC6454-isTransferable}
     * @dev Will revert if `tokenId` does not exist
     */
    function isTransferable(
        uint256 tokenId,
        address from,
        address to
    ) public view virtual returns (bool) {
        bool fromIsZeroAddress = from == address(0);
        bool toIsZeroAddress = to == address(0);
        if (!(fromIsZeroAddress && !toIsZeroAddress) && !_exists(tokenId)) {
            revert("Token does not exist");
        }
        if (fromIsZeroAddress && !toIsZeroAddress) {
            return true;
        } else if (!fromIsZeroAddress && toIsZeroAddress) {
            return
                _unlockedTokens[tokenId] &&
                ((msg.sender == ownerOf(tokenId) &&
                    _tokenHolderIsAllowedToBurn) ||
                    isOwnerOrApproved(msg.sender, tokenId));
        } else {
            return _unlockedTokens[tokenId];
        }
    }

    /**
     * @notice Transfers `tokenId` from `from` to `to` and locks `tokenId`
     * @dev Only executable on unlocked tokens by owner or approved addresses
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        virtual
        override
        onlyTransferable(tokenId, from, to)
        onlyOwnerOrApproved(msg.sender, tokenId)
    {
        _transfer(from, to, tokenId);
        _unlockedStatus(tokenId, false);
    }

    /**
     * @dev See {IERC721-safeTransferFrom} and locks `tokenId`
     * @dev Only executable on unlocked tokens by owner or approved addresses
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    )
        public
        virtual
        override
        onlyTransferable(tokenId, from, to)
        onlyOwnerOrApproved(msg.sender, tokenId)
    {
        _safeTransfer(from, to, tokenId, data);
        _unlockedStatus(tokenId, false);
    }
}
