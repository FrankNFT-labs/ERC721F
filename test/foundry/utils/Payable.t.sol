// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../../lib/forge-std/src/Test.sol";
import "../../../../contracts/mocks/PayableMock.sol";

/**
 * @title PayableTest
 * @notice Regression suite for Payable.sol.
 *
 * These tests were written against the v5.6.1 release to lock the
 * behavioural contract of Payable and prevent silent regressions when
 * the contract is modified.
 *
 * Coverage targets:
 *  - receive()                     ETH can be sent to the contract
 *  - _withdraw(address, uint256)   happy path transfers ETH
 *  - _withdraw(address(0), ...)    reverts WithdrawToZeroAddress
 *  - _withdraw to rejecting target reverts EtherWithdrawFailed
 */
contract PayableTest is Test {
    PayableMock internal payableMock;
    RejectEtherMock internal rejecter;

    address internal constant ALICE = address(0xA11CE);

    function setUp() public {
        payableMock = new PayableMock();
        rejecter = new RejectEtherMock();
        // Fund the mock so withdrawals have balance to draw from.
        vm.deal(address(payableMock), 10 ether);
    }

    // ─── receive() ───────────────────────────────────────────────────────────

    function test_receive_acceptsEther() public {
        uint256 before = address(payableMock).balance;
        (bool ok, ) = address(payableMock).call{value: 1 ether}("");
        assertTrue(ok, "ETH transfer to contract should succeed");
        assertEq(address(payableMock).balance, before + 1 ether);
    }

    function test_receive_incrementsBalance(uint96 amount) public {
        vm.assume(amount > 0);
        uint256 before = address(payableMock).balance;
        (bool ok, ) = address(payableMock).call{value: amount}("");
        assertTrue(ok);
        assertEq(address(payableMock).balance, before + amount);
    }

    // ─── _withdraw — happy path ───────────────────────────────────────────────

    function test_withdraw_transfersExactAmount() public {
        uint256 aliceBefore = ALICE.balance;
        payableMock.withdraw(ALICE, 1 ether);
        assertEq(ALICE.balance, aliceBefore + 1 ether);
    }

    function test_withdraw_decreasesContractBalance() public {
        uint256 contractBefore = address(payableMock).balance;
        payableMock.withdraw(ALICE, 1 ether);
        assertEq(address(payableMock).balance, contractBefore - 1 ether);
    }

    function test_withdraw_fullBalance() public {
        uint256 total = address(payableMock).balance;
        payableMock.withdraw(ALICE, total);
        assertEq(address(payableMock).balance, 0);
        assertEq(ALICE.balance, total);
    }

    function test_fuzz_withdraw_transfersExactAmount(uint96 amount) public {
        vm.assume(amount > 0 && amount <= address(payableMock).balance);
        uint256 aliceBefore = ALICE.balance;
        payableMock.withdraw(ALICE, amount);
        assertEq(ALICE.balance, aliceBefore + amount);
    }

    // ─── _withdraw — WithdrawToZeroAddress ───────────────────────────────────

    function test_withdraw_revertsOnZeroAddress() public {
        vm.expectRevert(Payable.WithdrawToZeroAddress.selector);
        payableMock.withdraw(address(0), 1 ether);
    }

    function test_withdraw_zeroAddress_anyAmount(uint96 amount) public {
        vm.expectRevert(Payable.WithdrawToZeroAddress.selector);
        payableMock.withdraw(address(0), amount);
    }

    // ─── _withdraw — EtherWithdrawFailed ─────────────────────────────────────

    function test_withdraw_revertsWhenRecipientRejectsEther() public {
        vm.expectRevert(Payable.EtherWithdrawFailed.selector);
        payableMock.withdraw(address(rejecter), 1 ether);
    }
}
