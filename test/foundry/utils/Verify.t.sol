// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/mocks/VerifyMock.sol";
import "../../../contracts/mocks/ERC721FMock.sol";

/**
 * @title VerifyTest
 * @notice Unit suite for Verify.sol pinning the three authorization paths:
 * direct token ownership, Warm Wallet hot-wallet lookup, and Delegate Cash
 * token-level delegation. Complements the integration coverage in
 * test/hardhat/examples/ERC721FVerifyImplementation.test.js.
 */
contract VerifyTest is Test {
    VerifyMock internal verifyMock;
    WarmWalletStubMock internal warmWallet;
    DelegateCashStubMock internal delegateCash;
    ERC721FMock internal token;
    address internal holder;
    address internal hotWallet;
    address internal stranger;

    function setUp() public {
        warmWallet = new WarmWalletStubMock();
        delegateCash = new DelegateCashStubMock();
        verifyMock = new VerifyMock(address(warmWallet), address(delegateCash));
        token = new ERC721FMock("Verify", "VFY");
        holder = makeAddr("holder");
        hotWallet = makeAddr("hotWallet");
        stranger = makeAddr("stranger");
        vm.prank(holder);
        token.mint(1); // tokenId 0 owned by holder
    }

    // ─── constructor guards ──────────────────────────────────────────────────

    function test_constructor_revertsOnZeroWarmWallet() public {
        vm.expectRevert(Verify.ZeroAddressCheck.selector);
        new VerifyMock(address(0), address(delegateCash));
    }

    function test_constructor_revertsOnZeroDelegateCash() public {
        vm.expectRevert(Verify.ZeroAddressCheck.selector);
        new VerifyMock(address(warmWallet), address(0));
    }

    // ─── authorization paths ─────────────────────────────────────────────────

    function test_verify_trueForTokenOwner() public {
        vm.prank(holder);
        assertTrue(verifyMock.verify(address(token), 0));
    }

    function test_verify_trueForWarmHotWallet() public {
        warmWallet.setOwner(hotWallet);
        vm.prank(hotWallet);
        assertTrue(verifyMock.verify(address(token), 0));
    }

    function test_verify_trueForDelegateCashDelegate() public {
        delegateCash.setDelegated(true);
        vm.prank(stranger);
        assertTrue(verifyMock.verify(address(token), 0));
    }

    function test_verify_falseForUnrelatedCaller() public {
        vm.prank(stranger);
        assertFalse(verifyMock.verify(address(token), 0));
    }
}
