// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../../lib/forge-std/src/Test.sol";
import "../../../../contracts/mocks/SoulboundMock.sol";

/**
 * @title SoulboundTest
 * @notice Characterization suite for Soulbound.sol, written before the
 * transfer/mint path refactor to lock in behavior and serve as the gas
 * baseline (forge snapshot).
 *
 * The test contract is the contract owner (SoulboundMock passes msg.sender).
 * Negative locked-token cases deliberately use approved non-owner callers so
 * they remain valid once the contract owner may manage locked tokens
 * directly.
 */
contract SoulboundTest is Test {
    // Local declarations of the IERC5192 events, for vm.expectEmit.
    event Locked(uint256 tokenId);
    event Unlocked(uint256 tokenId);

    SoulboundMock internal token;
    address internal holder;
    address internal bob;

    function setUp() public {
        token = new SoulboundMock("Soulbound", "SBT");
        holder = makeAddr("holder");
        bob = makeAddr("bob");
        token.mint(holder); // tokenId 0, locked
    }

    // ─── mint ────────────────────────────────────────────────────────────────

    function test_mint_emitsLockedEvent() public {
        vm.expectEmit(true, true, true, true);
        emit Locked(1);
        token.mint(holder);
    }

    function test_mint_tokenIsLockedByDefault() public {
        assertTrue(token.locked(0));
    }

    // ─── transferFrom ────────────────────────────────────────────────────────

    function test_transferFrom_lockedToken_revertsForApprovedCaller() public {
        token.approve(bob, 0);
        vm.prank(bob);
        vm.expectRevert(Soulbound.TokenNotTransferable.selector);
        token.transferFrom(holder, bob, 0);
    }

    function test_transferFrom_unlocked_byContractOwner_relocks() public {
        token.unlockedStatus(0, true);
        vm.expectEmit(true, true, true, true);
        emit Locked(0);
        token.transferFrom(holder, bob, 0);
        assertEq(token.ownerOf(0), bob);
        assertTrue(token.locked(0));
    }

    function test_transferFrom_unlocked_unapprovedCaller_reverts() public {
        token.unlockedStatus(0, true);
        vm.prank(bob);
        vm.expectRevert(Soulbound.NotOwnerOrApproved.selector);
        token.transferFrom(holder, bob, 0);
    }

    function test_safeTransferFrom_unlocked_byApprovedCaller_relocks() public {
        token.approve(bob, 0);
        token.unlockedStatus(0, true);
        vm.prank(bob);
        token.safeTransferFromHelperWithData(holder, bob, 0, "");
        assertEq(token.ownerOf(0), bob);
        assertTrue(token.locked(0));
    }

    // ─── burn ────────────────────────────────────────────────────────────────

    function test_burn_lockedToken_revertsForApprovedCaller() public {
        token.approve(bob, 0);
        vm.prank(bob);
        vm.expectRevert(Soulbound.TokenNotTransferable.selector);
        token.burn(0);
    }

    function test_burn_unlocked_byApprovedCaller() public {
        token.approve(bob, 0);
        token.unlockedStatus(0, true);
        vm.prank(bob);
        token.burn(0);
        assertEq(token.totalSupply(), 0);
        assertEq(token.totalBurned(), 1);
    }

    function test_burn_unlocked_byAllowedTokenHolder() public {
        token.allowBurn(true);
        token.unlockedStatus(0, true);
        vm.prank(holder);
        token.burn(0);
        assertEq(token.totalSupply(), 0);
    }

    // ─── unlock state lifecycle ──────────────────────────────────────────────

    function test_remintedId_startsLocked() public {
        token.mintId(holder, 7);
        token.unlockedStatus(7, true);
        token.burn(7); // caller is contract owner, token unlocked
        token.mintId(holder, 7);
        assertTrue(token.locked(7));
    }

    // ─── gas anchors (compared via forge snapshot before/after refactor) ────

    function test_gas_mint() public {
        token.mint(bob);
    }

    function test_gas_transferUnlockedByOwner() public {
        token.unlockedStatus(0, true);
        token.transferFrom(holder, bob, 0);
    }

    function test_gas_burnUnlockedByOwner() public {
        token.unlockedStatus(0, true);
        token.burn(0);
    }
}
