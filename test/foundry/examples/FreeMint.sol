// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../../../examples/FreeMint.sol";
import "../../../lib/forge-std/src/Test.sol";

/**
 * Forge section commands
 * forge test --gas-report --mt '\W*(MintThirty)\W*'
 * forge test --gas-report --mt '\W*(MintOne)\W*'
 * forge test --gas-report --mt '\W*(MintZero)\W*'
 */
contract FreeMintTest is Test {
    FreeMint t;
    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        t = new FreeMint();
    }

    function testGasUsageMintThirtyTokens() public {
        t.flipSaleState();
        vm.prank(owner, owner);
        t.mint(30);
        assertEq(t.totalSupply(), 30);
    }

    function testGasUsageMintOneToken() public {
        t.flipSaleState();
        vm.prank(owner, owner);
        t.mint(1);
        assertEq(t.totalSupply(), 1);
    }

    function testGasUsageAndRevertMintZeroToken() public {
        t.flipSaleState();
        vm.prank(owner, owner);
        vm.expectRevert(bytes("numberOfNfts cannot be 0"));
        t.mint(0);
        assertEq(t.totalSupply(), 0);
    }
}
