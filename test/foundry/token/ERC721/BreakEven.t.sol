// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9 <0.9.0;

import "../../../../contracts/mocks/ERC721FGasReporterMock.sol";
import "../../../../lib/forge-std/src/Test.sol";

/**
 * Forge section commands
 * forge test --gas-report --mt '\W*(Asc)\W*'
 * forge test --gas-report --mt '\W*(Desc)\W*'
 */
contract BreakEven is Test {
    ERC721FGasReporterMock t;
    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address other = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    uint256 totalTransfered = 42;

    function setUp() public {
        t = new ERC721FGasReporterMock("GAS Stress Test", "Gas");
    }

    function testTransferAscMintHundred() public {
        t.mintHundred(owner);
        vm.prank(owner);
        t.transferAsc(totalTransfered, other);
    }

    function testTransferDescMintHundred() public {
        t.mintHundred(owner);
        vm.prank(owner);
        t.transferDesc(totalTransfered, other);
    }
}