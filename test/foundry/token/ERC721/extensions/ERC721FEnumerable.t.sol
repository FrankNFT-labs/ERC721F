// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../../../lib/forge-std/src/Test.sol";
import "../../../../../contracts/mocks/ERC721FEnumerableMock.sol";
import "../../../../../contracts/mocks/ERC721FEnumerableStartAtOneMock.sol";

/**
 * @title ERC721FEnumerableTest
 * @notice Foundry suite for ERC721FEnumerable.sol focusing on the paths the
 * hardhat suite exercises least: burn holes in the id range, the non-zero
 * start id variant, and a fuzz over mint/burn counts. The mock mints to
 * msg.sender, so the test contract holds tokens unless it pranks.
 */
contract ERC721FEnumerableTest is Test {
    ERC721FEnumerableMock internal token;
    address internal alice;

    function setUp() public {
        token = new ERC721FEnumerableMock("Enumerable", "ENM");
        alice = makeAddr("alice");
    }

    function test_supportsInterface_enumerable() public {
        assertTrue(
            token.supportsInterface(type(IERC721Enumerable).interfaceId)
        );
    }

    // ─── tokenByIndex ────────────────────────────────────────────────────────

    function test_tokenByIndex_sequentialWithoutBurns() public {
        token.mint(3);
        for (uint256 i; i < 3; i++) {
            assertEq(token.tokenByIndex(i), i);
        }
    }

    function test_tokenByIndex_skipsBurnedToken() public {
        token.mint(5); // ids 0..4
        token.burn(2);
        assertEq(token.totalSupply(), 4);
        assertEq(token.tokenByIndex(0), 0);
        assertEq(token.tokenByIndex(1), 1);
        assertEq(token.tokenByIndex(2), 3);
        assertEq(token.tokenByIndex(3), 4);
    }

    function test_tokenByIndex_revertsWhenIndexOutOfBounds() public {
        token.mint(2);
        vm.expectRevert(ERC721FEnumerable.TotalIndexOutOfBounds.selector);
        token.tokenByIndex(2);
    }

    function test_tokenByIndex_boundsShrinkAfterBurn() public {
        token.mint(2);
        token.burn(0);
        vm.expectRevert(ERC721FEnumerable.TotalIndexOutOfBounds.selector);
        token.tokenByIndex(1);
    }

    // ─── tokenOfOwnerByIndex ─────────────────────────────────────────────────

    function test_tokenOfOwnerByIndex_returnsOwnersTokensInIdOrder() public {
        token.mint(2); // this: 0,1
        vm.prank(alice);
        token.mint(2); // alice: 2,3
        token.mint(1); // this: 4

        assertEq(token.tokenOfOwnerByIndex(address(this), 0), 0);
        assertEq(token.tokenOfOwnerByIndex(address(this), 1), 1);
        assertEq(token.tokenOfOwnerByIndex(address(this), 2), 4);
        assertEq(token.tokenOfOwnerByIndex(alice, 0), 2);
        assertEq(token.tokenOfOwnerByIndex(alice, 1), 3);
    }

    function test_tokenOfOwnerByIndex_reflectsTransfers() public {
        token.mint(2); // this: 0,1
        vm.prank(alice);
        token.mint(1); // alice: 2
        token.transferFrom(address(this), alice, 0);

        // alice now holds 0 and 2; the scan returns them in id order.
        assertEq(token.tokenOfOwnerByIndex(alice, 0), 0);
        assertEq(token.tokenOfOwnerByIndex(alice, 1), 2);
        assertEq(token.tokenOfOwnerByIndex(address(this), 0), 1);
    }

    function test_tokenOfOwnerByIndex_revertsWhenIndexOutOfBounds() public {
        token.mint(1);
        vm.expectRevert(ERC721FEnumerable.OwnerIndexOutOfBounds.selector);
        token.tokenOfOwnerByIndex(address(this), 1);
    }

    // ─── non-zero start id variant ───────────────────────────────────────────

    function test_startAtOne_tokenByIndexOffsetsCorrectly() public {
        ERC721FEnumerableStartAtOneMock startAtOne = new ERC721FEnumerableStartAtOneMock(
                "StartAtOne",
                "SAO"
            );
        startAtOne.mint(3); // ids 1..3
        assertEq(startAtOne.tokenByIndex(0), 1);
        assertEq(startAtOne.tokenByIndex(2), 3);
        assertEq(startAtOne.tokenOfOwnerByIndex(address(this), 0), 1);
    }

    // ─── fuzz: supply accounting vs enumeration ──────────────────────────────

    function test_fuzz_enumerationConsistentAfterBurns(
        uint8 mintCount,
        uint8 burnCount
    ) public {
        uint256 minted = bound(mintCount, 1, 30);
        uint256 burned = bound(burnCount, 0, minted);
        token.mint(minted);
        for (uint256 i; i < burned; i++) {
            token.burn(i); // burn the lowest ids
        }

        assertEq(token.totalSupply(), minted - burned);
        // Remaining ids are contiguous starting right after the burned range.
        for (uint256 i; i < minted - burned; i++) {
            assertEq(token.tokenByIndex(i), burned + i);
        }
    }
}
