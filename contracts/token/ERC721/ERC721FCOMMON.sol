// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "./ERC721F.sol";
import "../../utils/Payable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

/**
 * @title ERC721FCOMMON
 * @notice Ready-to-use NFT base contract that bundles gas-optimised minting (ERC721F),
 *         on-chain royalty info (ERC-2981), and ETH withdrawal helpers (Payable).
 *
 * @dev Composition rationale — why three parents instead of one:
 *
 *  - **ERC721F** handles the token ledger and supply accounting.
 *  - **ERC2981** stores royalty configuration and satisfies marketplace queries via
 *    `royaltyInfo()`.  It is a thin, well-audited OZ module; reimplementing it would
 *    only introduce risk.
 *  - **Payable** provides `_withdraw()` (internal helper) and a `receive()` fallback so
 *    the contract can accept ETH.  Child contracts are expected to expose their own
 *    `withdraw()` function with the signature appropriate for their use case, calling
 *    `_withdraw()` internally.  Kept separate so projects that do not accept payment
 *    can use ERC721F directly without the extra surface area.
 *
 *  Child contracts typically only need to add a `mint()` function on top of this base.
 *
 * @author @FrankNFT.eth
 */

contract ERC721FCOMMON is ERC721F, Payable, ERC2981 {
    /**
     * @dev Royalty percentage stored as basis points (1 % = 100 bp).
     *      Basis points are the standard unit used by ERC-2981's `royaltyInfo()`
     *      denominator of 10 000.  A `uint16` is sufficient (max 65 535 bp = 655 %)
     *      and wastes no storage compared to a larger type.
     *      Default: 500 bp = 5 %.
     */
    uint16 private royalties = 500;
    address private royaltyReceiver;

    event ROYALTIESUPDATED(uint256 royalties);

    error RoyaltiesTooHigh();
    error RoyaltyInfoForNonexistentToken();
    error RoyaltyReceiverIsZeroAddress();

    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner
    ) ERC721F(name_, symbol_, initialOwner) {
        setRoyaltyReceiver(initialOwner);
    }

    /**
     * @notice Sets the royalty percentage charged on secondary sales.
     *
     * @dev The input `_royalties` is a plain percentage (0–89).  It is multiplied by
     *      100 before storage so the internal value is already in basis points, ready
     *      for ERC-2981's formula: `royaltyAmount = salePrice * royalties / 10_000`.
     *
     *      Example: `setRoyalties(5)` stores 500 bp → 5 % royalty on every sale.
     *
     *      Values >= 90 % are rejected as economically nonsensical and to protect
     *      buyers from accidental misconfiguration.
     *
     * @param _royalties Royalty percentage as a whole number (0–89 inclusive).
     *                   Pass 0 to disable royalties entirely.
     */
    function setRoyalties(uint16 _royalties) public onlyOwner {
        if (_royalties >= 90) revert RoyaltiesTooHigh();

        royalties = (_royalties * 100);

        emit ROYALTIESUPDATED(_royalties);
    }

    /**
     * @notice Sets `receiver` as royaltyReceiver. Reverts if receiver is the zero address.
     */
    function setRoyaltyReceiver(address receiver) public virtual onlyOwner {
        if (receiver == address(0)) revert RoyaltyReceiverIsZeroAddress();
        royaltyReceiver = receiver;
    }

    /**
     * @notice Returns true if this contract implements the interface identified by `_interfaceId`.
     *
     * @dev EIP-165 multi-inheritance resolution.  Both ERC721 and ERC2981 implement
     *      `supportsInterface`, so Solidity requires an explicit override to resolve the
     *      ambiguity.  The check for `IERC2981` is added manually before delegating to
     *      `super`, which walks the C3-linearised MRO (ERC721F → ERC721 → ERC2981).
     *      This ensures marketplaces querying for `0x2a55205a` (ERC-2981) get `true`.
     *
     * @return `true` if the contract implements `_interfaceId`, `false` otherwise.
     */
    function supportsInterface(
        bytes4 _interfaceId
    ) public view virtual override(ERC721, ERC2981) returns (bool) {
        return
            _interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    /**
     * @notice Returns the royalty recipient and amount for a given sale price (ERC-2981).
     *
     * @dev The `_exists` guard is intentional: querying royalty info for a burned or
     *      never-minted token is likely a caller error, and reverting early prevents
     *      marketplaces from quoting royalties on invalid tokens.  OZ's default
     *      ERC2981 implementation does not check existence; the revert here is a
     *      deliberate strictness increase.
     *
     *      Calculation: `royaltyAmount = _salePrice * royalties / 10_000`
     *      where `royalties` is already stored in basis points.
     *
     * @param _tokenId   The token being sold — must exist.
     * @param _salePrice Sale price in any currency unit; royalty is expressed in the same unit.
     * @return receiver      Address that should receive the royalty payment.
     * @return royaltyAmount Amount to pay, denominated in the same unit as `_salePrice`.
     */
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    )
        public
        view
        virtual
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        if (!_exists(_tokenId)) revert RoyaltyInfoForNonexistentToken();
        return (royaltyReceiver, (_salePrice * royalties) / 10000);
    }
}
