// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24 <0.9.0;

import "../utils/BytesBuilder.sol";

/**
 * @title BytesBuilderMock
 * @dev Mock exposing the internal BytesBuilder helpers for testing purposes.
 * The library threads a raw memory pointer that is only valid inside a single
 * call frame, so every function here runs a complete start -> write -> finish
 * cycle and returns the materialized bytes. Returning over the ABI boundary is
 * deliberate: a corrupted length word or an overrun allocation surfaces as a
 * malformed return value rather than staying invisible inside the test.
 */
contract BytesBuilderMock {
    /**
     * @dev Exposes what start() produced without writing anything, so the
     * allocation size and the pointer placement can be asserted directly.
     * @param cap capacity to allocate
     * @return allocatedLength length word of the freshly allocated buffer
     * @return ptrOffset distance from the array head to the write pointer
     */
    function inspectStart(
        uint256 cap
    ) external pure returns (uint256 allocatedLength, uint256 ptrOffset) {
        (bytes memory out, uint256 ptr) = BytesBuilder.start(cap);
        allocatedLength = out.length;
        assembly ("memory-safe") {
            ptrOffset := sub(ptr, out)
        }
    }

    /**
     * @dev start() followed by finish() with no write in between.
     * @param cap capacity to allocate
     * @return out the finished buffer, expected to be empty
     */
    function buildEmpty(uint256 cap) external pure returns (bytes memory out) {
        uint256 ptr;
        (out, ptr) = BytesBuilder.start(cap);
        BytesBuilder.finish(out, ptr);
    }

    /**
     * @dev Appends every piece in order through w().
     * @param cap capacity to allocate
     * @param pieces byte strings to append
     * @return out the finished buffer
     */
    function buildBytes(
        uint256 cap,
        bytes[] calldata pieces
    ) external pure returns (bytes memory out) {
        uint256 ptr;
        (out, ptr) = BytesBuilder.start(cap);
        for (uint256 i; i < pieces.length;) {
            ptr = BytesBuilder.w(ptr, pieces[i]);
            unchecked {
                ++i;
            }
        }
        BytesBuilder.finish(out, ptr);
    }

    /**
     * @dev Appends every value in order through w1().
     * @param cap capacity to allocate
     * @param values raw byte values to append
     * @return out the finished buffer
     */
    function buildBytes1(
        uint256 cap,
        uint8[] calldata values
    ) external pure returns (bytes memory out) {
        uint256 ptr;
        (out, ptr) = BytesBuilder.start(cap);
        for (uint256 i; i < values.length;) {
            ptr = BytesBuilder.w1(ptr, values[i]);
            unchecked {
                ++i;
            }
        }
        BytesBuilder.finish(out, ptr);
    }

    /**
     * @dev Appends every value in order through wNum().
     * @param cap capacity to allocate
     * @param values decimal values to append, each below 10000
     * @return out the finished buffer
     */
    function buildNums(
        uint256 cap,
        uint256[] calldata values
    ) external pure returns (bytes memory out) {
        uint256 ptr;
        (out, ptr) = BytesBuilder.start(cap);
        for (uint256 i; i < values.length;) {
            ptr = BytesBuilder.wNum(ptr, values[i]);
            unchecked {
                ++i;
            }
        }
        BytesBuilder.finish(out, ptr);
    }

    /**
     * @dev Appends every value in order through wHex6().
     * @param cap capacity to allocate
     * @param values 24-bit RGB values to append
     * @return out the finished buffer
     */
    function buildHex6(
        uint256 cap,
        uint24[] calldata values
    ) external pure returns (bytes memory out) {
        uint256 ptr;
        (out, ptr) = BytesBuilder.start(cap);
        for (uint256 i; i < values.length;) {
            ptr = BytesBuilder.wHex6(ptr, values[i]);
            unchecked {
                ++i;
            }
        }
        BytesBuilder.finish(out, ptr);
    }

    /**
     * @dev Representative render exercising all five helpers in one buffer,
     * over-allocating so finish() has to shrink the length word.
     * @param x rect x coordinate
     * @param y rect y coordinate
     * @param size rect width and height
     * @param rgb 24-bit fill colour
     * @return out the finished SVG fragment
     */
    function buildSvgRect(
        uint256 x,
        uint256 y,
        uint256 size,
        uint24 rgb
    ) external pure returns (bytes memory out) {
        uint256 ptr;
        (out, ptr) = BytesBuilder.start(96);
        ptr = BytesBuilder.w(ptr, bytes('<rect x="'));
        ptr = BytesBuilder.wNum(ptr, x);
        ptr = BytesBuilder.w(ptr, bytes('" y="'));
        ptr = BytesBuilder.wNum(ptr, y);
        ptr = BytesBuilder.w(ptr, bytes('" width="'));
        ptr = BytesBuilder.wNum(ptr, size);
        ptr = BytesBuilder.w(ptr, bytes('" height="'));
        ptr = BytesBuilder.wNum(ptr, size);
        ptr = BytesBuilder.w(ptr, bytes('" fill="#'));
        ptr = BytesBuilder.wHex6(ptr, rgb);
        ptr = BytesBuilder.w1(ptr, 0x22); // closing double quote
        ptr = BytesBuilder.w(ptr, bytes("/>"));
        BytesBuilder.finish(out, ptr);
    }

    /**
     * @dev Allocates a sentinel array immediately after the buffer, then fills
     * the buffer. Used to show that writes staying inside `cap` never reach the
     * neighbouring allocation, which is what the ("memory-safe") annotations
     * promise the optimizer.
     * @param cap capacity to allocate
     * @param piece byte string to append
     * @param sentinelValue contents of the neighbouring allocation
     * @return out the finished buffer
     * @return neighbour the sentinel array as it stands after the writes
     */
    function buildWithNeighbour(
        uint256 cap,
        bytes calldata piece,
        bytes calldata sentinelValue
    ) external pure returns (bytes memory out, bytes memory neighbour) {
        uint256 ptr;
        (out, ptr) = BytesBuilder.start(cap);
        neighbour = bytes.concat(sentinelValue);
        ptr = BytesBuilder.w(ptr, piece);
        BytesBuilder.finish(out, ptr);
    }

    /**
     * @dev Hands finish() a pointer that sits before the buffer's data word, as
     * a caller mixing up two buffers would. The length subtraction wraps, so
     * this is the underflow side of the capacity guard.
     * @param cap capacity to allocate
     * @param rewindBy how far to move the pointer back past the data word
     * @return out the finished buffer
     */
    function finishWithRewoundPointer(
        uint256 cap,
        uint256 rewindBy
    ) external pure returns (bytes memory out) {
        uint256 ptr;
        (out, ptr) = BytesBuilder.start(cap);
        BytesBuilder.finish(out, ptr - rewindBy);
    }
}
