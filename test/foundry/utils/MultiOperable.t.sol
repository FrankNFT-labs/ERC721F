// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/mocks/MultiOperableMock.sol";

/**
 * @title MultiOperableTest
 * @notice Behavioral suite for MultiOperable.sol: multi-operator access
 * control where the owner and every registered operator pass the
 * onlyOperators gate.
 */
contract MultiOperableTest is Test {
    MultiOperableMock internal multiOperable;
    address internal bob;
    address internal carol;
    address internal stranger;

    function setUp() public {
        multiOperable = new MultiOperableMock();
        bob = makeAddr("bob");
        carol = makeAddr("carol");
        stranger = makeAddr("stranger");
    }

    function test_addOperator_marksAddressAsOperator() public {
        multiOperable.addOperator(bob);
        assertTrue(multiOperable.isOperator(bob));
        assertFalse(multiOperable.isOperator(carol));
    }

    function test_addOperator_revertsForNonOwner() public {
        vm.prank(stranger);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                stranger
            )
        );
        multiOperable.addOperator(stranger);
    }

    function test_removeOperator_unmarksAddress() public {
        multiOperable.addOperator(bob);
        multiOperable.removeOperator(bob);
        assertFalse(multiOperable.isOperator(bob));
    }

    function test_removeOperator_revertsForNonOwner() public {
        multiOperable.addOperator(bob);
        vm.prank(stranger);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                stranger
            )
        );
        multiOperable.removeOperator(bob);
    }

    function test_operatorAction_allowsEveryOperator() public {
        multiOperable.addOperator(bob);
        multiOperable.addOperator(carol);
        vm.prank(bob);
        multiOperable.operatorAction();
        vm.prank(carol);
        multiOperable.operatorAction();
        assertEq(multiOperable.operatorActionCount(), 2);
    }

    function test_operatorAction_allowsOwnerWhoIsNotOperator() public {
        multiOperable.operatorAction();
        assertEq(multiOperable.operatorActionCount(), 1);
    }

    function test_operatorAction_revertsForStranger() public {
        vm.prank(stranger);
        vm.expectRevert(MultiOperable.CallerNotOwnerOrOperator.selector);
        multiOperable.operatorAction();
    }

    function test_operatorAction_revertsForRemovedOperator() public {
        multiOperable.addOperator(bob);
        multiOperable.removeOperator(bob);
        vm.prank(bob);
        vm.expectRevert(MultiOperable.CallerNotOwnerOrOperator.selector);
        multiOperable.operatorAction();
    }
}
