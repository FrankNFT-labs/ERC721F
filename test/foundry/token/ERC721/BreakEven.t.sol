// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

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
    uint256 totalTransfered;
    uint256 constant backupTotalTransfered = 100;

    function setUp() public {
        t = new ERC721FGasReporterMock("GAS Stress Test", "Gas");
        try vm.envUint("BREAK_EVEN_COUNT") returns (uint256 result) {
            totalTransfered = result;
        } catch {
            totalTransfered = backupTotalTransfered;
        }
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
