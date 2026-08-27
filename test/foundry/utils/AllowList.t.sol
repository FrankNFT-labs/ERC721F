// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/mocks/AllowListMock.sol";

/**
 * @title AllowListTest
 * @notice Characterization suite for AllowList.sol, written before the
 * allowAddresses loop refactor to lock in behavior and serve as the gas
 * baseline (forge snapshot).
 */
contract AllowListTest is Test {
    AllowListMock internal allowListMock;
    address internal stranger;

    function setUp() public {
        allowListMock = new AllowListMock();
        stranger = makeAddr("stranger");
    }

    function test_allowAddresses_addsAllAddresses() public {
        address[] memory addresses = _buildAddresses(3);
        allowListMock.allowAddresses(addresses);
        for (uint256 i; i < addresses.length; i++) {
            assertTrue(allowListMock.isAllowList(addresses[i]));
        }
    }

    function test_allowAddresses_revertsForNonOwner() public {
        address[] memory addresses = _buildAddresses(1);
        vm.prank(stranger);
        vm.expectRevert();
        allowListMock.allowAddresses(addresses);
    }

    function test_allowAddress_revertsForNonOwner() public {
        vm.prank(stranger);
        vm.expectRevert();
        allowListMock.allowAddress(stranger);
    }

    function test_disallowAddress_removesAddress() public {
        allowListMock.allowAddress(stranger);
        allowListMock.disallowAddress(stranger);
        assertFalse(allowListMock.isAllowList(stranger));
    }

    // ─── gas anchor (compared via forge snapshot before/after refactor) ─────

    function test_gas_allowAddresses100() public {
        allowListMock.allowAddresses(_buildAddresses(100));
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
