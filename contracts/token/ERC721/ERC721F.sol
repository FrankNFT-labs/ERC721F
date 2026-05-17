// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ERC721F
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation.
 * Optimized to no longer use ERC721Enumerable , but still provide a totalSupply() and walletOfOwner(address _owner) implementation.
 * @author @FrankNFT.eth
 *
 */

contract ERC721F is Ownable, ERC721 {
    uint256 private _tokenSupply;
    uint256 private _burnCounter;

    // Base URI for Meta data
    string private _baseTokenURI;

    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner
    ) ERC721(name_, symbol_) Ownable(initialOwner) {}

    /**
     * @notice Returns all token IDs currently owned by `_owner`.
     *
     * @dev OFF-CHAIN / VIEW USE ONLY.
     * This function is O(totalMinted) — it performs a full linear scan over every token ID
     * that has ever been minted, regardless of how many are still owned by `_owner`.
     *
     * Safe usage:
     *  - Frontend / dapp queries via `eth_call` (no gas cost to the caller).
     *  - Off-chain indexers or scripts.
     *
     * Unsafe usage — do NOT call from another contract on-chain:
     *  - At 10 000 tokens the scan costs roughly 20 000 000 gas, which exceeds the block gas
     *    limit and will revert.
     *  - Even at smaller supply sizes an on-chain call wastes significant gas with no benefit,
     *    since the result is not verifiable by the calling contract anyway.
     *
     * If you need on-chain enumeration, inherit ERC721FEnumerable instead, or track token IDs
     * in your own minting logic.
     *
     * @return tokens Array of token IDs owned by `_owner` at the time of the call.
     */
    function walletOfOwner(
        address _owner
    ) external view virtual returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = _startTokenId();
        uint256 ownedTokenIndex = 0;
        uint256 endTokenId = currentTokenId + _tokenSupply;

        unchecked {
            for (;;) {
                if (ownedTokenIndex >= ownerTokenCount) {
                    break;
                }
                if (currentTokenId >= endTokenId) {
                    break;
                }
                if (_ownerOf(currentTokenId) == _owner) {
                    ownedTokenIds[ownedTokenIndex] = currentTokenId;
                    ownedTokenIndex++;
                }
                currentTokenId++;
            }
        }
        return ownedTokenIds;
    }

    /**
     * @dev Set the base token URI
     */
    function setBaseTokenURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    /**
     * @dev Gets the total amount of existing tokens stored by the contract.
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view virtual returns (uint256) {
        return _tokenSupply - _burnCounter;
    }

    /**
     * @dev Minting: Increases _tokenSupply
     * @dev Burning:  Increases _burnCounter
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = super._update(to, tokenId, auth);
        if (from == address(0)) {
            _tokenSupply++;
        } else if (to == address(0)) {
            _burnCounter++;
        }
        return from;
    }

    /**
     * To change the starting tokenId, override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
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

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
