// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24 <0.9.0;

/**
 * @title BytesBuilder
 * @dev Append-only memory buffer. Caller allocates `new bytes(cap)` once and
 * threads a raw write pointer through the helpers; `finish` fixes the length.
 * Avoids the O(n^2) copying of repeated `bytes.concat` / `abi.encodePacked`.
 * Measured: 64 fragments appended in an accumulator loop cost 19.5k here
 * against ~112k for all three of `abi.encodePacked`, `bytes.concat` and
 * `string.concat`, crossing over at two fragments.
 *
 * The bigger everyday win is a different one. `wNum` and `wHex6` format
 * directly into the buffer, so a value never becomes an intermediate
 * allocation that is then copied again. One `<rect>` with four numbers and a
 * colour costs 5.2k here against 10.5k for a single `string.concat` over the
 * usual helpers, a shape that allocates once and so never pays the O(n^2)
 * penalty at all. For fragments that are already formatted, one `concat` call
 * ties with this library; reach for it when values need formatting, or when
 * fragments accumulate in a loop.
 *
 * Sizing `cap` is the caller's job: the write helpers do not bounds check,
 * so overrunning corrupts whatever was allocated next. `finish` reverts
 * with `BufferOverflow` when the pointer ends up outside the allocation,
 * which turns that corruption into a failed transaction instead of a
 * silently wrong result. Note that `wNum` can emit up to 78 bytes.
 * @author @FrankNFT.eth
 */
library BytesBuilder {
    /// @dev More bytes were written than the buffer was allocated to hold.
    /// @param written bytes the write pointer accounts for
    /// @param capacity bytes the buffer was allocated with
    error BufferOverflow(uint256 written, uint256 capacity);

    function start(
        uint256 cap
    ) internal pure returns (bytes memory out, uint256 ptr) {
        out = new bytes(cap);
        assembly ("memory-safe") {
            ptr := add(out, 0x20)
        }
    }

    /// @dev Stamps the written length onto `out`, rejecting a pointer that does
    ///      not sit inside the allocation. `out` still carries the capacity in
    ///      its length word at this point, which is what makes the check
    ///      possible without threading a limit through every write. A pointer
    ///      behind the data word wraps the subtraction to a huge value and is
    ///      caught by the same comparison.
    ///
    ///      This detects an overrun rather than preventing it: the offending
    ///      bytes are already written when `finish` runs. Reverting still
    ///      contains the damage, because nothing observes the corrupted memory
    ///      before the transaction unwinds. Keeping the check here costs one
    ///      comparison per buffer instead of one per write, which matters for
    ///      the render loops this library exists to speed up.
    function finish(bytes memory out, uint256 ptr) internal pure {
        uint256 written;
        uint256 capacity;
        assembly ("memory-safe") {
            capacity := mload(out)
            written := sub(ptr, add(out, 0x20))
        }
        if (written > capacity) revert BufferOverflow(written, capacity);
        assembly ("memory-safe") {
            mstore(out, written)
        }
    }

    function w(uint256 ptr, bytes memory s) internal pure returns (uint256) {
        assembly ("memory-safe") {
            let len := mload(s)
            mcopy(ptr, add(s, 0x20), len)
            ptr := add(ptr, len)
        }
        return ptr;
    }

    /// @dev writes a single byte
    function w1(uint256 ptr, uint8 b) internal pure returns (uint256) {
        assembly ("memory-safe") {
            mstore8(ptr, b)
        }
        return ptr + 1;
    }

    /// @dev decimal, any uint256. Counts the digits, then fills them in
    ///      backwards from the end so no scratch buffer or reversal is needed.
    ///      Writes up to 78 bytes (type(uint256).max), so size `cap` for the
    ///      largest value a call site can actually produce.
    function wNum(uint256 ptr, uint256 n) internal pure returns (uint256 end) {
        assembly ("memory-safe") {
            let len := 1
            let m := n
            for {} gt(m, 9) {} {
                m := div(m, 10)
                len := add(len, 1)
            }
            end := add(ptr, len)
            let p := end
            for {} 1 {} {
                p := sub(p, 1)
                mstore8(p, add(48, mod(n, 10)))
                n := div(n, 10)
                if iszero(n) {
                    break
                }
            }
        }
    }

    /// @dev 6 lowercase hex chars for a 24-bit RGB value.
    ///      `rgb` is a `uint24` rather than a `uint256` so the 24-bit domain is
    ///      enforced by the compiler instead of by a comment: an out-of-range
    ///      literal no longer compiles, and a wider value has to be narrowed
    ///      with an explicit cast the caller writes and a reviewer can see.
    ///      Measured at +2 gas against the unchecked `uint256` version, which
    ///      matters because colours are written once per element in a render
    ///      loop. Matches `w1` taking a `uint8`. Note that an *external*
    ///      function exposing a `uint24` does pay ABI range validation on the
    ///      argument (~80 gas); that is the ABI boundary, not this library.
    ///
    ///      Inline assembly may see dirty bits above a narrow type's encoding,
    ///      but every nibble here is read as `and(shr(k * 4, rgb), 0xf)` for
    ///      k in 0..5, so only bits 0-23 survive and anything above is masked.
    function wHex6(uint256 ptr, uint24 rgb) internal pure returns (uint256) {
        assembly ("memory-safe") {
            let
                table := 0x3031323334353637383961626364656600000000000000000000000000000000 // "0123456789abcdef"
            for {
                let i := 0
            } lt(i, 6) {
                i := add(i, 1)
            } {
                let nib := and(shr(mul(sub(5, i), 4), rgb), 0xf)
                mstore8(add(ptr, i), byte(nib, table))
            }
        }
        return ptr + 6;
    }
}
