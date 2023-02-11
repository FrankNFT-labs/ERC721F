// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../../../examples/ERC4906.sol";
import "../../../lib/forge-std/src/Test.sol";

/**
 * @title ERC4906Test
 *
 * @dev Contract utilised to test additional contractfunctionality and retained functionality of overridden functions
 */
contract ERC4906Test is Test {
    ERC4906 t;
    address owner;

    function setUp() public {
        t = new ERC4906();
        t.flipSaleState();
        owner = t.owner();
    }

    function testSupportsInterfaceReturnsRequiredTrue() public {
        assertTrue(t.supportsInterface(0x49064906));
    }
}
