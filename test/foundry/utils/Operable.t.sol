// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../../lib/forge-std/src/Test.sol";
import "../../../../contracts/mocks/OperableMock.sol";

/**
 * @title OperableTest
 * @notice Behavioral suite for Operable.sol: single-operator access control
 * where both the owner and the operator pass the onlyOperator gate.
 */
contract OperableTest is Test {
    OperableMock internal operable;
    address internal bob;
    address internal stranger;

    function setUp() public {
        operable = new OperableMock();
        bob = makeAddr("bob");
        stranger = makeAddr("stranger");
    }

    function test_operator_isDeployerByDefault() public {
        assertEq(operable.operator(), address(this));
    }

    function test_setOperator_changesOperator() public {
        operable.setOperator(bob);
        assertEq(operable.operator(), bob);
    }

    function test_setOperator_revertsForNonOwner() public {
        vm.prank(stranger);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                stranger
            )
        );
        operable.setOperator(stranger);
    }

    function test_operatorAction_allowsOperator() public {
        operable.setOperator(bob);
        vm.prank(bob);
        operable.operatorAction();
        assertEq(operable.operatorActionCount(), 1);
    }

    function test_operatorAction_allowsOwnerWhoIsNotOperator() public {
        operable.setOperator(bob);
        operable.operatorAction();
        assertEq(operable.operatorActionCount(), 1);
    }

    function test_operatorAction_revertsForStranger() public {
        vm.prank(stranger);
        vm.expectRevert(Operable.CallerNotOwnerOrOperator.selector);
        operable.operatorAction();
    }

    function test_operatorAction_revertsForReplacedOperator() public {
        operable.setOperator(bob);
        operable.setOperator(stranger);
        vm.prank(bob);
        vm.expectRevert(Operable.CallerNotOwnerOrOperator.selector);
        operable.operatorAction();
    }
}
