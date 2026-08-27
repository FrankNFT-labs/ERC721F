// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/mocks/AllowListWithAmountMock.sol";

/**
 * @title AllowListWithAmountTest
 * @notice Characterization suite for AllowListWithAmount.sol, written before
 * the allowAddresses/decreaseAddressAvailableTokens refactor to lock in
 * behavior and serve as the gas baseline (forge snapshot).
 */
contract AllowListWithAmountTest is Test {
    AllowListWithAmountMock internal allowListMock;
    address internal alice;
    address internal stranger;

    function setUp() public {
        allowListMock = new AllowListWithAmountMock();
        alice = makeAddr("alice");
        stranger = makeAddr("stranger");
    }

    function test_allowAddresses_setsAmountForAllAddresses() public {
        address[] memory addresses = _buildAddresses(3);
        allowListMock.allowAddresses(addresses, 5);
        for (uint256 i; i < addresses.length; i++) {
            assertEq(allowListMock.getAllowListFunds(addresses[i]), 5);
        }
    }

    function test_allowAddresses_revertsForNonOwner() public {
        address[] memory addresses = _buildAddresses(1);
        vm.prank(stranger);
        vm.expectRevert();
        allowListMock.allowAddresses(addresses, 5);
    }

    function test_consumeTokens_decreasesAvailableTokens() public {
        allowListMock.allowAddress(alice, 10);
        vm.prank(alice);
        allowListMock.consumeTokens(4);
        assertEq(allowListMock.getAllowListFunds(alice), 6);
    }

    function test_consumeTokens_exactBalanceReachesZero() public {
        allowListMock.allowAddress(alice, 10);
        vm.prank(alice);
        allowListMock.consumeTokens(10);
        assertEq(allowListMock.getAllowListFunds(alice), 0);
    }

    function test_consumeTokens_revertsWhenInsufficient() public {
        allowListMock.allowAddress(alice, 3);
        vm.prank(alice);
        vm.expectRevert(
            AllowListWithAmount.InsufficientAllowListTokens.selector
        );
        allowListMock.consumeTokens(4);
    }

    // ─── gas anchors (compared via forge snapshot before/after refactor) ────

    function test_gas_allowAddresses100() public {
        allowListMock.allowAddresses(_buildAddresses(100), 5);
    }

    function test_gas_consumeTokens() public {
        allowListMock.allowAddress(alice, 10);
        vm.prank(alice);
        allowListMock.consumeTokens(4);
    }

    function _buildAddresses(
        uint256 amount
    ) internal pure returns (address[] memory addresses) {
        addresses = new address[](amount);
        for (uint256 i; i < amount; i++) {
            addresses[i] = address(uint160(i + 1));
        }
    }
}
