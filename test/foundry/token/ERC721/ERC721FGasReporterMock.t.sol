// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../../../../contracts/mocks/ERC721FGasReporterMock.sol";
import "../../../../lib/forge-std/src/Test.sol";

contract ERC721FGasReporterMockTest is Test {
    ERC721FGasReporterMock t;
    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address other = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function setUp() public {
        t = new ERC721FGasReporterMock("Gas", "Gas");
    }

    function testMintOne() public {
        t.mintOne(owner);
        t.mintOne(owner);
    }

    function testMintTen() public {
        t.mintTen(owner);
        t.mintTen(owner);
    }

    function testMintHundred() public {
        t.mintHundred(owner);
        t.mintHundred(owner);
    }

    function testMintOneTransferOneAsc() public {
        t.mintOne(owner);
        vm.prank(owner);
        t.transferOneAsc(other);
        vm.prank(other);
        t.transferOneAsc(owner);
    }

    function testMintOneTransferOneDesc() public {
        t.mintOne(owner);
        vm.prank(owner);
        t.transferOneDesc(other);
        vm.prank(other);
        t.transferOneDesc(owner);
    }

    function testMintTenTransferOneAsc() public {
        t.mintTen(owner);
        vm.prank(owner);
        t.transferOneAsc(other);
    }

    function testMintTenTransferOneDesc() public {
        t.mintTen(owner);
        vm.prank(owner);
        t.transferOneDesc(other);
    }

    function testMintTenTransferTenAsc() public {
        t.mintTen(owner);
        vm.prank(owner);
        t.transferTenAsc(other);
        vm.prank(other);
        t.transferTenAsc(owner);
    }

    function testMintTenTransferTenDesc() public {
        t.mintTen(owner);
        vm.prank(owner);
        t.transferTenDesc(other);
        vm.prank(other);
        t.transferTenDesc(owner);
    }

    function testMintHundredTransferTenAsc() public {
        t.mintHundred(owner);
        vm.prank(owner);
        t.transferTenAsc(other);
    }

    function testMintHundredTransferTenDesc() public {
        t.mintHundred(owner);
        vm.prank(owner);
        t.transferTenDesc(other);
    }

    function testMintHundredTransferFiftyAsc() public {
        t.mintHundred(owner);
        vm.prank(owner);
        t.transferFiftyAsc(other);
    }

    function testMintHundredTransferFiftyDesc() public {
        t.mintHundred(owner);
        vm.prank(owner);
        t.transferFiftyDesc(other);
    }

    function testWalletOfOwner() public {
        t.mintHundred(owner);
        t.walletOfOwner(owner);
    }
}