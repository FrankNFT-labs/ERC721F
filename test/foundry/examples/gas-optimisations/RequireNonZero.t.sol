// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../../../../examples/gas-optimisations/RequireNonZero.sol";
import "../../../../lib/forge-std/src/Test.sol";

contract RequireNonZeroTest is Test {
    RequireNonZero t;

    function setUp() public {
        t = new RequireNonZero();
    }

    function testRequireLargerThanZeroReverts() public {
        vm.expectRevert(bytes("Value must be larger than 0"));
        t.requireLargerThanZero(0);
    }

    function testRequireNotEqualsZeroReverts() public {
        vm.expectRevert(bytes("Value, can't be 0"));
        t.requireNotEqualsZero(0);
    }
}
