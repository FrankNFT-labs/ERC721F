// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../ERC721/ERC721F.sol";
import "../../interfaces/IERC5192.sol";
import "../../interfaces/IERC6454.sol";

/**
 * @title Soulbound
 * @dev Implementation of a soulbound token, which is a non-transferable ERC721 token.
 * This contract implements the IERC5192 and IERC6454 interfaces for locked tokens and transfer validation.
 * It extends the ERC721F contract to provide additional functionality specific to soulbound tokens.
 *
 * Key features:
 * - Tokens are non-transferable by default (locked)
 * - Owner can set individual tokens to be unlocked
 * - Owner can transfer or burn locked tokens directly (equivalent to
 *   unlocking first, but in a single transaction)
 * - Implements ERC5192 for querying locked status
 * - Implements ERC6454 for transfer validation
 * - Optionally allows token holders to burn their own tokens
 *
 * @notice This contract creates non-transferable tokens that can be selectively unlocked by the contract owner.
 * It's suitable for use cases where tokens represent non-transferable rights, credentials, or identities.
 *
 * @author @FrankNFT.eth
 */

contract Soulbound is IERC5192, IERC6454, ERC721F {
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => bool) private _unlockedTokens;
    bool private _tokenHolderIsAllowedToBurn;

    error NotOwnerOrApproved();
    error TokenNotTransferable();
    error TokenOwnedByZeroAddress();
    error TokenDoesNotExist();
    error TokenNotMinted();

    /**
     * @dev Only a `spender` that is the owner of the contract or approved for `tokenId`/owner of `tokenId` passes
     */
    modifier onlyOwnerOrApproved(address spender, uint256 tokenId) {
        if (!isOwnerOrApproved(spender, tokenId)) revert NotOwnerOrApproved();
        _;
    }

    /**
     * @dev Only a `tokenId` which is transferable passes
     */
    modifier onlyTransferable(uint256 tokenId, address from, address to) {
        if (!isTransferable(tokenId, from, to)) revert TokenNotTransferable();
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner
    ) ERC721F(name_, symbol_, initialOwner) {}

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
     * @notice Returns the locking status of a Soulbound Token
     * @dev SBTs assigned to zero address are considered invalid, and queries about them do throw
     * @param tokenId The identifier for an SBT
     */
    function locked(uint256 tokenId) external view returns (bool) {
        if (!_exists(tokenId)) revert TokenOwnedByZeroAddress();
        return !_unlockedTokens[tokenId];
    }

    /**
     * @notice Approve `to` to have transfer- and burnperms of `tokenId`
     */
    function approve(
        address to,
        uint256 tokenId
    ) public virtual override onlyOwner {
        _approve(to, tokenId, address(0));
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
     * @notice Allows whether the contract token holders can burn their tokens
     * @dev Only executable by the owner of the contract
     */
    function allowBurn(bool allowed) public onlyOwner {
        _tokenHolderIsAllowedToBurn = allowed;
    }

    /**
     * @notice Transfers `tokenId` from `from` to `to` and locks `tokenId`
     * @dev Unlocked tokens: executable by the contract owner or approved
     * addresses. Locked tokens: only executable by the contract owner
     * @dev Transferability is enforced (and the token relocked) in {_update}
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override onlyOwnerOrApproved(msg.sender, tokenId) {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom} and locks `tokenId`
     * @dev Unlocked tokens: executable by the contract owner or approved
     * addresses. Locked tokens: only executable by the contract owner
     * @dev Transferability is enforced (and the token relocked) in {_update}
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
     * @notice Returns whether a token is transferable
     * @dev See {IERC6454-isTransferable}
     * @dev Will revert if `tokenId` does not exist
     * @dev The result depends on the caller: a locked token is only
     * transferable when queried by the contract owner
     */
    function isTransferable(
        uint256 tokenId,
        address from,
        address to
    ) public view virtual returns (bool) {
        if (!(from == address(0) && to != address(0)) && !_exists(tokenId)) {
            revert TokenDoesNotExist();
        }
        if (from != address(0) && to == address(0)) {
            // The burn permission check is based on the actual holder of the
            // token, regardless of the `from` supplied by the caller.
            from = ownerOf(tokenId);
        }
        return _isTransferable(tokenId, from, to);
    }

    /**
     * @dev Transferability check used by {_update}; `from` must be the actual
     * owner of `tokenId` (as it is inside `_update`), so no existence checks
     * or owner reads are repeated here.
     */
    function _isTransferable(
        uint256 tokenId,
        address from,
        address to
    ) internal view virtual returns (bool) {
        bool fromIsZeroAddress = from == address(0);
        bool toIsZeroAddress = to == address(0);
        if (fromIsZeroAddress && !toIsZeroAddress) {
            return true;
        }
        if (!_unlockedTokens[tokenId]) {
            // The contract owner can already move or burn a locked token by
            // unlocking it first (unlockedStatus is onlyOwner), so letting
            // the owner act directly adds no power — it only removes the
            // extra transaction.
            return msg.sender == owner();
        }
        if (!fromIsZeroAddress && toIsZeroAddress) {
            return
                (msg.sender == from && _tokenHolderIsAllowedToBurn) ||
                _isOwnerOrApproved(msg.sender, tokenId, from);
        }
        return true;
    }

    /**
     * @notice Returns whether an address is the owner of the contract or is approved for a specific `tokenId` or has overal approval for the holder of `tokenId`
     */
    function isOwnerOrApproved(
        address spender,
        uint256 tokenId
    ) public view returns (bool) {
        return _isOwnerOrApproved(spender, tokenId, ERC721.ownerOf(tokenId));
    }

    /**
     * @dev Approval check with the token owner supplied by the caller, so hot
     * paths that already loaded it avoid a repeated ownerOf read.
     */
    function _isOwnerOrApproved(
        address spender,
        uint256 tokenId,
        address tokenOwner
    ) internal view returns (bool) {
        return
            spender == owner() ||
            isApprovedForAll(tokenOwner, spender) ||
            getApproved(tokenId) == spender;
    }

    /**
     * @notice Returns whether all token holders are allowed to burn tokens
     */
    function tokenHolderIsAllowedToBurn() public view returns (bool) {
        return _tokenHolderIsAllowedToBurn;
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
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
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
     * @dev Minting: Can only be executed by owner contract, locks `tokenId`
     * @dev Burning: Clears the unlock flag so a re-minted `tokenId` starts locked
     * @dev Transferring: Requires an unlocked token, which relocks on arrival
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        if (from == address(0)) {
            _checkOwner();
        }
        if (!_isTransferable(tokenId, from, to)) revert TokenNotTransferable();
        super._update(to, tokenId, auth);
        if (to == address(0)) {
            delete _unlockedTokens[tokenId];
        } else if (from == address(0)) {
            // The flag is already false for a fresh mint and cleared on burn
            // for a re-mint, so emitting the ERC-5192 signal suffices.
            emit Locked(tokenId);
        } else if (_unlockedTokens[tokenId]) {
            _unlockedTokens[tokenId] = false;
            emit Locked(tokenId);
        }
        return from;
    }

    /**
     * @dev Sets the unlockedState of `tokenId` to `_unlocked`, `tokenId` must exist
     */
    function _unlockedStatus(uint256 tokenId, bool _unlocked) internal {
        if (!_exists(tokenId)) revert TokenNotMinted();
        _unlockedTokens[tokenId] = _unlocked;
        if (_unlocked) {
            emit Unlocked(tokenId);
        } else {
            emit Locked(tokenId);
        }
    }
}
