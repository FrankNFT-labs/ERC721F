@echo off
forge snapshot --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol --snap forge-snapshots/mint.gas-snapshot --match-test '\W*(testMint)\W*'