// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../../../../examples/mocks/FreeMintMock.sol";
import "../../../../lib/forge-std/src/Test.sol";

/**
 * Forge section commands
 * forge test --gas-report --mt '\W*(MintZero)\W*'
 * forge test --gas-report --mt '\W*(MintOne)\W*'
 * forge test --gas-report --mt '\W*(MintThirty)\W*'
 */
contract FreeMintTest is Test {
    FreeMintMock t;
    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        t = new FreeMintMock();
        t.flipSaleState();
        vm.startPrank(owner, owner);
    }

    function testGasUsageAndRevertMintZeroToken() public {
        t.mint(1);
        vm.expectRevert(bytes("numberOfNfts must be larger than 0"));
        t.mintRequireNumberOfTokensLargerThanZero(0);
        vm.expectRevert(bytes("numberOfNfts cannot be 0"));
        t.mintRequireNumberOfTokensNotEqualsZero(0);
    }

    function testGasUsageMintOneToken() public {
        t.mint(1);
        t.mintRequireNumberOfTokensLargerThanZero(1);
        assertEq(t.totalSupply(), 2);
        t.mintRequireNumberOfTokensNotEqualsZero(1);
        assertEq(t.totalSupply(), 3);
    }

    function testGasUsageMintThirtyTokens() public {
        t.mint(1);
        t.mintRequireNumberOfTokensLargerThanZero(30);
        assertEq(t.totalSupply(), 31);
        t.mintRequireNumberOfTokensNotEqualsZero(30);
        assertEq(t.totalSupply(), 61);
    }
}
