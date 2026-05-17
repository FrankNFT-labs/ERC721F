// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ERC721F
 * @notice Gas-optimised ERC-721 implementation that replaces ERC721Enumerable while
 *         preserving the most-used enumeration helpers: `totalSupply()` and `walletOfOwner()`.
 *
 * @dev Key design decisions vs OpenZeppelin ERC721Enumerable:
 *
 *  1. **No per-token index arrays** — ERC721Enumerable keeps three mappings
 *     (`_allTokens`, `_allTokensIndex`, `_ownedTokens`) that each require an SSTORE
 *     on every mint.  ERC721F replaces all of that with a single monotonic counter
 *     (`_tokenSupply`), cutting mint cost by 36–77 % depending on batch size.
 *
 *  2. **Linear scan instead of random access** — `walletOfOwner` iterates the full
 *     minted range off-chain; it cannot be called on-chain at scale.  This is an
 *     intentional tradeoff: the savings on every mint outweigh the cost of the
 *     occasional off-chain scan.
 *
 *  3. **Two counters, not one** — Keeping separate `_tokenSupply` (minted) and
 *     `_burnCounter` (burned) makes `totalSupply()` a single subtraction with no
 *     extra branches, and makes both raw values available to child contracts via
 *     `_totalMinted()` / `_totalBurned()`.
 *
 * @author @FrankNFT.eth
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
     * @notice Stores the IPFS / HTTPS prefix prepended to every `tokenId` to build
     *         the token's metadata URI.
     *
     * @dev A single SSTORE per call.  Setting the URI after deploy is intentional:
     *      many projects reveal metadata in a separate transaction once minting is
     *      complete ("reveal"), so the base URI can start empty and be updated once.
     */
    function setBaseTokenURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    /**
     * @notice Returns the number of tokens that currently exist (minted minus burned).
     *
     * @dev Uses two monotonic counters instead of an enumerable array.
     *      ERC721Enumerable maintains `_allTokens[]` which grows with every mint and
     *      requires an SSTORE per element.  Here a single subtraction replaces that
     *      entire array, costing one SLOAD each.
     *
     * @return uint256 Live token count (minted - burned).
     */
    function totalSupply() public view virtual returns (uint256) {
        return _tokenSupply - _burnCounter;
    }

    /**
     * @notice OZ ERC-721 hook called on every token state change (mint, transfer, burn).
     *
     * @dev This is the single insertion point for supply accounting.
     *      - **Mint** (`from == address(0)`): increments `_tokenSupply` — one SSTORE.
     *      - **Burn** (`to   == address(0)`): increments `_burnCounter` — one SSTORE.
     *      - **Transfer**: no counter update needed.
     *
     *      Compare to ERC721Enumerable which executes up to 3 SSTOREs per mint
     *      (_allTokens push, _allTokensIndex set, _ownedTokens set).  Eliminating
     *      those is the primary source of ERC721F's gas savings.
     *
     * @param to    Recipient address (zero for burns).
     * @param tokenId Token being minted / transferred / burned.
     * @param auth  Address authorised to trigger the transfer (checked by OZ base).
     * @return from Previous owner address (zero for mints).
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
     * @notice Returns the first token ID issued by this contract.
     *
     * @dev Defaults to 0.  Override to use 1-based IDs (common in NFT projects):
     *
     *      ```solidity
     *      function _startTokenId() internal pure override returns (uint256) {
     *          return 1;
     *      }
     *      ```
     *
     *      `walletOfOwner` and mint loops both call `_startTokenId()` so a single
     *      override propagates everywhere without further changes.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Returns the base URI used to construct each token's metadata URL.
     *      OZ's `tokenURI(id)` returns `baseURI + id.toString()` when this is non-empty.
     *      Storage is a single private string slot; reading it costs one SLOAD.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Returns the cumulative number of tokens minted, including any that were
     *      subsequently burned.  Useful for assigning sequential IDs at mint time:
     *      `uint256 tokenId = _totalMinted() + 1;`
     *
     *      Exposed separately from `totalSupply()` so child contracts can distinguish
     *      between "how many tokens exist now" and "how many were ever minted."
     */
    function _totalMinted() internal view virtual returns (uint256) {
        return _tokenSupply;
    }

    /**
     * @dev Returns the cumulative number of tokens that have been burned.
     *      Together with `_totalMinted()` this gives child contracts full insight into
     *      supply history without maintaining additional state.
     */
    function _totalBurned() internal view virtual returns (uint256) {
        return _burnCounter;
    }

    /**
     * @dev Returns whether `tokenId` has been minted and not yet burned.
     *
     * @dev OpenZeppelin 5.x removed the public `_exists` helper in favour of checking
     *      `_ownerOf` directly.  ERC721F re-exposes it as an internal function because
     *      many extension contracts (e.g. ERC721FCOMMON's `royaltyInfo`) need a concise
     *      existence check.  Retaining the familiar name also reduces confusion for
     *      developers migrating from OZ 4.x.
     *
     * Tokens start existing when they are minted and stop existing when they are burned.
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
