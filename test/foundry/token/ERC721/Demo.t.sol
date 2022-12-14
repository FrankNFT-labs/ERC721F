// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../../../../contracts/mocks/ERC721FGasReporterMock.sol";
import "../../../../lib/forge-std/src/Test.sol";

contract Demo is Test {
    ERC721FGasReporterMock t;
    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address other = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function setUp() public {
        t = new ERC721FGasReporterMock("Gas", "Gas");
    }

    function testMintOne() public {
        t.mintOne(owner);
    }

    function testMintOneTwo() public {
        t.mintOne(owner);
    }
}