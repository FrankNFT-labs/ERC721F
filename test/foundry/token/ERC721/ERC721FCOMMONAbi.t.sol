// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "../../../../lib/forge-std/src/Test.sol";
import "../../../../contracts/mocks/ERC721FCOMMONMock.sol";

contract ERC721FCOMMONAbiTest is Test {
    ERC721FCOMMONMock internal token;

    function setUp() public {
        token = new ERC721FCOMMONMock("ABI Test", "ABI");
    }

    function test_noArgWithdraw_doesNotExistOnBase() public {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("withdraw()")
        );
        assertFalse(
            success,
            "ERC721FCOMMON must not expose a no-arg withdraw() - child contracts own their withdraw signature"
        );
    }

    function test_twoArgWithdraw_exists() public {
        vm.deal(address(token), 1 ether);
        address recipient = address(0xBEEF);

        token.withdraw(recipient, 1 ether);

        assertEq(recipient.balance, 1 ether);
    }
}
