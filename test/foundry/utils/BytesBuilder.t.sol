// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24 <0.9.0;

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/mocks/BytesBuilderMock.sol";

/**
 * @title BytesBuilderTest
 * @notice Path coverage for BytesBuilder.sol. The library hands the caller a
 * raw memory pointer, so correctness means three separate things and each is
 * asserted here: the right bytes land in the buffer, the pointer advances by
 * exactly the number of bytes written, and finish() stamps a length word that
 * matches. Every assertion runs across the ABI boundary, so a pointer that
 * drifts shows up as a wrong length or wrong content rather than silently
 * passing.
 *
 * Coverage map:
 *  - start          : zero capacity, non-zero capacity, fuzzed capacity
 *  - finish         : nothing written, partial fill, exact fill, and the
 *                     capacity guard from both sides of the boundary
 *  - append         : empty, sub-word, exact word, word+1, repeated, fuzzed
 *  - appendByte     : 0x00, printable, 0xff, repeated, fuzzed
 *  - appendNumber   : 0, every power-of-ten boundary, interior zeros,
 *                     uint256 max, fuzzed small-range and full-range
 *  - appendHexColor : both nibble extremes, full alphabet, digit ordering,
 *                     fuzzed over the whole uint24 domain
 *
 * Neither helper has an unenforced precondition left. appendNumber is
 * asserted across all of uint256, and appendHexColor takes a uint24, so its
 * fuzz test covers the whole of its parameter type rather than a subset of a
 * wider one: no input exists that these tests do not speak for. Capacity is
 * the one thing still left to the caller, and finish() reverts when a caller
 * gets it wrong.
 */
contract BytesBuilderTest is Test {
    BytesBuilderMock internal builder;

    function setUp() public {
        builder = new BytesBuilderMock();
    }

    // ─── start ───────────────────────────────────────────────────────────────

    function test_start_allocatesRequestedCapacity() public {
        (uint256 allocatedLength, uint256 ptrOffset) = builder.inspectStart(64);
        assertEq(allocatedLength, 64);
        assertEq(ptrOffset, 0x20);
    }

    function test_start_acceptsZeroCapacity() public {
        (uint256 allocatedLength, uint256 ptrOffset) = builder.inspectStart(0);
        assertEq(allocatedLength, 0);
        assertEq(ptrOffset, 0x20);
    }

    function test_fuzz_start_pointerAlwaysAtDataWord(uint16 cap) public {
        (uint256 allocatedLength, uint256 ptrOffset) = builder.inspectStart(
            cap
        );
        assertEq(allocatedLength, cap);
        assertEq(ptrOffset, 0x20);
    }

    // ─── finish ──────────────────────────────────────────────────────────────

    function test_finish_zeroCapacityYieldsEmpty() public {
        assertEq(builder.buildEmpty(0), bytes(""));
    }

    function test_finish_shrinksUnwrittenCapacityToEmpty() public {
        bytes memory out = builder.buildEmpty(128);
        assertEq(out.length, 0);
        assertEq(out, bytes(""));
    }

    function test_finish_keepsOnlyTheWrittenPrefix() public {
        bytes[] memory pieces = new bytes[](1);
        pieces[0] = bytes("abc");
        bytes memory out = builder.buildBytes(128, pieces);
        assertEq(out.length, 3);
        assertEq(out, bytes("abc"));
    }

    function test_finish_keepsFullLengthWhenCapacityExactlyFilled() public {
        bytes[] memory pieces = new bytes[](2);
        pieces[0] = bytes("abcd");
        pieces[1] = bytes("efgh");
        bytes memory out = builder.buildBytes(8, pieces);
        assertEq(out.length, 8);
        assertEq(out, bytes("abcdefgh"));
    }

    // ─── w ───────────────────────────────────────────────────────────────────

    function test_append_emptyInputLeavesPointerUnmoved() public {
        bytes[] memory pieces = new bytes[](3);
        pieces[0] = bytes("");
        pieces[1] = bytes("x");
        pieces[2] = bytes("");
        bytes memory out = builder.buildBytes(16, pieces);
        assertEq(out.length, 1);
        assertEq(out, bytes("x"));
    }

    function test_append_singleByte() public {
        bytes[] memory pieces = new bytes[](1);
        pieces[0] = bytes("Z");
        assertEq(builder.buildBytes(16, pieces), bytes("Z"));
    }

    /// @dev 31 / 32 / 33 bracket the mcopy word boundary: a partial word, an
    /// exact word, and a word plus a trailing partial word.
    function test_append_wordBoundaryLengths() public {
        uint256[3] memory lengths = [uint256(31), 32, 33];
        for (uint256 i; i < lengths.length; ++i) {
            bytes memory piece = _pattern(lengths[i]);
            bytes[] memory pieces = new bytes[](1);
            pieces[0] = piece;
            bytes memory out = builder.buildBytes(64, pieces);
            assertEq(out.length, lengths[i]);
            assertEq(out, piece);
        }
    }

    function test_append_appendsInOrder() public {
        bytes[] memory pieces = new bytes[](4);
        pieces[0] = bytes("<svg ");
        pieces[1] = bytes("width=");
        pieces[2] = bytes('"100"');
        pieces[3] = bytes(">");
        assertEq(builder.buildBytes(64, pieces), bytes('<svg width="100">'));
    }

    function test_append_doesNotDisturbNeighbouringAllocation() public {
        bytes memory piece = _pattern(40);
        bytes memory sentinel = bytes("sentinel-must-survive");
        (bytes memory out, bytes memory neighbour) = builder.buildWithNeighbour(
            piece.length,
            piece,
            sentinel
        );
        assertEq(out, piece);
        assertEq(neighbour, sentinel);
    }

    function test_fuzz_append_roundTripsArbitraryBytes(
        bytes memory piece
    ) public {
        vm.assume(piece.length <= 512);
        bytes[] memory pieces = new bytes[](1);
        pieces[0] = piece;
        bytes memory out = builder.buildBytes(piece.length, pieces);
        assertEq(out.length, piece.length);
        assertEq(out, piece);
    }

    function test_fuzz_append_concatenationMatchesNativeConcat(
        bytes memory first,
        bytes memory second
    ) public {
        vm.assume(first.length + second.length <= 512);
        bytes[] memory pieces = new bytes[](2);
        pieces[0] = first;
        pieces[1] = second;
        assertEq(
            builder.buildBytes(first.length + second.length, pieces),
            bytes.concat(first, second)
        );
    }

    // ─── appendByte ──────────────────────────────────────────────────────────────────

    function test_w1_writesNulByteAndStillAdvances() public {
        uint8[] memory values = new uint8[](1);
        values[0] = 0x00;
        bytes memory out = builder.buildByteValues(16, values);
        assertEq(out.length, 1);
        assertEq(out, hex"00");
    }

    function test_w1_writesMaxByte() public {
        uint8[] memory values = new uint8[](1);
        values[0] = 0xff;
        assertEq(builder.buildByteValues(16, values), hex"ff");
    }

    function test_w1_writesSequenceInOrder() public {
        uint8[] memory values = new uint8[](4);
        values[0] = 0x41; // A
        values[1] = 0x00;
        values[2] = 0xff;
        values[3] = 0x7a; // z
        assertEq(builder.buildByteValues(16, values), hex"4100ff7a");
    }

    function test_fuzz_w1_writesExactlyOneByte(uint8 value) public {
        uint8[] memory values = new uint8[](1);
        values[0] = value;
        bytes memory out = builder.buildByteValues(16, values);
        assertEq(out.length, 1);
        assertEq(uint8(out[0]), value);
    }

    // ─── appendNumber ────────────────────────────────────────────────────────────────

    function test_wNum_zero() public {
        assertEq(_num(0), bytes("0"));
    }

    /// @dev One case either side of every branch threshold in appendNumber.
    function test_wNum_branchBoundaries() public {
        assertEq(_num(9), bytes("9")); // n < 10
        assertEq(_num(10), bytes("10")); // n >= 10
        assertEq(_num(99), bytes("99"));
        assertEq(_num(100), bytes("100")); // n >= 100
        assertEq(_num(999), bytes("999"));
        assertEq(_num(1000), bytes("1000")); // n >= 1000
        assertEq(_num(9999), bytes("9999")); // top of the domain
    }

    /// @dev Interior zeros are where a digit-extraction bug hides: each of these
    /// forces a `% 10` result of 0 in a position that is still emitted.
    function test_wNum_interiorZeroDigits() public {
        assertEq(_num(101), bytes("101"));
        assertEq(_num(110), bytes("110"));
        assertEq(_num(1001), bytes("1001"));
        assertEq(_num(1010), bytes("1010"));
        assertEq(_num(1100), bytes("1100"));
        assertEq(_num(2005), bytes("2005"));
    }

    function test_wNum_appendsWithoutSeparator() public {
        uint256[] memory values = new uint256[](3);
        values[0] = 1;
        values[1] = 23;
        values[2] = 4567;
        assertEq(builder.buildNums(32, values), bytes("1234567"));
    }

    /// @dev Dense coverage of the small values this library actually renders.
    function test_fuzz_wNum_matchesDecimalRendering(uint256 n) public {
        n = bound(n, 0, 9999);
        assertEq(string(_num(n)), vm.toString(n));
    }

    // ─── appendNumber: beyond four digits ────────────────────────────────────────────

    function test_wNum_fiveDigitsAndAbove() public {
        assertEq(_num(10000), bytes("10000"));
        assertEq(_num(65535), bytes("65535"));
        assertEq(_num(123456), bytes("123456"));
    }

    /// @dev Each pair straddles a power-of-ten boundary, where a digit-count
    /// that is off by one shows up immediately.
    function test_wNum_digitCountBoundaries() public {
        assertEq(_num(9999), bytes("9999"));
        assertEq(_num(10000), bytes("10000"));
        assertEq(_num(99999), bytes("99999"));
        assertEq(_num(100000), bytes("100000"));
        assertEq(_num(1e18 - 1), bytes("999999999999999999"));
        assertEq(_num(1e18), bytes("1000000000000000000"));
    }

    function test_wNum_uint256Max() public {
        bytes memory out = _num(type(uint256).max);
        assertEq(
            out,
            bytes(
                "115792089237316195423570985008687907853269984665640564039457584007913129639935"
            )
        );
        assertEq(out.length, 78);
    }

    function test_fuzz_wNum_matchesDecimalRenderingFullRange(uint256 n) public {
        assertEq(string(_num(n)), vm.toString(n));
    }

    // ─── appendHexColor ───────────────────────────────────────────────────────────────

    function test_wHex6_nibbleExtremes() public {
        assertEq(_hex6(0x000000), bytes("000000"));
        assertEq(_hex6(0xffffff), bytes("ffffff"));
    }

    /// @dev Between them these three values emit all sixteen hex characters, so
    /// every entry of the lookup table is exercised.
    function test_wHex6_coversFullAlphabet() public {
        assertEq(_hex6(0x012345), bytes("012345"));
        assertEq(_hex6(0x6789ab), bytes("6789ab"));
        assertEq(_hex6(0xcdef01), bytes("cdef01"));
    }

    /// @dev Pins the digit order: a single set nibble must land in its own
    /// column, most significant first.
    function test_wHex6_emitsMostSignificantNibbleFirst() public {
        assertEq(_hex6(0x100000), bytes("100000"));
        assertEq(_hex6(0x010000), bytes("010000"));
        assertEq(_hex6(0x001000), bytes("001000"));
        assertEq(_hex6(0x000100), bytes("000100"));
        assertEq(_hex6(0x000010), bytes("000010"));
        assertEq(_hex6(0x000001), bytes("000001"));
    }

    function test_wHex6_alwaysWritesSixCharacters() public {
        assertEq(_hex6(0x000001).length, 6);
        assertEq(_hex6(0xabcdef).length, 6);
    }

    function test_wHex6_appendsWithoutSeparator() public {
        uint24[] memory values = new uint24[](2);
        values[0] = 0x112233;
        values[1] = 0x445566;
        assertEq(builder.buildHex6(32, values), bytes("112233445566"));
    }

    /// @dev The parameter type is the domain, so this fuzzes every value appendHexColor
    /// can be handed rather than a chosen slice of a wider type. Values above
    /// bit 23 used to render silently truncated; they are now a compile error
    /// at the call site, which no runtime test can express.
    function test_fuzz_wHex6_matchesReferenceRendering(uint24 rgb) public {
        assertEq(_hex6(rgb), bytes(_referenceHex6(rgb)));
    }

    /// @dev Pins the top of the domain explicitly: the widest uint24 is exactly
    /// the widest 24-bit colour, so the type and the format agree at the edge.
    function test_wHex6_typeMaximumIsWhite() public {
        assertEq(uint256(type(uint24).max), 0xffffff);
        assertEq(_hex6(type(uint24).max), bytes("ffffff"));
    }

    // ─── capacity guard ──────────────────────────────────────────────────────

    function test_RevertWhen_singleWriteOverrunsCapacity() public {
        bytes[] memory pieces = new bytes[](1);
        pieces[0] = bytes("abcdefgh");
        vm.expectRevert(
            abi.encodeWithSelector(BytesBuilder.BufferOverflow.selector, 8, 4)
        );
        builder.buildBytes(4, pieces);
    }

    /// @dev Smallest possible overrun; the guard must not be off by one.
    function test_RevertWhen_oneByteOverCapacity() public {
        bytes[] memory pieces = new bytes[](1);
        pieces[0] = bytes("abcde");
        vm.expectRevert(
            abi.encodeWithSelector(BytesBuilder.BufferOverflow.selector, 5, 4)
        );
        builder.buildBytes(4, pieces);
    }

    /// @dev No single write exceeds the buffer; only their sum does.
    function test_RevertWhen_accumulatedWritesOverrunCapacity() public {
        bytes[] memory pieces = new bytes[](3);
        pieces[0] = bytes("aaa");
        pieces[1] = bytes("bbb");
        pieces[2] = bytes("ccc");
        vm.expectRevert(
            abi.encodeWithSelector(BytesBuilder.BufferOverflow.selector, 9, 8)
        );
        builder.buildBytes(8, pieces);
    }

    function test_RevertWhen_w1OverrunsCapacity() public {
        uint8[] memory values = new uint8[](3);
        values[0] = 0x41;
        values[1] = 0x42;
        values[2] = 0x43;
        vm.expectRevert(
            abi.encodeWithSelector(BytesBuilder.BufferOverflow.selector, 3, 2)
        );
        builder.buildByteValues(2, values);
    }

    /// @dev The case the appendNumber rewrite made reachable: a capacity sized for the
    /// old four-digit ceiling, handed a value that now renders 78 bytes wide.
    function test_RevertWhen_wNumOverrunsCapacitySizedForFourDigits() public {
        uint256[] memory values = new uint256[](1);
        values[0] = type(uint256).max;
        vm.expectRevert(
            abi.encodeWithSelector(BytesBuilder.BufferOverflow.selector, 78, 4)
        );
        builder.buildNums(4, values);
    }

    function test_RevertWhen_wHex6OverrunsCapacity() public {
        uint24[] memory values = new uint24[](2);
        values[0] = 0x112233;
        values[1] = 0x445566;
        vm.expectRevert(
            abi.encodeWithSelector(BytesBuilder.BufferOverflow.selector, 12, 8)
        );
        builder.buildHex6(8, values);
    }

    /// @dev A pointer behind the data word makes the length subtraction wrap to
    /// a huge value; the same comparison has to catch it rather than storing it.
    function test_RevertWhen_pointerRewoundBeforeBufferStart() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                BytesBuilder.BufferOverflow.selector,
                type(uint256).max,
                8
            )
        );
        builder.finishWithRewoundPointer(8, 1);
    }

    /// @dev Filling capacity exactly is legal and must stay legal.
    function test_capacityGuard_allowsExactFill() public {
        bytes[] memory pieces = new bytes[](1);
        pieces[0] = bytes("abcd");
        assertEq(builder.buildBytes(4, pieces), bytes("abcd"));
    }

    /// @dev Pins the boundary from both sides at once: the guard must fire for
    /// every length above capacity and for none at or below it.
    function test_fuzz_capacityGuard_firesExactlyAboveCapacity(
        uint8 cap,
        uint8 writeLen
    ) public {
        bytes[] memory pieces = new bytes[](1);
        pieces[0] = _pattern(writeLen);
        if (writeLen > cap) {
            vm.expectRevert(
                abi.encodeWithSelector(
                    BytesBuilder.BufferOverflow.selector,
                    writeLen,
                    cap
                )
            );
            builder.buildBytes(cap, pieces);
        } else {
            assertEq(builder.buildBytes(cap, pieces).length, writeLen);
        }
    }

    // ─── all helpers combined ────────────────────────────────────────────────

    function test_integration_svgRectUsesEveryHelper() public {
        assertEq(
            builder.buildSvgRect(10, 20, 30, 0x1a2b3c),
            bytes('<rect x="10" y="20" width="30" height="30" fill="#1a2b3c"/>')
        );
    }

    /// @dev Same render at the widest values the domain allows: four-digit
    /// numbers and a full-white fill still fit the 96-byte capacity.
    function test_integration_svgRectAtDomainMaximum() public {
        bytes memory out = builder.buildSvgRect(9999, 9999, 9999, 0xffffff);
        assertEq(
            out,
            bytes(
                '<rect x="9999" y="9999" width="9999" height="9999" fill="#ffffff"/>'
            )
        );
        assertEq(out.length, 67);
    }

    /// @dev Single-digit values shorten the output, proving finish() reads the
    /// pointer rather than assuming a fixed layout.
    function test_integration_svgRectAtDomainMinimum() public {
        bytes memory out = builder.buildSvgRect(0, 0, 0, 0x000000);
        assertEq(
            out,
            bytes('<rect x="0" y="0" width="0" height="0" fill="#000000"/>')
        );
        assertEq(out.length, 55);
    }

    // ─── helpers ─────────────────────────────────────────────────────────────

    /// @dev Renders a single value through appendNumber. The capacity covers the 78
    /// digits of type(uint256).max so the helper works across the full domain.
    function _num(uint256 n) private view returns (bytes memory) {
        uint256[] memory values = new uint256[](1);
        values[0] = n;
        return builder.buildNums(96, values);
    }

    /// @dev Renders a single value through appendHexColor.
    function _hex6(uint24 rgb) private view returns (bytes memory) {
        uint24[] memory values = new uint24[](1);
        values[0] = rgb;
        return builder.buildHex6(8, values);
    }

    /// @dev Distinct non-zero bytes, so a misplaced copy changes the content
    /// and not just the length.
    function _pattern(uint256 len) private pure returns (bytes memory out) {
        out = new bytes(len);
        for (uint256 i; i < len; ++i) {
            out[i] = bytes1(uint8((i % 255) + 1));
        }
    }

    /// @dev Independent hex rendering used as the fuzz oracle; deliberately
    /// written in plain Solidity rather than reusing the library's lookup table.
    function _referenceHex6(uint24 rgb) private pure returns (string memory) {
        bytes16 digits = "0123456789abcdef";
        bytes memory out = new bytes(6);
        for (uint256 i; i < 6; ++i) {
            out[i] = digits[(rgb >> ((5 - i) * 4)) & 0xf];
        }
        return string(out);
    }
}
